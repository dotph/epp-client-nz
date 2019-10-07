require File.expand_path('../command', __FILE__)

module EPP
  module Extension
    module SecDns
      class Update < Command
        def initialize(opts={})
          @ds_for_rem   = opts[:rem]
          @ds_for_add   = opts[:add]
          @max_sig_life = opts[:max_sig_life]
        end

        def name
          'update'
        end

        def to_xml
          extension = xml_node('extension')

          node = super

          #maxsiglife
          if @max_sig_life
            sig_life = sec_dns_node("maxSigLife", @max_sig_life)
          end

          #remove ds record
          if @ds_for_rem
            rem_node = sec_dns_node('rem')

            if @ds_for_rem[:all]
              rem_all_node = sec_dns_node("all", "true")
              rem_node << rem_all_node
            elsif @ds_for_rem[:key_data]
              @ds_for_rem[:key_data].each do |key_data|
                key_data_node = key_data_node(key_data)
                rem_node << key_data_node
              end
            else @ds_for_rem[:ds_data]
              @ds_for_rem[:ds_data].each do |ds_data|
                ds_data_node = ds_data_node(ds_data)
                rem_node << ds_data_node
              end
            end

            node << rem_node
          end
          #add ds record
          if @ds_for_add
            add_node = sec_dns_node("add", nil)
            if @ds_for_add[:key_data]
              @ds_for_add[:key_data].each do |key_data|
                key_tag_node = sec_dns_node("keyData", nil)
                key_data_node = key_data_node(key_data)
                add_node << key_data_node
              end
            elsif @ds_for_add[:ds_data]
              @ds_for_add[:ds_data].each do |ds_data|
                ds_data_node = ds_data_node(ds_data)
                add_node << ds_data_node
              end
            end

            node << add_node
          end
          #chg max sig life
          if sig_life
            chg_node = sec_dns_node("chg", nil)
            chg_node << sig_life
            node << chg_node
          end

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
#   EPP::Extension::SecDns::Update.new({
#     max_sig_life: '1231',
#     rem: {
#       # all: true, # <<- set all to true to automatically remove all ds data
#       ds_data: [
#         {
#           key_tag: "12346",
#           alg: "3",
#           digest_type: "1",
#           digest: "38EC35D5B3A34B33C99B"
#         },
#         {
#           key_tag: "12345",
#           alg: "3",
#           digest_type: "1",
#           digest: "38EC35D5B3A34B33C99C",
#           key_data: {
#             flags: "123",
#             protocol: "2",
#             alg: "1",
#             pubKey: "AQPJ////4Q=="
#           }
#         }
#       ]
#     },
#     add: {
#       ds_data: [
#         {
#           key_tag: "12346",
#           alg: "3",
#           digest_type: "1",
#           digest: "38EC35D5B3A34B33C99B"
#         },
#         {
#           key_tag: "12345",
#           alg: "3",
#           digest_type: "1",
#           digest: "38EC35D5B3A34B33C99C",
#           key_data: {
#             flags: "123",
#             protocol: "2",
#             alg: "1",
#             pubKey: "AQPJ////4Q=="
#           }
#         }
#       ]
#     }
#   })
# )

## Key Data only
# client = EPP::Client.new username, password, host
# epp = client.update(
#   EPP::Domain::Update.new("again-xtest-jul-5-0010.net.ph", {
#     chg: {
#       registrant: "P-BVM466"
#     }
#   }),
#   EPP::Extension::SecDns::Update.new({
#     max_sig_life: '1231',
#     rem: {
#       # all: true,
#       key_data: [
#         {
#             flags: "123",
#             protocol: "2",
#             alg: "1",
#             pubKey: "AQPJ////4Q=="
#         },
#         {
#             flags: "123",
#             protocol: "2",
#             alg: "1",
#             pubKey: "AQPJ////4Q=="
#         }
#       ]
#     },
#     add: {
#       key_data: [
#         {
#             flags: "123",
#             protocol: "2",
#             alg: "1",
#             pubKey: "AQPJ////4Q=="
#         },
#         {
#             flags: "123",
#             protocol: "2",
#             alg: "1",
#             pubKey: "AQPJ////4Q=="
#         }
#       ]
#     }
#   })
# )