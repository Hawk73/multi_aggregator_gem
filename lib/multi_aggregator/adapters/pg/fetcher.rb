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
          params = {},
          logger = MultiAggregator::Logger.new
        )
          @params = params
          @logger = logger
        end

        def call(table, columns, query_params = {})
          connection = ::PG.connect(params)
          query = select_data_query(table, columns, query_params)
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
        def select_data_query(table, columns, query_params = {})
          columns_string = columns.join(',')
          query = "SELECT #{columns_string} FROM #{table}"
          query += " LIMIT #{query_params[:limit]}" if query_params[:limit]&.positive?
          query += " OFFSET #{query_params[:offset]}" if query_params[:offset]&.positive?
          query + ';'
        end
      end
    end
  end
end
