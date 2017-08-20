# frozen_string_literal: true

RSpec.describe MultiAggregator::Query::SpecCreator do
  let(:query) { generate_query }

  def call
    subject.call(query)
  end

  context 'adapters exist' do
    let(:query_spec) { generate_query_spec }

    it 'returns request attributes' do
      expect(call).to eq(query_spec)
    end

    # TODO: add specs
    context 'two "FROM"' do
    end

    context 'two "JOIN"' do
    end
  end
end
