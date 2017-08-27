# MultiAggregator

Prototype for prestodb.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'multi_aggregator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install multi_aggregator

## Usage

    $ psql

```sql
CREATE DATABASE storage;

CREATE DATABASE db_a;
CREATE TABLE users (id integer, name character varying);
INSERT INTO users(id,name) VALUES ('1','Tom'),('2','Jerry');

CREATE DATABASE db_b;
CREATE TABLE types (id integer, type character varying);
INSERT INTO types(id,type) VALUES ('1','cat'),('2','mouse');
```
    $ bundle exec irb

Run code
```ruby
require 'multi_aggregator'

params_a = { dbname: 'db_a' }
provider_a = MultiAggregator::Adapters::Adapter.create_pg_adapter(params_a)
provider_a.check_connections

params_b = { dbname: 'db_b' }
provider_b = MultiAggregator::Adapters::Adapter.create_pg_adapter(params_b)
provider_b.check_connections

providers = {
'db_a' => provider_a,
'db_b' => provider_b
}

storage_params = { dbname: 'storage' }
storage = MultiAggregator::Adapters::Adapter.create_pg_adapter(storage_params)
storage.check_connections

query = <<-SQL
SELECT db_a.users.id, db_a.users.name, db_b.types.type
FROM db_a.users
LEFT JOIN db_b.types ON (db_b.types.id = db_a.users.id);
SQL

MultiAggregator::Processor.new.call(query, storage, providers)
```
Expected result
```
{"id"=>"1", "name"=>"Tom", "type"=>"cat"}
{"id"=>"2", "name"=>"Jerry", "type"=>"mouse"}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/multi_aggregator.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
