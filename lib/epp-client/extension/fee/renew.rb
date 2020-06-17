require File.expand_path('../command', __FILE__)

module EPP
  module Extension
    module Fee
      class Renew < Command
        def initialize(options = {})
          @currency = options[:currency]  || 'USD'
          @fee     = options[:fee_price]  || 0
        end

        def name
          'renew'
        end

        def to_xml
          extension = xml_node('extension')
          node = super
          node << fee_node('currency', @currency)
          node << fee_node('fee', @fee)
          extension << node

          extension
        end
      end
    end
  end
end
