require File.expand_path('../command', __FILE__)

module EPP
  module Extension
    module Rgp
      class Update < Command
        def initialize(opts={})
          @node_for  = opts[:node_for] || "restore"
          @op        = opts[:op]
          @resreason = opts[:resreason]

          @predata   = opts[:predata]
          @postdata  = opts[:postdata]
          @deltime   = opts[:deltime]
          @restime   = opts[:restime]
          @statement = opts[:statement]
          @other     = opts[:other]
        end

        def name
          'update'
        end

        def to_xml
          extension = xml_node("extension")

          node = super
          node_for = rgp_node(@node_for)
          XML::Attr.new(node_for, "op", @op)

          if @op == "report"
            report_node = rgp_node("report")
            report_node << rgp_node("resReason", @resreason) if @resreason
            report_node << rgp_node("preData", @predata) if @predata
            report_node << rgp_node("postData", @postdata) if @postdata
            report_node << rgp_node("delTime", @deltime) if @deltime
            report_node << rgp_node("resTime", @restime) if @restime
            report_node << rgp_node("statement", @statement) if @statement
            report_node << rgp_node("other", @other) if @other

            node_for << report_node
          end
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