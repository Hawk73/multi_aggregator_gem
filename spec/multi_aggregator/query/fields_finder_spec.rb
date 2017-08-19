# frozen_string_literal: true

RSpec.describe MultiAggregator::Query::FieldsFinder do
  let(:query) { QueryGenerator.call }

  def call
    subject.call(query)
  end

  context 'providers exist' do
    let(:request_attributes) do
      {
        'db_a' => {
          'table_a' => %w[
            field_a
            id
          ]
        },
        'db_b' => {
          'table_b' => %w[
            id
            field_b
          ]
        }
      }
    end

    it 'returns request attributes' do
      expect(call).to eq(request_attributes)
    end

    # TODO: add specs
    context 'two "FROM"' do
    end

    context 'two "JOIN"' do
    end
  end
end
