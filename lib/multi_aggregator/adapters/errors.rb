# frozen_string_literal: true

module MultiAggregator
  module Adapters
    class Error < MultiAggregator::Error
    end

    NoConnectionError = Class.new(Error)
  end
end
