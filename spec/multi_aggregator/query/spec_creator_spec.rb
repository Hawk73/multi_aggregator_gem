# frozen_string_literal: true

RSpec.describe MultiAggregator::Query::SpecCreator do
  def call
    subject.call(query, providers)
  end

  def stub_fetch_structure(provider, result)
    allow(provider).to receive(:fetch_structure).and_return(result)
  end

  def expect_fetch_structure(provider, table)
    expect(provider).to receive(:fetch_structure).with(table)
  end

  let(:query) { generate_query }
  let(:providers) do
    {
      'db_a' => create_pg_adapter(host: 'host_for_db_a'),
      'db_b' => create_pg_adapter(host: 'host_for_db_b')
    }
  end

  let(:query_spec) { generate_query_spec }
  let(:fetched_structure_a) do
    {
      'field_a' => 'character varying',
      'id' => 'integer'
    }
  end
  let(:fetched_structure_b) do
    {
      'id' => 'integer',
      'field_b' => 'character varying'
    }
  end

  before do
    stub_pg_check_connection
    stub_fetch_structure(providers['db_a'], fetched_structure_a)
    stub_fetch_structure(providers['db_b'], fetched_structure_b)
  end

  it 'returns spec' do
    expect(call).to eq(query_spec)
  end

  it 'fetches structures' do
    expect_fetch_structure(providers['db_a'], 'table_a')
    expect_fetch_structure(providers['db_b'], 'table_b')

    call
  end

  # TODO: add specs
  context 'two "FROM"' do
  end

  context 'two "JOIN"' do
  end

  context 'adapters do not exist' do
    let(:providers) do
      {
        'db_a_wrong' => create_pg_adapter(host: 'host_for_db_a'),
        'db_b' => create_pg_adapter(host: 'host_for_db_b')
      }
    end

    it 'raises NoProviderError' do
      expect { call }.to raise_error(described_class::NoProviderError)
    end
  end
end
