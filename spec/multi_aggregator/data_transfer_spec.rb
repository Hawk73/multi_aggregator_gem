# frozen_string_literal: true

RSpec.describe MultiAggregator::DataTransfer do
  def call
    subject.call(query_spec, storage, providers)
  end

  def allow_fetch(provider, result = [])
    allow(provider).to receive(:fetch).and_return(result)
  end

  def expect_fetch(provider, table, *columns)
    expect(provider).to receive(:fetch).with(table, columns).and_return([])
  end

  def allow_create_structure
    allow(storage).to receive(:create_structure)
  end

  def allow_push
    allow(storage).to receive(:push)
  end

  def expect_push(table, rows)
    expect(storage).to receive(:push).with(table, rows)
  end

  let(:storage) { create_pg_adapter }
  let(:providers) do
    {
      'db_a' => create_pg_adapter(host: 'host_for_db_a'),
      'db_b' => create_pg_adapter(host: 'host_for_db_b')
    }
  end
  let(:query_spec) { generate_query_spec }

  let(:fetched_rows_a) do
    [
      { 'field_a' => 'one a', 'id' => 1 },
      { 'field_a' => 'two a', 'id' => 2 }
    ]
  end
  let(:fetched_rows_b) do
    [
      { 'field_b' => 'one b', 'id' => 1 },
      { 'field_b' => 'two b', 'id' => 2 }
    ]
  end

  before do
    storage.uid = 't123'
    allow_fetch(providers['db_a'], fetched_rows_a)
    allow_fetch(providers['db_b'], fetched_rows_b)
    allow_create_structure
    allow_push
  end

  it 'runs without errors' do
    call
  end

  it 'fetches data' do
    expect_fetch(providers['db_a'], 'table_a', 'field_a', 'id')
    expect_fetch(providers['db_b'], 'table_b', 'id', 'field_b')

    call
  end

  it 'pushes data' do
    expect_push('t123__db_a__table_a', fetched_rows_a)
    expect_push('t123__db_b__table_b', fetched_rows_b)

    call
  end
end
