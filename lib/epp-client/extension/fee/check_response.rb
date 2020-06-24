require File.expand_path('../response', __FILE__)

module EPP
  module Extension
    module Fee
      class CheckResponse < Response
        def fees(name, command)
          fees = get_fees command
          return fees

          raise ArgumentError, "no fee found for #{name}"
        end

        def fee_type(name, command)
          fees = get_fees command
          return fees.first[:class]

          raise ArgumentError, "no fee type found for #{name}"
        end

        def fee(name, command, period)
          return get_fees(command, period)

          raise ArgumentError, "no fee found for #{name}"
        end

        protected
          def create_fees
            @create_fees = get_fees('create')
          end

          def renew_fees
            @renew_fees = get_fees('renew')
          end

          def transfer_fees
            @transfer_fees = get_fees('transfer')
          end

          def get_fees(command, period = '1')
            @fees = []
            fees_path = nodes_for_xpath('//fee:cd', @response.extension)
            fees_path.each do |path|
              hash = Hash.new
              path.reject{|text_node| text_node.name == 'text'}.each do |node|
                if node.name == 'period'
                  hash[node.name.to_sym] = node.content.to_i
                elsif node.name == 'fee'
                  hash[node.name.to_sym] = node.content.to_f
                else
                  hash[node.name.to_sym] = node.content
                end
              end
              @fees << hash
            end
            if command.present?
              @fees.select{|fee| fee[:command] == command}
            else
              @fees
            end
          end
      end
    end
  end
end
