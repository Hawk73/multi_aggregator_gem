# frozen_string_literal: true

module MultiAggregator
  module Query
    class FieldsFinder
      BaseError = Class.new(StandardError)

      NoTableError = Class.new(BaseError)

      FROM_TABLES_REGEX = /[^\.\w]from\s*([\w.]*)/i
      JOIN_TABLES_REGEX = /[^\.\w]join\s*([\w.]*)/i

      def call(text)
        providers_with_tables = find_providers_with_tables!(text)

        find_attributes(providers_with_tables, text)
      end

      private

      def find_providers_with_tables!(text)
        providers_with_tables = from_tables(text) + join_tables(text)
        raise NoTableError if providers_with_tables.empty?
        providers_with_tables.uniq
      end

      def from_tables(text)
        text.scan(FROM_TABLES_REGEX).flatten
      end

      def join_tables(text)
        text.scan(JOIN_TABLES_REGEX).flatten
      end

      def find_attributes(providers_with_tables, text)
        attributes = {}
        providers_with_tables.each do |provider_with_table|
          provider, table = provider_with_table.split('.')
          attributes[provider] ||= {}
          attributes[provider][table] ||= []

          regex = attributes_regex(provider, table)

          attributes[provider][table] = (attributes[provider][table] + text.scan(regex).flatten).uniq
        end
        attributes
      end

      def attributes_regex(provider, table)
        /#{provider}\.#{table}\.([\w_]+)/i
      end
    end
  end
end
