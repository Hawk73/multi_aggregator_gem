# frozen_string_literal: true

RSpec.describe MultiAggregator::Adapters::Adapter do
  let(:params) { { a: 1 } }

  describe '.create_pg_adapter' do
    subject { described_class.create_pg_adapter(params) }

    it 'creates PG adapter' do
      expect(subject.type).to eq(described_class::PG_TYPE)
    end
  end

  describe '#connection_checker' do
    context 'PG type' do
      subject { described_class.create_pg_adapter(params) }

      it 'returns instance of Pg::ConnectionChecker' do
        expect(subject.connection_checker.class).to eq(MultiAggregator::Adapters::Pg::ConnectionChecker)
      end
    end
  end

  describe '#[]' do
    subject { described_class.create_pg_adapter(params) }

    it 'returns value from params' do
      expect(subject[:a]).to eq(1)
    end
  end
end
