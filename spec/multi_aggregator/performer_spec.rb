# frozen_string_literal: true

RSpec.describe MultiAggregator::Performer do
  let(:query) { QueryGenerator.call }

  it 'runs without errors' do
    subject.call(query)
  end
end
