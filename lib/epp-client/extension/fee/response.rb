module EPP
  module Extension
    module Fee
      class Response
        include ResponseHelper

        def initialize(response)
          @response = response
          @arg_namespace = if @response&.extension&.namespaces&.namespace&.to_s&.split(':').first.include?('fee')
                            @response&.extension&.namespaces&.namespace&.to_s&.split(':').drop(1).join(':')
                           else
                            @response&.extension&.namespaces&.namespace&.to_s || NAMESPACE
                           end
        end

        def method_missing(meth, *args, &block)
          return super unless @response.respond_to?(meth)
          @response.send(meth, *args, &block)
        end

        def respond_to_missing?(method, include_private)
          @response.respond_to?(method, include_private)
        end

        unless RUBY_VERSION >= "1.9.2"
          def respond_to?(method, include_private = false)
            respond_to_missing?(method, include_private) || super
          end
          def method(sym)
            respond_to_missing?(sym, true) ? @response.method(sym) : super
          end
        end

        protected
          def namespaces
            {"fee" => @arg_namespace}
          end
      end
    end
  end
end
