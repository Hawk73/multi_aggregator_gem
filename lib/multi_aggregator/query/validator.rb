# frozen_string_literal: true

module MultiAggregator
  module Query
    class Validator
      BaseError = Class.new(StandardError)

      EmptyQueryError = Class.new(BaseError)

      # TODO: add additional validations
      def call(query)
        validate_presence!(query)
        true
      end

      private

      def validate_presence!(query)
        return if presence?(query)
        raise EmptyQueryError
      end

      def presence?(query)
        query && query != ''
      end
    end
  end
end
