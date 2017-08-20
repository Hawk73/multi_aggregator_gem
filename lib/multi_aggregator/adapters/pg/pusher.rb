# frozen_string_literal: true

require 'pg'

module MultiAggregator
  module Adapters
    module Pg
      class Pusher
        LOG_EXEC_QUERY_LIMIT = 100

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

        def call(db_name, table, rows)
          connection = ::PG.connect(params.merge(dbname: db_name))
          query = insert_data_query(table, rows)
          logger.info("Exec (first #{LOG_EXEC_QUERY_LIMIT}): #{query[0...LOG_EXEC_QUERY_LIMIT]}")
          connection.exec(query)
        rescue ::PG::ConnectionBad => error
          logger.log_error(error)
          raise(MultiAggregator::Adapters::NoConnectionError, error.message)
        ensure
          connection&.finish
        end

        private

        def insert_data_query(table, rows)
          columns = rows.first.keys
          query = "INSERT INTO #{table}(#{columns.join(',')}) VALUES "
          rows[0...-1].each do |row|
            query += "(#{values_string(row)}),"
          end
          query + "(#{values_string(rows.last)});"
        end

        # TODO: escape values
        def values_string(row)
          values = escaped_values(row.values)
          "'#{values.join("','")}'"
        end

        def escaped_values(values)
          values.map do |value|
            # TODO: remove "to_s" if it will need
            value.to_s.tr("'", "\'")
          end
        end
      end
    end
  end
end
