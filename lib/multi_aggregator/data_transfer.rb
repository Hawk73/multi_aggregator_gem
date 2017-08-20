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
      tables_spec.each do |table, columns_spec|
        transfer_table(storage, provider, db_name, table, columns_spec)
      end
    end

    # TODO: transfer by batches
    def transfer_table(storage, provider, db_name, table, columns_spec)
      columns = columns_spec.keys
      rows = provider.fetch(table, columns)

      uid = generate_uid
      # TODO: create better solution for uniq tables names
      storage.uid = uid
      target_table = target_table_for(db_name, table, uid)
      storage.create_structure(target_table, columns_spec)

      storage.push(target_table, rows)
    end

    def generate_uid
      "t#{Time.now.to_i}"
    end

    def target_table_for(src_db_name, src_table, uid)
      "#{uid}__#{src_db_name}__#{src_table}"
    end
  end
end
