module EPP
  module Extension
    module SecDns
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
          node = sec_dns_node(name)
          xattr = XML::Attr.new(node, "schemaLocation", SCHEMA_LOCATION)
          xattr.namespaces.namespace = @namespaces['xsi'] || XML::Namespace.new(node, 'xsi', 'http://www.w3.org/2001/XMLSchema-instance')

          node
        end

        protected
          def sec_dns_node(name, value = nil)
            node = xml_node(name, value)
            node.namespaces.namespace = sec_dns_namespace(node)
            node
          end

          def ds_data_node ds_data
            ds_data_node = sec_dns_node("dsData", nil)

            key_tag_node      = sec_dns_node("keyTag", ds_data[:key_tag])
            alg_node          = sec_dns_node("alg", ds_data[:alg])
            digest_type_node  = sec_dns_node("digestType", ds_data[:digest_type])
            digest_node       = sec_dns_node("digest", ds_data[:digest])

            ds_data_node << key_tag_node
            ds_data_node << alg_node
            ds_data_node << digest_type_node
            ds_data_node << digest_node

            if ds_data[:key_data]
              key_data      = ds_data[:key_data]
              key_data_node = key_data_node(key_data)
              ds_data_node << key_data_node
            end

            ds_data_node
          end

          def key_data_node key_data
            key_tag_node  = sec_dns_node("keyData", nil)

            flags_node    = sec_dns_node("flags", key_data[:flags])
            protocol_node = sec_dns_node("protocol", key_data[:protocol])
            alg_type_node = sec_dns_node("alg", key_data[:alg])
            pub_key_node  = sec_dns_node("pubKey", key_data[:pubKey])

            key_tag_node << flags_node
            key_tag_node << protocol_node
            key_tag_node << alg_type_node
            key_tag_node << pub_key_node

            key_tag_node
          end

          def sec_dns_namespace(node)
            return @namespaces['secDNS'] if @namespaces.has_key?('secDNS')
            @namespaces['secDNS'] = xml_namespace(node, 'secDNS', @namespace || NAMESPACE)
          end
      end
    end
  end
end