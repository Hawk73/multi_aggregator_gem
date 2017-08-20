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

    def call(query_spec, storage, providers = {})
      query_spec.each do |provider_id, tables_spec|
        transfer_tables(storage, providers[provider_id], provider_id, tables_spec)
      end
    end

    private

    def transfer_tables(storage, provider, db_name, tables_spec)
      tables_spec.each do |table, fields|
        transfer_table(storage, provider, db_name, table, fields)
      end
    end

    # TODO: transfer by batches
    def transfer_table(storage, provider, db_name, table, fields)
      rows = provider.fetch(db_name, table, fields)
      storage.push(db_name, table, rows)
    end
  end
end
