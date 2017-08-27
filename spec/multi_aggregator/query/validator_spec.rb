# frozen_string_literal: true

RSpec.describe MultiAggregator::Query::Validator do
  def call
    subject.call(query)
  end

  context 'query is valid' do
    let(:query) { generate_query }

    it 'returns true' do
      expect(call).to be_truthy
    end
  end

  context 'query is empty' do
    let(:query) { '' }

    it 'raises error' do
      expect { call }.to raise_error(described_class::EmptyQueryError)
    end
  end
end
