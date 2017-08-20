# frozen_string_literal: true

RSpec.describe MultiAggregator::Adapters::Pg::StructureFetcher do
  def call
    subject.call(table)
  end

  let(:table) { 'table_a' }

  context 'connection is good' do
    let(:fake_connection) { create_fake_connection }
    let(:select_schema_query) do
      "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'table_a';"
    end
    let(:rows) do
      [
        { 'column_name' => 'id', 'data_type' => 'integer' },
        { 'column_name' => 'field_a', 'data_type' => 'character varying' }
      ]
    end
    let(:columns_with_types) do
      {
        'id' => 'integer',
        'field_a' => 'character varying'
      }
    end

    before do
      stub_pg_connection(fake_connection)
      allow(fake_connection).to receive(:exec).and_return(rows)
    end

    it 'execs "SELECT" query' do
      expect(fake_connection).to receive(:exec).with(select_schema_query).and_return([])
      call
    end

    it 'returns columns with types' do
      expect(call).to eq(columns_with_types)
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
