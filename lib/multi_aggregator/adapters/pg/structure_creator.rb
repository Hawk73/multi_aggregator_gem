# frozen_string_literal: true

require 'pg'

module MultiAggregator
  module Adapters
    module Pg
      class StructureCreator
        attr_reader(
          :logger,
          :params
        )

        def initialize(
          params = {},
          logger = MultiAggregator::Logger.new
        )
          @params = params
          @logger = logger
        end

        def call(table, columns_spec)
          connection = ::PG.connect(params)
          query = create_table_query(table, columns_spec)
          logger.info("Exec: #{query}")
          connection.exec(query)
        rescue ::PG::ConnectionBad => error
          logger.log_error(error)
          raise(MultiAggregator::Adapters::NoConnectionError, error.message)
        ensure
          connection&.finish
        end

        private

        def create_table_query(table, columns_spec)
          query = "CREATE TABLE #{table} ("
          columns_spec.keys[0...-1].each do |column|
            query += "#{column_string(column, columns_spec[column])},"
          end
          column = columns_spec.keys.last
          query + "#{column_string(column, columns_spec[column])});"
        end

        def column_string(column, type)
          "#{column} #{type}"
        end
      end
    end
  end
end
