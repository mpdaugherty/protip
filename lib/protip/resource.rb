# Missing dependencies from the other requires
require 'active_model/callbacks'
require 'active_model/validator'
require 'active_support/callbacks'
require 'active_support/core_ext/module/delegation'

require 'active_support/concern'
require 'active_support/core_ext/object/blank'

require 'active_model/validations'
require 'active_model/conversion'
require 'active_model/naming'
require 'active_model/translation'
require 'active_model/errors'

require 'active_model/attribute_methods' # ActiveModel::Dirty depends on this
require 'active_model/dirty'

require 'forwardable'

require 'protip/error'
require 'protip/standard_converter'
require 'protip/wrapper'

require 'protip/messages/array'

require 'protip/resource/creatable'
require 'protip/resource/updateable'
require 'protip/resource/destroyable'
require 'protip/resource/extra_methods'
require 'protip/resource/search_methods'

module Protip
  module Resource
    extend ActiveSupport::Concern

    # Backport the ActiveModel::Model functionality
    # https://github.com/rails/rails/blob/097ca3f1f84bb9a2d3cda3f2cce7974a874efdf4/activemodel/lib/active_model/model.rb#L95
    include ActiveModel::Validations
    include ActiveModel::Conversion

    include ActiveModel::Dirty

    included do
      extend ActiveModel::Naming
      extend ActiveModel::Translation
      extend Forwardable

      def_delegator :@wrapper, :message
      def_delegator :@wrapper, :as_json
    end

    module ClassMethods

      VALID_ACTIONS = %i(show index create update destroy)

      attr_accessor :client

      attr_reader :message, :nested_resources

      attr_writer :base_path, :converter

      def base_path
        if @base_path == nil
          raise(RuntimeError.new 'Base path not yet set')
        else
          @base_path.gsub(/\/$/, '')
        end
      end

      def converter
        @converter || (@_standard_converter ||= Protip::StandardConverter.new)
      end

      private

      # Primary entry point for defining resourceful behavior.
      def resource(actions:, message:, query: nil, nested_resources: {})
        raise RuntimeError.new('Only one call to `resource` is allowed') if @message
        validate_actions!(actions)
        validate_nested_resources!(nested_resources)

        @message = message
        @nested_resources = nested_resources

        define_attribute_accessors(@message)
        define_oneof_group_methods(@message)
        define_resource_query_methods(query, actions)

        include(::Protip::Resource::Creatable) if actions.include?(:create)
        include(::Protip::Resource::Updatable) if actions.include?(:update)
        include(::Protip::Resource::Destroyable) if actions.include?(:destroy)
      end

      def validate_nested_resources!(nested_resources)
        nested_resources.each do |key, resource_klass|
          unless key.is_a?(Symbol)
            raise "#{key} must be a Symbol, but is a #{key.class}"
          end
          unless resource_klass < ::Protip::Resource
            raise "#{resource_klass} is not a Protip::Resource"
          end
        end
      end

      def validate_actions!(actions)
        actions.map!{|action| action.to_sym}
        (actions - VALID_ACTIONS).each do |action|
          raise ArgumentError.new("Unrecognized action: #{action}")
        end
      end

      # Allow calls to oneof groups to get the set oneof field
      def define_oneof_group_methods(message)
        message.descriptor.each_oneof do |oneof_field|
          def_delegator :@wrapper, :"#{oneof_field.name}"
        end
      end

      # Define attribute readers/writers
      def define_attribute_accessors(message)
        message.descriptor.each do |field|
          def_delegator :@wrapper, :"#{field.name}"
          if ::Protip::Wrapper.matchable?(field)
            def_delegator :@wrapper, :"#{field.name}?"
          end

          define_method "#{field.name}=" do |new_value|
            old_wrapped_value = @wrapper.send(field.name)
            @wrapper.send("#{field.name}=", new_value)
            new_wrapped_value = @wrapper.send(field.name)

            # needed for ActiveModel::Dirty
            send("#{field.name}_will_change!") if new_wrapped_value != old_wrapped_value
          end

          # needed for ActiveModel::Dirty
          define_attribute_method field.name
        end
      end

      # For index/show, we want a different number of method arguments
      # depending on whether a query message was provided.
      def define_resource_query_methods(query, actions)
        if query
          if actions.include?(:show)
            define_singleton_method :find do |id, query_params = {}|
              wrapper = ::Protip::Wrapper.new(query.new, converter)
              wrapper.assign_attributes query_params
              ::Protip::Resource::SearchMethods.show(self, id, wrapper.message)
            end
          end

          if actions.include?(:index)
            define_singleton_method :all do |query_params = {}|
              wrapper = ::Protip::Wrapper.new(query.new, converter)
              wrapper.assign_attributes query_params
              ::Protip::Resource::SearchMethods.index(self, wrapper.message)
            end
          end
        else
          if actions.include?(:show)
            define_singleton_method :find do |id|
              ::Protip::Resource::SearchMethods.show(self, id, nil)
            end
          end

          if actions.include?(:index)
            define_singleton_method :all do
              ::Protip::Resource::SearchMethods.index(self, nil)
            end
          end
        end
      end

      def member(action:, method:, request: nil, response: nil)
        if request
          define_method action do |request_params = {}|
            wrapper = ::Protip::Wrapper.new(request.new, self.class.converter)
            wrapper.assign_attributes request_params
            ::Protip::Resource::ExtraMethods.member self, action, method, wrapper.message, response
          end
        else
          define_method action do
            ::Protip::Resource::ExtraMethods.member self, action, method, nil, response
          end
        end
      end

      def collection(action:, method:, request: nil, response: nil)
        if request
          define_singleton_method action do |request_params = {}|
            wrapper = ::Protip::Wrapper.new(request.new, converter)
            wrapper.assign_attributes request_params
            ::Protip::Resource::ExtraMethods.collection self,
                                                        action,
                                                        method,
                                                        wrapper.message,
                                                        response
          end
        else
          define_singleton_method action do
            ::Protip::Resource::ExtraMethods.collection self, action, method, nil, response
          end
        end
      end
    end

    def initialize(message_or_attributes = {})
      if self.class.message == nil
        raise RuntimeError.new('Must define a message class using `resource`')
      end
      if message_or_attributes.is_a?(self.class.message)
        self.message = message_or_attributes
      else
        self.message = self.class.message.new
        assign_attributes message_or_attributes
      end

      super()
    end

    def assign_attributes(attributes)
      # the resource needs to call its own setters so that fields get marked as dirty
      attributes.each { |field_name, value| send("#{field_name}=", value) }
      nil # return nil to match ActiveRecord behavior
    end

    def message=(message)
      @wrapper = Protip::Wrapper.new(message, self.class.converter, self.class.nested_resources)
    end

    def save
      success = true
      begin
        if persisted?
          # TODO: use `ActiveModel::Dirty` to only send changed attributes?
          update!
        else
          create!
        end
        changes_applied
      rescue Protip::UnprocessableEntityError => error
        success = false
        error.errors.messages.each do |message|
          errors.add :base, message
        end
        error.errors.field_errors.each do |field_error|
          errors.add field_error.field, field_error.message
        end
      end
      success
    end

    def persisted?
      id != nil
    end

    def attributes
      # Like `.as_json`, but includes nil fields to match ActiveRecord behavior.
      self.class.message.descriptor.map{|field| field.name}.inject({}) do |hash, attribute_name|
        hash[attribute_name] = public_send(attribute_name)
        hash
      end
    end

    def errors
      @errors ||= ActiveModel::Errors.new(self)
    end

    private

    # needed for ActiveModel::Dirty
    def changes_applied
      @previously_changed = changes
      @changed_attributes.clear
    end

  end
end
