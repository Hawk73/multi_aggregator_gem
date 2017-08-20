# frozen_string_literal: true

RSpec.describe MultiAggregator::Adapters::Pg::Fetcher do
  def call
    subject.call(db_name, table, fields)
  end

  def expect_exec_query(query, fake_connection, result = [])
    expect(fake_connection).to receive(:exec).with(query).and_return(result)
  end

  let(:params) do
    {
      host: 'host',
      user: 'postgres'
    }
  end
  let(:db_name) { 'db_a' }
  let(:table) { 'table_a' }
  let(:fields) do
    %w[
      field_a
      id
    ]
  end

  subject { described_class.new(params) }

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
  end

  context 'connection is bad' do
    before { stub_pg_connection_fail }

    it 'raises NoConnectionError' do
      expect { call }.to raise_error(MultiAggregator::Adapters::NoConnectionError)
    end
  end
end
