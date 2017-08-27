# frozen_string_literal: true

module MultiAggregator
  class Config
    class << self
      attr_accessor :enable_threads
      attr_accessor :copy_batch_size
    end
  end
end
