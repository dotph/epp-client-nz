require File.expand_path('../command', __FILE__)

module EPP
  module Extension
    module Fee
      class Check < Command
        def initialize(*names)
          @names = names.flatten
        end

        def name
          'check'
        end

        def to_xml
          extension = xml_node('extension')

          node = super
          @names.each do |name|
            domain = fee_node('domain')
            domain << fee_node('name', name)
            domain << fee_node('currency', 'USD')
            domain << fee_node('command', 'create')
            node << domain
          end
          extension << node
          
          extension
        end
      end
    end
  end
end
