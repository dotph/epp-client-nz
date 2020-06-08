require File.expand_path('../response', __FILE__)

module EPP
  module Extension
    module Fee
      class CheckResponse < Response
        def fees(name, command)
          fees = get_fees command
          return fees[name]['fee'] if fees[name]

          raise ArgumentError, "no fee found for #{name}"
        end

        def fee_type(name, command)
          fees = get_fees command
          return fees[name]['class'] if fees[name]

          raise ArgumentError, "no fee type found for #{name}"
        end

        protected
          def create_fees
            @create_fees = get_fees 'create'
          end

          def renew_fees
            @renew_fees = get_fees 'renew'
          end

          def transfer_fees
            @transfer_fees = get_fees 'transfer'
          end

          def get_fees command
            @fees = {}
            fees_path = nodes_for_xpath('//fee:cd', @response.extension)
            fees_path.each do |path|
              node_map = {'fee' => 0.0}
              path.each do |node|
                if node.name == 'fee'
                  node_map['fee'] += node.content.to_f
                else
                  node_map[node.name] = node.content
                end
              end
              @fees[node_map['name']] = node_map if node_map['command'] == command
            end
            @fees
          end
      end
    end
  end
end
