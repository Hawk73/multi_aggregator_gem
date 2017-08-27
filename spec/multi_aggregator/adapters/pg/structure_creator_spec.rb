# frozen_string_literal: true

RSpec.describe MultiAggregator::Adapters::Pg::StructureCreator do
  def call
    subject.call(table, columns_spec)
  end

  let(:table) { 'db_a__table_a' }
  let(:columns_spec) do
    {
      'field_a' => 'character varying',
      'id' => 'integer'
    }
  end

  context 'connection is good' do
    let(:fake_connection) { create_fake_connection }
    let(:create_table_query) do
      'CREATE TABLE db_a__table_a (' \
      'field_a character varying,' \
      'id integer' \
      ');'
    end

    before { stub_pg_connection(fake_connection) }

    it 'execs "CREATE TABLE" query' do
      expect(fake_connection).to receive(:exec).with(create_table_query)
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
