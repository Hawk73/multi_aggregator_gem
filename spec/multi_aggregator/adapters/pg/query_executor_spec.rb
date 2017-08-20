# frozen_string_literal: true

RSpec.describe MultiAggregator::Adapters::Pg::QueryExecutor do
  def call
    subject.call(raw_query, query_spec)
  end

  let(:params) do
    {
      host: 'host',
      user: 'pg'
    }
  end

  let(:raw_query) { generate_query }
  let(:query_spec) { generate_query_spec }

  let(:pg_query) { generate_pg_query }

  subject { described_class.new(params) }

  context 'connection is good' do
    let(:fake_connection) { create_fake_connection }

    before { stub_pg_connection(fake_connection) }

    it 'execs query' do
      expect(fake_connection).to receive(:exec).with(pg_query)
      call
    end

    it 'closes connection' do
      expect(fake_connection).to receive(:finish)
      call
    end
  end

  context 'connection is bad' do
    before { stub_pg_connection_fail }

    it 'raises NoConnectionError' do
      expect { call }.to raise_error(MultiAggregator::Adapters::NoConnectionError)
    end
  end
end
