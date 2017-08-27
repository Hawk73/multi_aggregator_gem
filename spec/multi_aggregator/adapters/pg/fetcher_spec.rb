# frozen_string_literal: true

RSpec.describe MultiAggregator::Adapters::Pg::Fetcher do
  def call
    subject.call(table, columns, query_params)
  end

  let(:table) { 'table_a' }
  let(:columns) do
    %w[
      field_a
      id
    ]
  end
  let(:query_params) { {} }

  subject { described_class.new }

  context 'connection is good' do
    let(:fake_connection) { create_fake_connection }
    let(:select_query) { 'SELECT field_a,id FROM table_a;' }

    before { stub_pg_connection(fake_connection) }

    it 'execs "SELECT" query' do
      expect(fake_connection).to receive(:exec).with(select_query)
      call
    end

    it 'closes connection' do
      expect(fake_connection).to receive(:finish)
      call
    end

    context 'with limit and offset' do
      let(:query_params) do
        {
          limit: 10,
          offset: 20
        }
      end
      let(:select_query) { 'SELECT field_a,id FROM table_a LIMIT 10 OFFSET 20;' }

      it 'execs limited query' do
        expect(fake_connection).to receive(:exec).with(select_query)
        call
      end
    end
  end

  context 'connection is bad' do
    before { stub_pg_connection_fail }

    it 'raises NoConnectionError' do
      expect { call }.to raise_error(MultiAggregator::Adapters::NoConnectionError)
    end
  end
end
