# frozen_string_literal: true

require 'pg'

module MultiAggregator
  module Adapters
    module Pg
      class Fetcher
        attr_reader(
          :logger,
          :params
        )

        def initialize(
          params,
          logger = MultiAggregator::Logger.new
        )
          @params = params
          @logger = logger
        end

        def call(table, columns)
          connection = ::PG.connect(params)
          query = select_data_query(table, columns)
          logger.info("Exec: #{query}")
          connection.exec(query).to_a
        rescue ::PG::ConnectionBad => error
          logger.log_error(error)
          raise(MultiAggregator::Adapters::NoConnectionError, error.message)
        ensure
          connection&.finish
        end

        private

        # TODO: add placeholders
        def select_data_query(table, columns)
          columns_string = columns.join(',')
          "SELECT #{columns_string} FROM #{table};"
        end
      end
    end
  end
end
