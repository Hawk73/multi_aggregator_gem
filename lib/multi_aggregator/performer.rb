# frozen_string_literal: true

module MultiAggregator
  # TODO: rename
  class Performer
    Error = Class.new(::MultiAggregator::Error)

    NoAdapterError = Class.new(Error)

    attr_reader(
      :adapter_validator,
      :data_transfer,
      :logger,
      :query_validator,
      :spec_creator
    )

    def initialize(
      adapter_validator: MultiAggregator::Adapters::Validator.new,
      data_transfer: DataTransfer.new,
      logger: MultiAggregator::Logger.new,
      query_validator: Query::Validator.new,
      spec_creator: Query::SpecCreator.new
    )
      @adapter_validator = adapter_validator
      @data_transfer = data_transfer
      @logger = logger
      @query_validator = query_validator
      @spec_creator = spec_creator
    end

    def call(query, storage, providers = {})
      log_debug_info(query, storage, providers)

      validate!(query, storage)

      query_spec = create_query_spec(query)
      providers = filter_providers(providers, query_spec)
      validate_providers!(providers, query_spec)

      rows = storage.query_executor.call(query, query_spec)
      rows.each { |row| logger.debug(row) }
      rows
    end

    private

    def log_debug_info(query, storage, providers)
      logger.debug "Query: '#{query}'"
      logger.debug "Storage: '#{storage}'"
      providers.each do |key, provider|
        logger.debug "#{key} provider: '#{provider}'"
      end
    end

    def validate!(query, storage)
      validate_query!(query)
      validate_adapter!(storage)
    end

    def validate_query!(query)
      query_validator.call(query)
    end

    def validate_adapter!(adapter)
      adapter_validator.call(adapter)
    end

    def filter_providers(providers, query_spec)
      # TODO: add helper SpecQuery.provider_ids
      provider_ids = query_spec.keys
      providers.select do |key, _provider|
        provider_ids.include?(key)
      end
    end

    def validate_providers!(providers, query_spec)
      ensure_required_providers!(providers, query_spec)

      providers.each do |_key, provider|
        validate_adapter!(provider)
      end
    end

    def create_query_spec(query)
      spec_creator.call(query)
    end

    def ensure_required_providers!(providers, query_spec)
      missing_provider_ids = retrieve_missing_provider_ids(query_spec.keys, providers)
      return if missing_provider_ids.empty?
      raise(NoAdapterError, "You must specify provider(s) for #{missing_provider_ids.join(',')}.")
    end

    def retrieve_missing_provider_ids(provider_ids, providers)
      provider_ids - providers.keys
    end
  end
end
