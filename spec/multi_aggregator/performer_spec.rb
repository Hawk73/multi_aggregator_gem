# frozen_string_literal: true

RSpec.describe MultiAggregator::Performer do
  def call
    subject.call(query, storage, providers)
  end

  def stub_spec_creator
    allow(subject.spec_creator).to receive(:call).with(query).and_return(query_spec)
  end

  let(:query) { generate_query }
  let(:storage) { create_pg_adapter }
  let(:providers) do
    {
      'db_a' => create_pg_adapter,
      'db_b' => create_pg_adapter
    }
  end
  let(:query_spec) { generate_query_spec }

  before do
    stub_spec_creator
    stub_pg_fetch
    stub_pg_push
    stub_pg_query_exec
  end

  it 'runs without errors' do
    call
  end

  it 'calls query_validator' do
    expect(subject.query_validator).to receive(:call).with(query)
    call
  end

  it 'validates storage and providers' do
    expect(subject.adapter_validator).to receive(:call).with(storage)
    providers.each do |_key, provider|
      expect(subject.adapter_validator).to receive(:call).with(provider)
    end

    call
  end

  it 'calls spec_creator' do
    expect(subject.spec_creator).to receive(:call).with(query).and_return(query_spec)
    call
  end

  context 'without required adapter' do
    let(:providers) do
      {
        'db_a' => create_pg_adapter,
        'unused_db' => create_pg_adapter
      }
    end

    it 'raises NoAdapterError' do
      expect { call }.to raise_error(described_class::NoAdapterError)
    end
  end
end
