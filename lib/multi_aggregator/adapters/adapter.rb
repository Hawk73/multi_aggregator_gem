# frozen_string_literal: true

module MultiAggregator
  module Adapters
    class Adapter
      include ::MultiAggregator::ClassHelper

      HIVE_TYPE = :hive
      PG_TYPE = :pg
      REDSHIFT_TYPE = :redshift

      TYPES = [
        HIVE_TYPE,
        PG_TYPE,
        REDSHIFT_TYPE
      ].freeze

      TYPES.each do |type|
        define_singleton_method("create_#{type}_adapter") do |params|
          new(type, params)
        end
      end

      attr_accessor(
        :params
      )
      attr_reader(
        :type
      )

      def initialize(type, params = {})
        @params = params
        @type = type
      end

      def [](key)
        params[key]
      end

      def connection_checker
        connection_checker_class.new(params)
      end

      def query_executor
        query_executor_class.new(params)
      end

      def to_s
        "#{type} adapter with params:#{params.inspect}"
      end

      private

      def connection_checker_class
        class_from_string("MultiAggregator::Adapters::#{type.capitalize}::ConnectionChecker")
      end

      def query_executor_class
        class_from_string("MultiAggregator::Adapters::#{type.capitalize}::QueryExecutor")
      end
    end
  end
end
