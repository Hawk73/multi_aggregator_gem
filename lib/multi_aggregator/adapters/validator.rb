# frozen_string_literal: true

module MultiAggregator
  module Adapters
    class Validator
      Error = Class.new(::MultiAggregator::Error)

      def call(adapter)
        check_connections!(adapter)
      end

      private

      def check_connections!(adapter)
        adapter.connection_checker.call
      end
    end
  end
end
