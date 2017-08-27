# frozen_string_literal: true

require 'pg'

module MultiAggregator
  module Adapters
    module Pg
      class ConnectionChecker
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

        def call
          connection = ::PG.connect(params)
          true
        rescue ::PG::ConnectionBad => error
          logger.log_warn(error)
          raise(MultiAggregator::Adapters::NoConnectionError, error.message)
        ensure
          connection&.finish
        end
      end
    end
  end
end
