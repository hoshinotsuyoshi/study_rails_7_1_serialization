# frozen_string_literal: true
require 'benchmark/ips'

# NOTE: Do not use it for any purpose other than checking the operation of the script. This is insecure.
# $ cat tmp/local_secret.txt
# 1a5ccd6f81c927016d72d7d5e1d5f4a718b9cada8e02459be5c3288b0d27e084cedc98fa00c6ababa035c462cf11a463e6670fb996700e20fb806e586a1e9870

marshal_encoded_key = "BAh7BkkiC19yYWlscwY6BkVUewhJIglkYXRhBjsAVHsJOghrZXlJIiFhcjlpbnA2YzVmOTA2NGpib29pMHh0NzUzODI5BjsAVDoQZGlzcG9zaXRpb25JIj1hdHRhY2htZW50OyBmaWxlbmFtZT0iR2VtZmlsZSI7IGZpbGVuYW1lKj1VVEYtOCcnR2VtZmlsZQY7AFQ6EWNvbnRlbnRfdHlwZUkiHWFwcGxpY2F0aW9uL29jdGV0LXN0cmVhbQY7AFQ6EXNlcnZpY2VfbmFtZToKbG9jYWxJIghleHAGOwBUSSIdMjAyNS0wMS0wM1QwODoyNTo1Ny4zMDBaBjsAVEkiCHB1cgY7AFRJIg1ibG9iX2tleQY7AEY=--2ca3cdd6f7880965789bfd02df337ddb12e3040a"
# Marshal.load(Base64.decode64(marshal_encoded_key))
# => {"_rails"=>
#   {"data"=>
#     {:key=>"ar9inp6c5f9064jbooi0xt753829",
#      :disposition=>"attachment; filename=\"Gemfile\"; filename*=UTF-8''Gemfile",
#      :content_type=>"application/octet-stream",
#      :service_name=>:local},
#    "exp"=>"2025-01-03T08:25:57.300Z",
#    "pur"=>"blob_key"}}

message_pack_encoded_key = "zICBpl9yYWlsc4OkZGF0YYTHAwBrZXm8YXI5aW5wNmM1ZjkwNjRqYm9vaTB4dDc1MzgyOccLAGRpc3Bvc2l0aW9u2ThhdHRhY2htZW50OyBmaWxlbmFtZT0iR2VtZmlsZSI7IGZpbGVuYW1lKj1VVEYtOCcnR2VtZmlsZccMAGNvbnRlbnRfdHlwZbhhcHBsaWNhdGlvbi9vY3RldC1zdHJlYW3HDABzZXJ2aWNlX25hbWXHBQBsb2NhbKNleHDHCwfOZ3ed1s4KSJGAAKNwdXKoYmxvYl9rZXk=--1cb95cac735e371099af81e088e325587cee761c"

json_encoded_key = "eyJfcmFpbHMiOnsiZGF0YSI6eyJrZXkiOiJhcjlpbnA2YzVmOTA2NGpib29pMHh0NzUzODI5IiwiZGlzcG9zaXRpb24iOiJhdHRhY2htZW50OyBmaWxlbmFtZT1cIkdlbWZpbGVcIjsgZmlsZW5hbWUqPVVURi04JydHZW1maWxlIiwiY29udGVudF90eXBlIjoiYXBwbGljYXRpb24vb2N0ZXQtc3RyZWFtIiwic2VydmljZV9uYW1lIjoibG9jYWwifSwiZXhwIjoiMjAyNS0wMS0wM1QwODoyODo0Ni44NzFaIiwicHVyIjoiYmxvYl9rZXkifX0=--ccf4874d705a19f158a724a5a6f0fcd502c09f15"

secret = ActiveSupport::KeyGenerator.new(Rails.application.secret_key_base, iterations: 1000).generate_key('ActiveStorage')

message_pack_verifier = ActiveSupport::MessageVerifier.new(secret, serializer: ActiveSupport::Messages::SerializerWithFallback::MessagePackWithFallback)
marshal_verifier      = ActiveSupport::MessageVerifier.new(secret, serializer: Marshal)
json_verifier         = ActiveSupport::MessageVerifier.new(secret, serializer: JSON)

Benchmark.ips do |x|
  x.report("message_pack") { message_pack_verifier.verify(message_pack_encoded_key, purpose: 'blob_key') }
  x.report("marshal")      {      marshal_verifier.verify(marshal_encoded_key,      purpose: 'blob_key') }
  x.report("json")         {         json_verifier.verify(json_encoded_key,         purpose: 'blob_key') }
  x.compare!
end


# $ bundle exec rails r bench.rb
# ruby 3.3.0 (2023-12-25 revision 5124f9ac75) [arm64-darwin22]
# Warming up --------------------------------------
#         message_pack     8.424k i/100ms
#              marshal     6.404k i/100ms
#                 json     6.474k i/100ms
# Calculating -------------------------------------
#         message_pack     83.365k (± 2.0%) i/s -    421.200k in   5.054535s
#              marshal     65.144k (± 8.1%) i/s -    326.604k in   5.080721s
#                 json     66.535k (± 1.8%) i/s -    336.648k in   5.061440s
#
# Comparison:
#         message_pack:    83365.3 i/s
#                 json:    66535.3 i/s - 1.25x  slower
#              marshal:    65143.5 i/s - 1.28x  slower
