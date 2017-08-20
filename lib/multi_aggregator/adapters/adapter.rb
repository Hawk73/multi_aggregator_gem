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

      COMPONENTS = %i[
        connection_checker
        fetcher
        pusher
        query_executor
      ].freeze

      TYPES.each do |type|
        define_singleton_method("create_#{type}_adapter") do |params|
          new(type, params)
        end
      end

      COMPONENTS.each do |component|
        define_method(component) do
          component_class(component).new(params)
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

      def to_s
        "#{type} adapter with params:#{params.inspect}"
      end

      def fetch(db_name, table, fields)
        fetcher.call(db_name, table, fields)
      end

      def push(db_name, table, rows)
        pusher.call(db_name, table, rows)
      end

      def exec(raw_query, query_spec)
        query_executor.call(raw_query, query_spec)
      end

      private

      def component_class(component)
        class_from_string("MultiAggregator::Adapters::#{type.capitalize}::#{camelize(component)}")
      end
    end
  end
end
