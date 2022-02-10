module EPP
  module Extension
    module Fee
      class Command
        include XMLHelpers
        attr_reader :namespaces
        attr_reader :namespace
        attr_reader :schema_location

        def set_namespaces(namespaces)
          @namespaces = namespaces
        end

        def set_namespace(namespace)
          @namespace = namespace
        end

        def set_schema_location(schema_location)
          @schema_location = schema_location
        end

        def name
          raise NotImplementedError, "#name must be implemented in subclasses"
        end

        def to_xml
          @namespaces ||= {}
          node = fee_node(name)
          xattr = XML::Attr.new(node, "schemaLocation", @schema_location || SCHEMA_LOCATION)
          xattr.namespaces.namespace = @namespaces['xsi'] || XML::Namespace.new(node, 'xsi', 'http://www.w3.org/2001/XMLSchema-instance')

          node
        end

        protected
          def fee_node(name, value = nil)
            node = xml_node(name, value)
            node.namespaces.namespace = domain_namespace(node)
            node
          end
          def domain_namespace(node)
            return @namespaces['fee'] if @namespaces.has_key?('fee')
            @namespaces['fee'] = xml_namespace(node, 'fee', @namespace || NAMESPACE)
          end
      end
    end
  end
end
