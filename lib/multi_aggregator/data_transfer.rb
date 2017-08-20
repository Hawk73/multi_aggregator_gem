# frozen_string_literal: true

module MultiAggregator
  class DataTransfer
    attr_reader(
      :logger
    )

    def initialize(
      logger = MultiAggregator::Logger.new
    )
      @logger = logger
    end

    def call(spec, storage, providers)
      spec.each do |table, fields|
        transfer(adapter_connection, table, fields)
      end
    end

    private

    # TODO: transfer by batches
    def transfer(adapter_connection, table, fields)
      data = adapter.pull(adapter_connection, table, fields)
      importer.push(data)
    end
  #
  #   def create_table(connection, table)
  #
  #   end
  #
  #   def pull(connection, table, fields)
  #     sql_query = select_data_query(table, fields)
  #     logger.info("Exec: #{sql_query}")
  #     connection.exec(sql_query)
  #   end
  #
  #   def push(connection, table, data)
  #     rows.each do |row|
  #       logger.info(row)
  #     end
  #   end
  #
  #   # TODO: add placeholders
  #   def select_data_query(table, fields)
  #     fields_string = fields.join(',')
  #     "SELECT #{fields_string} FROM #{table}"
  #   end
  # end
  end
end
