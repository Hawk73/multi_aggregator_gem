# frozen_string_literal: true

require 'pg'

module MultiAggregator
  module Adapters
    module Pg
      class StructureFetcher
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

        def call(table)
          connection = ::PG.connect(params)
          query = select_schema_query(table)
          logger.info("Exec: #{query}")
          rows = connection.exec(query)
          rows.map do |row|
            [row['column_name'], row['data_type']]
          end.to_h
        rescue ::PG::ConnectionBad => error
          logger.log_error(error)
          raise(MultiAggregator::Adapters::NoConnectionError, error.message)
        ensure
          connection&.finish
        end

        private

        def select_schema_query(table)
          'SELECT column_name, data_type FROM information_schema.columns ' \
          "WHERE table_name = '#{table}';"
        end
      end
    end
  end
end
