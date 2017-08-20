# frozen_string_literal: true

RSpec.describe MultiAggregator do
  it 'has a version number' do
    expect(MultiAggregator::VERSION).not_to be nil
  end

  context 'example from readme' do
    let(:expected_result) do
      [
        { 'id' => '1', 'name' => 'Tom', 'type' => 'cat' },
        { 'id' => '2', 'name' => 'Jerry', 'type' => 'mouse' }
      ]
    end

    it 'runs without errors' do
      params_a = { dbname: 'db_a' }
      provider_a = MultiAggregator::Adapters::Adapter.create_pg_adapter(params_a)
      provider_a.check_connections

      params_b = { dbname: 'db_b' }
      provider_b = MultiAggregator::Adapters::Adapter.create_pg_adapter(params_b)
      provider_b.check_connections

      providers = {
        'db_a' => provider_a,
        'db_b' => provider_b
      }

      storage_params = { dbname: 'storage' }
      storage = MultiAggregator::Adapters::Adapter.create_pg_adapter(storage_params)
      storage.check_connections

      query = <<-SQL
        SELECT db_a.users.id, db_a.users.name, db_b.types.type
        FROM db_a.users
        LEFT JOIN db_b.types ON (db_b.types.id = db_a.users.id);
      SQL

      expect(MultiAggregator::Processor.new.call(query, storage, providers)).to eq(expected_result)
    end
  end
end
