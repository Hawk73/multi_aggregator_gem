# frozen_string_literal: true

RSpec.describe MultiAggregator::Adapters::Validator do
  def call
    subject.call(adapter)
  end

  let(:adapter) { create_pg_adapter }

  before { stub_pg_connection }

  context 'adapter is valid' do
    it 'returns true' do
      expect(call).to be_truthy
    end
  end

  context 'connections is bad' do
    before { stub_pg_connection_fail }

    it 'raises NoConnectionError' do
      expect { call }.to raise_error(MultiAggregator::Adapters::NoConnectionError)
    end
  end
end
