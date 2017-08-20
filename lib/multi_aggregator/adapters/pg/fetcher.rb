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

        def call(db_name, table, fields)
          connection = ::PG.connect(params.merge(dbname: db_name))

          query = select_data_query(table, fields)
          logger.info("Exec: #{query}")
          connection.exec(query)
        rescue ::PG::ConnectionBad => error
          logger.log_error(error)
          raise(MultiAggregator::Adapters::NoConnectionError, error.message)
        ensure
          connection&.finish
        end

        private

        # TODO: add placeholders
        def select_data_query(table, fields)
          fields_string = fields.join(',')
          "SELECT #{fields_string} FROM #{table};"
        end
      end
    end
  end
end
