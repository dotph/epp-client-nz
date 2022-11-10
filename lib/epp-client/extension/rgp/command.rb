module EPP
  module Extension
    module Rgp
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
          node = rgp_node(name)

          # xattr = XML::Attr.new(node, "schemaLocation", SCHEMA_LOCATION)
          # xattr.namespaces.namespace = @namespaces['xsi'] || XML::Namespace.new(node, 'xsi', 'http://www.w3.org/2001/XMLSchema-instance')

          node
        end

        protected
          def rgp_node(name, value = nil)
            node = xml_node(name, value)
            node.namespaces.namespace = rgp_namespace(node)
            node
          end

          def rgp_namespace(node)
            return @namespaces['rgp'] if @namespaces.has_key?('rgp')
            @namespaces['rgp'] = xml_namespace(node, 'rgp', @namespace || NAMESPACE)
          end
      end
    end
  end
end