# frozen_string_literal: true

module MultiAggregator
  class Processor
    Error = Class.new(::MultiAggregator::Error)

    attr_reader(
      :storage_validator,
      :data_transfer,
      :logger,
      :query_validator,
      :spec_creator
    )

    def initialize(
      storage_validator: MultiAggregator::Adapters::Validator.new,
      data_transfer: DataTransfer.new,
      logger: MultiAggregator::Logger.new,
      query_validator: Query::Validator.new,
      spec_creator: Query::SpecCreator.new
    )
      @storage_validator = storage_validator
      @data_transfer = data_transfer
      @logger = logger
      @query_validator = query_validator
      @spec_creator = spec_creator
    end

    def call(query, storage, providers = {})
      log_src_params(query, storage, providers)

      # TODO: move to MultiAggregator::Validator
      validate!(query, storage)

      query_spec = create_query_spec(query)

      transfer_data(query_spec, storage, providers)

      rows = storage.exec(query, query_spec)
      rows.each { |row| logger.debug(row) }
      rows
    end

    private

    def log_src_params(query, storage, providers)
      logger.debug "Query: '#{query}'"
      logger.debug "Storage: '#{storage}'"
      providers.each do |key, provider|
        logger.debug "#{key} provider: '#{provider}'"
      end
    end

    def validate!(query, storage)
      validate_query!(query)
      validate_storage!(storage)
    end

    def validate_query!(query)
      query_validator.call(query)
    end

    def validate_storage!(storage)
      storage_validator.call(storage)
    end

    def create_query_spec(query)
      spec_creator.call(query)
    end

    def transfer_data(query_spec, storage, providers)
      data_transfer.call(query_spec, storage, providers)
    end
  end
end
