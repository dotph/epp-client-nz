require File.expand_path('../command', __FILE__)

module EPP
  module Extension
    module Keysys
      class Update < Command
        def initialize(opts={})
          @node_for      = opts[:node_for]
          @triggerfoa    = opts[:triggerfoa]
          @accept_trade  = opts[:accept_trade]
        end

        def name
          'update'
        end

        def to_xml
          extension = xml_node('extension')

          node = super
          node_for = keysys_node(@node_for)
          node_for  << keysys_node("triggerfoa", @triggerfoa) if @triggerfoa
          node_for  << keysys_node("accept_trade", @accept_trade) if @accept_trade
          node << node_for

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
#   EPP::Extension::Keysys::Update.new({
#     node_for: "contact",
#     triggerfoa: "1",
#     accept_trade: "1"
#   })
# )

# client = EPP::Client.new username, password, host
# epp = client.update(
#   EPP::Domain::Update.new("again-xtest-jul-5-0010.net.ph", {
#     chg: {
#       registrant: "P-BVM466"
#     }
#   }),
#   EPP::Extension::Keysys::Update.new({
#     node_for: "domain",
#     triggerfoa: "1",
#   })
# )