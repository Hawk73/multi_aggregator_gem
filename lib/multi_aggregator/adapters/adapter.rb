# frozen_string_literal: true

module MultiAggregator
  module Adapters
    # TODO: add db_name in params because adapter can contain more than one DB
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
        structure_creator
        structure_fetcher
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
        :params,
        :uid
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

      def check_connections
        connection_checker.call
      end

      def fetch_structure(table)
        structure_fetcher.call(table)
      end

      def fetch(table, columns)
        fetcher.call(table, columns)
      end

      def create_structure(table, columns_spec)
        structure_creator.call(table, columns_spec)
      end

      def push(table, rows)
        pusher.call(table, rows)
      end

      def exec(raw_query, query_spec)
        query_executor.call(raw_query, query_spec, uid)
      end

      private

      def component_class(component)
        class_from_string("MultiAggregator::Adapters::#{type.capitalize}::#{camelize(component)}")
      end
    end
  end
end
