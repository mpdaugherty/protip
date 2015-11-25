# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: protip/messages/money.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "protip.messages.Money" do
    optional :amount_cents, :int64, 1
    optional :currency, :enum, 2, "protip.messages.Money.Currency"
  end
  add_enum "protip.messages.Money.Currency" do
    value :AED, 0
    value :AFN, 1
    value :ALL, 2
    value :AMD, 3
    value :ANG, 4
    value :AOA, 5
    value :ARS, 6
    value :AUD, 7
    value :AWG, 8
    value :AZN, 9
    value :BAM, 10
    value :BBD, 11
    value :BDT, 12
    value :BGN, 13
    value :BHD, 14
    value :BIF, 15
    value :BMD, 16
    value :BND, 17
    value :BOB, 18
    value :BRL, 19
    value :BSD, 20
    value :BTN, 21
    value :BWP, 22
    value :BYR, 23
    value :BZD, 24
    value :CAD, 25
    value :CDF, 26
    value :CHF, 27
    value :CLF, 28
    value :CLP, 29
    value :CNY, 30
    value :COP, 31
    value :CRC, 32
    value :CUC, 33
    value :CUP, 34
    value :CVE, 35
    value :CZK, 36
    value :DJF, 37
    value :DKK, 38
    value :DOP, 39
    value :DZD, 40
    value :EGP, 41
    value :ERN, 42
    value :ETB, 43
    value :EUR, 44
    value :FJD, 45
    value :FKP, 46
    value :GBP, 47
    value :GEL, 48
    value :GHS, 49
    value :GIP, 50
    value :GMD, 51
    value :GNF, 52
    value :GTQ, 53
    value :GYD, 54
    value :HKD, 55
    value :HNL, 56
    value :HRK, 57
    value :HTG, 58
    value :HUF, 59
    value :IDR, 60
    value :ILS, 61
    value :INR, 62
    value :IQD, 63
    value :IRR, 64
    value :ISK, 65
    value :JMD, 66
    value :JOD, 67
    value :JPY, 68
    value :KES, 69
    value :KGS, 70
    value :KHR, 71
    value :KMF, 72
    value :KPW, 73
    value :KRW, 74
    value :KWD, 75
    value :KYD, 76
    value :KZT, 77
    value :LAK, 78
    value :LBP, 79
    value :LKR, 80
    value :LRD, 81
    value :LSL, 82
    value :LTL, 83
    value :LVL, 84
    value :LYD, 85
    value :MAD, 86
    value :MDL, 87
    value :MGA, 88
    value :MKD, 89
    value :MMK, 90
    value :MNT, 91
    value :MOP, 92
    value :MRO, 93
    value :MUR, 94
    value :MVR, 95
    value :MWK, 96
    value :MXN, 97
    value :MYR, 98
    value :MZN, 99
    value :NAD, 100
    value :NGN, 101
    value :NIO, 102
    value :NOK, 103
    value :NPR, 104
    value :NZD, 105
    value :OMR, 106
    value :PAB, 107
    value :PEN, 108
    value :PGK, 109
    value :PHP, 110
    value :PKR, 111
    value :PLN, 112
    value :PYG, 113
    value :QAR, 114
    value :RON, 115
    value :RSD, 116
    value :RUB, 117
    value :RWF, 118
    value :SAR, 119
    value :SBD, 120
    value :SCR, 121
    value :SDG, 122
    value :SEK, 123
    value :SGD, 124
    value :SHP, 125
    value :SKK, 126
    value :SLL, 127
    value :SOS, 128
    value :SRD, 129
    value :SSP, 130
    value :STD, 131
    value :SVC, 132
    value :SYP, 133
    value :SZL, 134
    value :THB, 135
    value :TJS, 136
    value :TMT, 137
    value :TND, 138
    value :TOP, 139
    value :TRY, 140
    value :TTD, 141
    value :TWD, 142
    value :TZS, 143
    value :UAH, 144
    value :UGX, 145
    value :USD, 146
    value :UYU, 147
    value :UZS, 148
    value :VEF, 149
    value :VND, 150
    value :VUV, 151
    value :WST, 152
    value :XAF, 153
    value :XAG, 154
    value :XAU, 155
    value :XCD, 156
    value :XDR, 157
    value :XOF, 158
    value :XPF, 159
    value :YER, 160
    value :ZAR, 161
    value :ZMK, 162
    value :ZMW, 163
    value :BTC, 164
    value :JEP, 165
    value :EEK, 166
    value :MTL, 167
    value :TMM, 168
    value :ZWD, 169
    value :ZWL, 170
    value :ZWN, 171
    value :ZWR, 172
  end
end

module Protip
  module Messages
    Money = Google::Protobuf::DescriptorPool.generated_pool.lookup("protip.messages.Money").msgclass
    Money::Currency = Google::Protobuf::DescriptorPool.generated_pool.lookup("protip.messages.Money.Currency").enummodule
  end
end
