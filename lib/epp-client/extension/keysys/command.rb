module EPP
  module Extension
    module Keysys
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
          node = keysys_node(name)
          xattr = XML::Attr.new(node, "schemaLocation", SCHEMA_LOCATION)
          xattr.namespaces.namespace = @namespaces['xsi'] || XML::Namespace.new(node, 'xsi', 'http://www.w3.org/2001/XMLSchema-instance')

          node
        end

        protected
          def keysys_node(name, value = nil)
            node = xml_node(name, value)
            node.namespaces.namespace = keysys_namespace(node)
            node
          end

          def keysys_namespace(node)
            return @namespaces['keysys'] if @namespaces.has_key?('keysys')
            @namespaces['keysys'] = xml_namespace(node, 'keysys', @namespace || NAMESPACE)
          end
      end
    end
  end
end