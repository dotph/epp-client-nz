require File.expand_path('../abstract', __FILE__)

module EPP
  module Requests
    class Command < Abstract
      DNSSEC_NAMESPACE = 'urn:ietf:params:xml:ns:secDNS-1.1'

      def initialize(tid, command, extension = nil)
        @tid, @command, @extension = tid, command, extension
      end

      def name
        'command'
      end

      def to_xml
        @namespaces = {}

        node = super
        @command.set_namespaces(@namespaces) if @command.respond_to?(:set_namespaces)
        node << as_xml(@command)

        if @command.to_s.include?("domain:create") || @command.to_s.include?("domain:update")
          if @extension and @extension[:extension]
            ext_dnssec_node = generate_dnssec_node(@extension[:extension])
            node << as_xml(ext_dnssec_node) if ext_dnssec_node
          end
        else
          @extension.set_namespaces(@namespaces) if @extension && @extension.respond_to?(:set_namespaces)
          node << as_xml(@extension) if @extension
        end

        node << epp_node('clTRID', @tid, @namespaces)

        # node checking
        # if @command.to_s.include?("domain:create") || @command.to_s.include?("domain:update")
        #   raise "#{node}"
        # end

        node
      end

      protected

      def generate_dnssec_node extension
        action            = extension[:action]       # action if create or update
        max_sig_life      = extension[:max_sig_life] # maxSigLife
        create_ds_data    = extension[:ds_data]      # ds data for create
        create_key_data   = extension[:key_data]     # key data for create
        ds_for_rem        = extension[:rem]          # remove params for update
        ds_for_add        = extension[:add]          # add params for update

        #root node
        ext_node = xml_node("extension", nil)
        #action
        dnssec_action = dnssec_node(action, nil)
        #maxsiglife
        if max_sig_life
          sig_life = dnssec_node("maxSigLife", max_sig_life)
        end

        if action == "create"
          #always create ds record
          dnssec_action << sig_life

          if create_ds_data
            create_ds_data.each do |ds_data|
              ds_data_node = ds_data_node(ds_data)
              dnssec_action << ds_data_node
            end
          elsif create_key_data
            create_key_data.each do |key_data|
              key_data_node = key_data_node(key_data)
              dnssec_action << key_data_node
            end
          end

          ext_node << dnssec_action
        elsif action == "update"
          #remove ds record
          if ds_for_rem
            rem_node = dnssec_node("rem", nil)

            if ds_for_rem[:all]
              rem_all_node = dnssec_node("all", "true")
              rem_node << rem_all_node
            elsif ds_for_rem[:key_data]
              ds_for_rem[:key_data].each do |key_data|
                key_data_node = key_data_node(key_data)
                rem_node << key_data_node
              end
            elsif ds_for_rem[:ds_data]
              ds_for_rem[:ds_data].each do |ds_data|
                ds_data_node = ds_data_node(ds_data)
                rem_node << ds_data_node
              end
            end

            dnssec_action << rem_node
          end
          #add ds record
          if ds_for_add
            add_node = dnssec_node("add", nil)
            if ds_for_add[:key_data]
              ds_for_add[:key_data].each do |key_data|
                key_tag_node = dnssec_node("keyData", nil)
                key_data_node = key_data_node(key_data)
                add_node << key_data_node
              end
            elsif ds_for_add[:ds_data]
              ds_for_add[:ds_data].each do |ds_data|
                ds_data_node = ds_data_node(ds_data)
                add_node << ds_data_node
              end
            end
            dnssec_action << add_node
          end
          #chg max sig life
          if sig_life
            chg_node = dnssec_node("chg", nil)
            chg_node << sig_life
            dnssec_action << chg_node
            ext_node << dnssec_action
          end
          ext_node << dnssec_action
        end

        ext_node
      end

      def dnssec_node name, value = nil
        ext_node = xml_node(name, value)

        if @namespaces.has_key?('secDNS')
          namespace = @namespaces['secDNS']
        else
          namespace = @namespaces['secDNS'] = xml_namespace(ext_node, 'secDNS', DNSSEC_NAMESPACE)
        end

        ext_node.namespaces.namespace = namespace
        ext_node
      end

      def ds_data_node ds_data
        ds_data_node = dnssec_node("dsData", nil)

        key_tag_node      = dnssec_node("keyTag", ds_data[:key_tag])
        alg_node          = dnssec_node("alg", ds_data[:alg])
        digest_type_node  = dnssec_node("digestType", ds_data[:digest_type])
        digest_node       = dnssec_node("digest", ds_data[:digest])

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
        key_tag_node  = dnssec_node("keyData", nil)

        flags_node    = dnssec_node("flags", key_data[:flags])
        protocol_node = dnssec_node("protocol", key_data[:protocol])
        alg_type_node = dnssec_node("alg", key_data[:alg])
        pub_key_node  = dnssec_node("pubKey", key_data[:pubKey])

        key_tag_node << flags_node
        key_tag_node << protocol_node
        key_tag_node << alg_type_node
        key_tag_node << pub_key_node

        key_tag_node
      end
    end
  end
end