# SimpleCsv

SimpleCsv is a simple gem that allows you to interact with CSV's in a more friendly way.
See the examples given below for more details :)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simple_csv'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple_csv

## Usage

### Generating a CSV file

The `SimpleCsv#generate` method takes a path and options to use for generating the file.
By default, a CSV is generated using comma's (`,`) as seperator and all fields are quoted.

When supplying options they will be merged into the existing defaults rather than overwriting them completely.

```ruby
SimpleCsv.generate(path, options = { seperator: ',', force_quotes: true })
```

To generate a CSV file we use `SimpleCsv#generate` (using the [faker](https://github.com/stympy/faker) gem to provide fake data)

```ruby
require 'faker'

# use SimpleCsv.generate('output.csv', seperator: '|') to generate a CSV with a pipe character as seperator
SimpleCsv.generate('output.csv') do
  # first define the headers
  headers :first_name, :last_name, :birth_date, :employed_at

  # loop something
  100.times do
    # insert data in each field defined in headers to insert a row.
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    birth_date Faker::Date.between(Date.today << 900, Date.today << 200)
    employed_at [Faker::Company.name, nil].sample
  end
end
```

### Reading a CSV file

The `SimpleCsv#read` method takes a path and options to use for reading the file.
By default, the expected seperator is a comma (`,`), `:headers` is set to `true` so that `CSV` parses the file expecting headers.
The `:converters` option ensures values are converted to a proper type if possible, by default (if this is not set) all values are returned as strings

When supplying options they will be merged into the existing defaults rather than overwriting them completely.

```ruby
SimpleCsv.read(path, options = { headers: true, seperator: ',',
                                 converters: [:all, :blank_to_nil, :null_to_nil] })
```

To read a CSV file we use `SimpleCsv#read`, we will pass it a file path and a block as arguments.
Within the block we define the headers present in the file, these will be transformed into methods you can call within `SimpleCsv::Reader#each_row` to get that property's current value

```ruby
SimpleCsv.read('input.csv') do
  # first define the headers in the file manually
  headers :first_name, :last_name, :birth_date, :employed_at

  each_row do
    # print each field defined in headers (that is not nil)
    puts [first_name, last_name, birth_date, employed_at].compact.join ', '
  end
end
```

If we have a large CSV we might want to batch operations (say, if we are inserting this data into a database).
For this we can use `SimpleCsv::Reader#in_groups_of` and pass the size of the group.
Within that we call `SimpleCsv::Reader#each_row` as usual

```ruby
SimpleCsv.read('input.csv') do
  # first define the headers in the file manually
  headers :first_name, :last_name, :birth_date, :employed_at

  in_groups_of(100) do
    each_row do
      # print each field defined in headers (that is not nil)
      puts [first_name, last_name, birth_date, employed_at].compact.join ', '
    end
    # execute after every 100 rows
    sleep 2
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/simple_csv. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
