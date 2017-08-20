# frozen_string_literal: true

RSpec.describe MultiAggregator::Adapters::Pg::ConnectionChecker do
  def call
    subject.call(db_name)
  end

  let(:params) do
    {
      host: 'host',
      user: 'pg'
    }
  end

  subject { described_class.new(params) }

  context 'db_name is nil' do
    let(:db_name) { nil }

    context 'connection is good' do
      before { stub_pg_connection }

      it 'returns true' do
        expect(call).to be_truthy
      end
    end

    context 'connection is bad' do
      before { stub_pg_connection_fail }

      it 'raises NoConnectionError' do
        expect { call }.to raise_error(MultiAggregator::Adapters::NoConnectionError)
      end
    end
  end
end
