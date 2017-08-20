# frozen_string_literal: true

module MultiAggregator
  module Query
    class SpecCreator
      Error = Class.new(::MultiAggregator::Error)

      NoTableError = Class.new(Error)
      NoProviderError = Class.new(Error)

      FROM_TABLES_REGEX = /[^\.\w]from\s*([\w.]*)/i
      JOIN_TABLES_REGEX = /[^\.\w]join\s*([\w.]*)/i

      attr_reader(
        :provider_validator
      )
      def initialize(
        provider_validator: MultiAggregator::Adapters::Validator.new
      )
        @provider_validator = provider_validator
      end

      def call(query, providers)
        providers_with_tables = find_providers_with_tables!(query)

        query_spec = {}
        providers_with_tables.each do |provider_with_table|
          provider_id, table = provider_with_table.split('.')
          provider = retrieve_provider!(provider_id, providers)

          validate_provider!(provider)
          columns_with_types = provider.fetch_structure(table)

          columns = find_columns(provider_id, table, query)
          used_columns_with_types = columns_with_types.select do |key, _type|
            columns.include?(key)
          end

          query_spec[provider_id] ||= {}
          query_spec[provider_id][table] = used_columns_with_types
        end
        query_spec
      end

      private

      def find_providers_with_tables!(query)
        providers_with_tables = from_tables(query) + join_tables(query)
        raise NoTableError if providers_with_tables.empty?
        providers_with_tables.uniq
      end

      def from_tables(query)
        query.scan(FROM_TABLES_REGEX).flatten
      end

      def join_tables(query)
        query.scan(JOIN_TABLES_REGEX).flatten
      end

      def retrieve_provider!(provider_id, providers)
        provider = providers[provider_id]
        raise(NoProviderError, "You must specify \"#{provider_id}\" provider.") unless provider
        provider
      end

      def validate_provider!(provider)
        provider_validator.call(provider)
      end

      def find_columns(provider_id, table, query)
        regex = attributes_regex(provider_id, table)
        query.scan(regex).flatten.uniq
      end

      def attributes_regex(provider, table)
        /#{provider}\.#{table}\.([\w_]+)/i
      end
    end
  end
end
