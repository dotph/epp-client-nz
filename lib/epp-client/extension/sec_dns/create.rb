require File.expand_path('../command', __FILE__)

module EPP
  module Extension
    module SecDns
      class Create < Command
        def initialize(opts={})
          @ds_data      = opts[:ds_data]
          @key_data     = opts[:key_data]
          @max_sig_life = opts[:max_sig_life]
        end

        def name
          'secDNS'
        end

        def to_xml
          extension = xml_node('extension')

          node = super
          sec_node = sec_dns_node('create')

          #maxsiglife
          if @max_sig_life
            sig_life = sec_dns_node("maxSigLife", @max_sig_life)
          end

          sec_node << sig_life if sig_life

          if @ds_data
            @ds_data.each do |ds_data|
              ds_data_node = ds_data_node(ds_data)
              sec_node << ds_data_node
            end
          elsif @key_data
            @key_data.each do |key_data|
              key_data_node = key_data_node(key_data)
              sec_node << key_data_node
            end
          end

          node << sec_node

          extension << node

          extension
        end
      end
    end
  end
end

#example
# client = EPP::Client.new username, password, host
# epp = client.update(
#   EPP::Domain::Update.new("again-xtest-jul-5-0010.net.ph", {
#     chg: {
#       registrant: "P-BVM466"
#     }
#   }),
#   EPP::Extension::SecDns::Create.new({
#     max_sig_life: '1231',
#     ds_data: [
#       {
#         key_tag: "12345",
#         alg: "3",
#         digest_type: "1",
#         digest: "38EC35D5B3A34B33C99B"
#       },
#       {
#         key_tag: "12345",
#         alg: "3",
#         digest_type: "1",
#         digest: "38EC35D5B3A34B33C99B",
#         key_data: {
#           flags: "123",
#           protocol: "2",
#           alg: "1",
#           pubKey: "AQPJ////4Q=="
#         }
#       }
#     ]
#   })
# )

## Key Data Only
# client = EPP::Client.new username, password, host
# epp = client.update(
#   EPP::Domain::Update.new("again-xtest-jul-5-0010.net.ph", {
#     chg: {
#       registrant: "P-BVM466"
#     }
#   }),
#   EPP::Extension::SecDns::Create.new({
#     max_sig_life: '1231',
#     key_data: [
#       {
#           flags: "123",
#           protocol: "2",
#           alg: "1",
#           pubKey: "AQPJ////4Q=="
#       },
#       {
#           flags: "123",
#           protocol: "2",
#           alg: "1",
#           pubKey: "AQPJ////4Q=="
#       }
#     ]
#   })
# )