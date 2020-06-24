require File.expand_path('../command', __FILE__)

module EPP
  module Extension
    module Fee
      class Check < Command
        def initialize(names = [], periods = ['1','2','5','10'], period_unit = 'y')
          @names = names.flatten
          @periods = periods.flatten
          @period_unit = period_unit
        end

        def name
          'check'
        end

        def to_xml
          extension = xml_node('extension')

          node = super
          @names.each do |name|
            @periods.each do |period|
              domain = fee_node('domain')
              domain << fee_node('name', name)
              domain << fee_node('command', 'create')
              fee_period_node = fee_node('period', period)
              fee_period_node['unit'] = @period_unit
              domain << fee_period_node
              node << domain
            end
            @periods.each do |period|
              domain = fee_node('domain')
              domain << fee_node('name', name)
              domain << fee_node('command', 'renew')
              fee_period_node = fee_node('period', period)
              fee_period_node['unit'] = @period_unit
              domain << fee_period_node
              node << domain
            end
            @periods.each do |period|
              domain = fee_node('domain')
              domain << fee_node('name', name)
              domain << fee_node('command', 'transfer')
              fee_period_node = fee_node('period', period)
              fee_period_node['unit'] = @period_unit
              domain << fee_period_node
              node << domain
            end
          end

          extension << node

          extension
        end
      end
    end
  end
end
