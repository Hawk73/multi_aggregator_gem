# frozen_string_literal: true

module MultiAggregator
  # TODO: rename to "copy"
  class DataTransfer
    attr_reader(
      :config,
      :logger
    )

    def initialize(
      config = MultiAggregator::Config,
      logger = MultiAggregator::Logger.new
    )
      @config = config
      @logger = logger
    end

    def call(query_spec, storage, providers = {})
      if config.enable_threads
        call_async(query_spec, storage, providers)
      else
        call_sync(query_spec, storage, providers)
      end
    end

    private

    def call_async(query_spec, storage, providers)
      threads = []
      query_spec.each do |provider_id, tables_spec|
        threads << Thread.new(storage, providers[provider_id], provider_id, tables_spec) do |*args|
          transfer_tables(*args)
        end
      end
      threads.each(&:join)
    end

    def call_sync(query_spec, storage, providers)
      query_spec.each do |provider_id, tables_spec|
        transfer_tables(storage, providers[provider_id], provider_id, tables_spec)
      end
    end

    def transfer_tables(storage, provider, db_name, tables_spec)
      tables_spec.each do |table, columns_spec|
        transfer_table(storage, provider, db_name, table, columns_spec)
      end
    end

    def transfer_table(storage, provider, db_name, table, columns_spec)
      target_table = target_table_for(db_name, table, storage.uid)
      storage.create_structure(target_table, columns_spec)

      columns = columns_spec.keys

      offset = 0
      while (rows = provider.fetch(table, columns, limit: copy_batch_size, offset: offset)).any?
        storage.push(target_table, rows)
        break if copy_batch_size.zero?
        offset += copy_batch_size
      end
    end

    def target_table_for(src_db_name, src_table, uid)
      "#{uid}__#{src_db_name}__#{src_table}"
    end

    def copy_batch_size
      config.copy_batch_size.to_i
    end
  end
end
