module Shoulda
  module Matchers
    module Independent
      def delegate_method(method)
        require 'mocha'
        DelegateMatcher.new(method)
      rescue LoadError
        raise "To use Shoulda's #delegate_method matcher, please add `mocha` to your Gemfile."
      end

      class DelegateMatcher
        def initialize(method)
          @method = method
          @options = {}
        end

        def to(object)
          @options[:to] = object
          self
        end

        def matches?(subject)
          unless @options.key?(:to)
            raise TargetNotDefined
          end

          begin
            extend Mocha::API
            stubbed_object = stub
            stubbed_object.stubs(@method).returns('Stubbed Value')

            subject.stubs(@options[:to]).returns(stubbed_object)
            subject.send(@method) == 'Stubbed Value'
          rescue NoMethodError
            false
          end
        end

        def failure_message
          "Expected to delegate ##{@method} to ##{@options[:to]}, but did not delegate."
        end

        def negative_failure_message
          "Expected not to delegate ##{@method}."
        end

        class TargetNotDefined < StandardError
          def message
            "Delegation needs a target. Use the #to method to define one, e.g. `post_office.should delegate(:deliver_mail).to(:mailman)`"
          end
        end
      end
    end
  end
end

