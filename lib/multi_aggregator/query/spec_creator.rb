# frozen_string_literal: true

module MultiAggregator
  module Query
    class SpecCreator
      Error = Class.new(::MultiAggregator::Error)

      NoTableError = Class.new(Error)

      FROM_TABLES_REGEX = /[^\.\w]from\s*([\w.]*)/i
      JOIN_TABLES_REGEX = /[^\.\w]join\s*([\w.]*)/i

      def call(text)
        adapters_with_tables = find_adapters_with_tables!(text)

        find_attributes(adapters_with_tables, text)
      end

      private

      def find_adapters_with_tables!(text)
        adapters_with_tables = from_tables(text) + join_tables(text)
        raise NoTableError if adapters_with_tables.empty?
        adapters_with_tables.uniq
      end

      def from_tables(text)
        text.scan(FROM_TABLES_REGEX).flatten
      end

      def join_tables(text)
        text.scan(JOIN_TABLES_REGEX).flatten
      end

      def find_attributes(adapters_with_tables, text)
        attributes = {}
        adapters_with_tables.each do |adapter_with_table|
          adapter, table = adapter_with_table.split('.')
          attributes[adapter] ||= {}
          attributes[adapter][table] ||= []

          regex = attributes_regex(adapter, table)

          attributes[adapter][table] = (attributes[adapter][table] + text.scan(regex).flatten).uniq
        end
        attributes
      end

      def attributes_regex(adapter, table)
        /#{adapter}\.#{table}\.([\w_]+)/i
      end
    end
  end
end
