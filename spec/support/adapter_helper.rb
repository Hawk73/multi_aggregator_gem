# frozen_string_literal: true

module AdapterHelper
  def create_pg_adapter(params = {})
    MultiAggregator::Adapters::Adapter.create_pg_adapter(params)
  end
end
