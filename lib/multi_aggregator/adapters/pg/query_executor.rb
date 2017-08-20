# frozen_string_literal: true

require 'pg'

module MultiAggregator
  module Adapters
    module Pg
      class QueryExecutor
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

        def call(raw_query, query_spec)
          connection = ::PG.connect(params)
          query = adapted_query(raw_query, query_spec)
          connection.exec(query).to_a
        rescue ::PG::ConnectionBad => error
          logger.log_error(error)
          raise(MultiAggregator::Adapters::NoConnectionError, error.message)
        ensure
          connection&.finish
        end

        private

        def adapted_query(raw_query, query_spec)
          query = raw_query
          query_spec.each do |provider, tables|
            tables.each_key do |table|
              query = query.gsub("#{provider}.#{table}", "#{provider}_#{table}")
            end
          end
          query
        end
      end
    end
  end
end
