# frozen_string_literal: true

module MultiAggregator
  class Config
    class << self
      attr_accessor :enable_threads
      attr_accessor :copy_batch_size
      attr_accessor :debug

      def debug?
        !debug.nil?
      end
    end
  end
end
