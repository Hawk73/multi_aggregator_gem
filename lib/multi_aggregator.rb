# frozen_string_literal: true

require 'multi_aggregator/config'
require 'multi_aggregator/data_transfer'
require 'multi_aggregator/error'
require 'multi_aggregator/logger'
require 'multi_aggregator/processor'
require 'multi_aggregator/version'

require 'multi_aggregator/helpers/class_helper'

require 'multi_aggregator/adapters/adapter'
require 'multi_aggregator/adapters/errors'
require 'multi_aggregator/adapters/validator'

require 'multi_aggregator/adapters/pg/connection_checker'
require 'multi_aggregator/adapters/pg/fetcher'
require 'multi_aggregator/adapters/pg/pusher'
require 'multi_aggregator/adapters/pg/query_executor'
require 'multi_aggregator/adapters/pg/structure_creator'
require 'multi_aggregator/adapters/pg/structure_fetcher'

require 'multi_aggregator/query/spec_creator'
require 'multi_aggregator/query/query'
require 'multi_aggregator/query/validator'

module MultiAggregator
  # TODO: add ability to set global logger and remove logger from dependency
end
