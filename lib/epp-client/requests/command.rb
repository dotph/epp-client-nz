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
            extention_node = generate_extension_node(@extension[:extension])
            node << as_xml(extention_node) if extention_node
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

      def generate_extension_node extension
        # default values
        @namespace        = extension[:namespace]    # name of the namespace, example: 'secDNS', 'keysys'
        @uri              = extension[:uri]          # xmlns value
        action            = extension[:action]       # action if create or update
        # for DNSSEC
        max_sig_life      = extension[:max_sig_life] # maxSigLife
        create_ds_data    = extension[:ds_data]      # ds data for create
        create_key_data   = extension[:key_data]     # key data for create
        ds_for_rem        = extension[:rem]          # remove params for update
        ds_for_add        = extension[:add]          # add params for update
        # for keysys
        domain            = extension[:domain]       # for triggerfoa

        # kindly update for any additional extension. Just make sure everything works

        #root node
        ext_node = xml_node("extension", nil)
        #action
        namespace_node = create_node(action, nil)
        #maxsiglife
        if max_sig_life
          sig_life = create_node("maxSigLife", max_sig_life)
        end

        if action == "create"
          #always create ds record
          namespace_node << sig_life

          if create_ds_data
            create_ds_data.each do |ds_data|
              ds_data_node = ds_data_node(ds_data)
              namespace_node << ds_data_node
            end
          elsif create_key_data
            create_key_data.each do |key_data|
              key_data_node = key_data_node(key_data)
              namespace_node << key_data_node
            end
          end

          ext_node << namespace_node
        elsif action == "update"
          #remove ds record
          if ds_for_rem
            rem_node = create_node("rem", nil)

            if ds_for_rem[:all]
              rem_all_node = create_node("all", "true")
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

            namespace_node << rem_node
          end
          #add ds record
          if ds_for_add
            add_node = create_node("add", nil)
            if ds_for_add[:key_data]
              ds_for_add[:key_data].each do |key_data|
                key_tag_node = create_node("keyData", nil)
                key_data_node = key_data_node(key_data)
                add_node << key_data_node
              end
            elsif ds_for_add[:ds_data]
              ds_for_add[:ds_data].each do |ds_data|
                ds_data_node = ds_data_node(ds_data)
                add_node << ds_data_node
              end
            end
            namespace_node << add_node
          end
          #chg max sig life
          if sig_life
            chg_node = create_node("chg", nil)
            chg_node << sig_life
            namespace_node << chg_node
            ext_node << namespace_node
          end

          #keysys domain triggerfoa
          if domain
            domain_node = create_node("domain", nil)

            if domain[:triggerfoa]
              triggerfoa_node = create_node("triggerfoa", domain[:triggerfoa])
              domain_node << triggerfoa_node
            end

            if domain[:accept_trade]
              accept_trade = create_node("accept-trade", domain[:accept_trade])
              domain_node << accept_trade
            end

            namespace_node << domain_node
          end

          ext_node << namespace_node
        end

        ext_node
      end

      def create_node action, value = nil
        ext_node = xml_node(action, value)

        if @namespaces.has_key?(@namespace)
          namespace = @namespaces[@namespace]
        else
          namespace = @namespaces[@namespace] = xml_namespace(ext_node, @namespace, @uri)
        end

        ext_node.namespaces.namespace = namespace
        ext_node
      end

      def ds_data_node ds_data
        ds_data_node = create_node("dsData", nil)

        key_tag_node      = create_node("keyTag", ds_data[:key_tag])
        alg_node          = create_node("alg", ds_data[:alg])
        digest_type_node  = create_node("digestType", ds_data[:digest_type])
        digest_node       = create_node("digest", ds_data[:digest])

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
        key_tag_node  = create_node("keyData", nil)

        flags_node    = create_node("flags", key_data[:flags])
        protocol_node = create_node("protocol", key_data[:protocol])
        alg_type_node = create_node("alg", key_data[:alg])
        pub_key_node  = create_node("pubKey", key_data[:pubKey])

        key_tag_node << flags_node
        key_tag_node << protocol_node
        key_tag_node << alg_type_node
        key_tag_node << pub_key_node

        key_tag_node
      end
    end
  end
end