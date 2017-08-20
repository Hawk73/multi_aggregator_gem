# frozen_string_literal: true

# TODO: make me better, allow_any_instance_of is bad style
module PgHelper
  def create_fake_connection
    double(
      exec: [],
      finish: true
    )
  end

  def stub_pg_connection(fake_connection = create_fake_connection)
    allow(::PG).to receive(:connect).and_return(fake_connection)
  end

  def stub_pg_connection_fail
    allow(::PG).to receive(:connect).and_raise(::PG::ConnectionBad)
  end

  def stub_pg_fetch(result = [])
    allow_any_instance_of(MultiAggregator::Adapters::Pg::Fetcher).to receive(:call).and_return(result)
  end

  def stub_pg_push(result = true)
    allow_any_instance_of(MultiAggregator::Adapters::Pg::Pusher).to receive(:call).and_return(result)
  end

  def stub_pg_query_exec(result = [])
    allow_any_instance_of(MultiAggregator::Adapters::Pg::QueryExecutor).to receive(:call).and_return(result)
  end
end
