# frozen_string_literal: true

RSpec.describe MultiAggregator::Adapters::Pg::Pusher do
  def call
    subject.call(db_name, table, rows)
  end

  def expect_exec_query(query, fake_connection, result = true)
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
  let(:rows) do
    [
      {
        'field_a' => 'one',
        'id' => 1
      },
      {
        'field_a' => 'two',
        'id' => 2
      }
    ]
  end

  subject { described_class.new(params) }

  context 'connection is good' do
    let(:fake_connection) { create_fake_connection }
    let(:insert_query) do
      'INSERT INTO table_a(field_a,id) ' \
      'VALUES ' \
      "('one','1')," \
      "('two','2');"
    end

    before { stub_pg_connection(fake_connection) }

    it 'execs "INSERT" query' do
      expect(fake_connection).to receive(:exec).with(insert_query)
      call
    end

    it 'closes connection' do
      expect(fake_connection).to receive(:finish)
      call
    end

    context 'value contains quotes' do
      let(:rows) do
        [
          {
            'field_a' => "it's with '",
            'id' => '1'
          }
        ]
      end
      let(:insert_query) do
        'INSERT INTO table_a(field_a,id) ' \
        'VALUES ' \
        "('it\'s with \'','1');"
      end

      it 'escapes quotes' do
        expect(fake_connection).to receive(:exec).with(insert_query)
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
