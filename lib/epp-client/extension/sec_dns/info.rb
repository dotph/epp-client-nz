require File.expand_path('../command', __FILE__)

module EPP
  module Extension
    module SecDns
      class Info < Command
        # def initialize(opts={})
        #   @node_for      = opts[:node_for]
        #   @triggerfoa    = opts[:triggerfoa]
        #   @accept_trade  = opts[:accept_trade]
        # end

        # def name
        #   'keysys'
        # end

        # def to_xml
        #   extension = xml_node('extension')

        #   node = super
        #   node_for = keysys_node(@node_for)
        #   node_for  << keysys_node("triggerfoa", @triggerfoa) if @triggerfoa
        #   node_for  << keysys_node("accept_trade", @accept_trade) if @accept_trade
        #   node << node_for

        #   extension << node

        #   extension
        # end
      end
    end
  end
end