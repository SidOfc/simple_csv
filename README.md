# SimpleCsv

SimpleCsv is a simple gem that allows you to interact with CSV's in a more friendly way.
See the examples given below for more details :)

## Status

[![Gem Version](https://badge.fury.io/rb/simple_csv.svg)](http://badge.fury.io/rb/simple_csv)
[![Build Status](https://travis-ci.org/SidOfc/simple_csv.svg?branch=master)](https://travis-ci.org/SidOfc/simple_csv)
[![Coverage Status](https://coveralls.io/repos/github/SidOfc/simple_csv/badge.svg?branch=master)](https://coveralls.io/github/SidOfc/simple_csv?branch=master)

---

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

### General

By default, the settings used will be those of `CSV::DEFAULT_OPTIONS` generally.
`SimpleCsv` sets the `:headers` property to true by default, this is due to the nature of `SimpleCsv`.

Headers have to be defined either before reading or generating a CSV.
Since `:headers` is now `true` by default, `SimpleCsv` will allow `CSV` to parse the first line as headers.
These headers are then converted in method calls to use within an `SimpleCsv::Reader#each_row` loop.

If however, your file lacks headers, you have the ability to set `:has_headers` to false and supply headers manually before calling `SimpleCsv::Reader#each_row`.
The headers will be picked up and used instead of the first line.

#### SimpleCsv default settings

These are the settings that will be merged with settings passed through either `SimpleCsv#generate` or `SimpleCsv#read`

|        setting       |                   value               |
|----------------------|---------------------------------------|
|`:col_sep`            | `","`                                 |
|`:row_sep`            | `:auto`                               |
|`:quote_char`         | `"\"`                                 |
|`:field_size_limit`    | `nil`                                 |
|`:converters`         | `[:all, :blank_to_nil, :null_to_nil]` |
|`:unconverted_fields`  | `nil`                                 |
|`:headers`            | `true`                                |
|`:return_headers`     | `false`                               |
|`:header_converters`  | `nil`                                 |
|`:skip_blanks`        | `false`                               |
|`:force_quotes`       | `true`                                |
|`:skip_lines`         | `nil`                                 |

The following settings differ from the `CSV::DEFAULT_OPTIONS`

* `:converters` is set to `[:all, :blank_to_nil, :null_to_nil]`
* `:headers` is `true` by default
* `:force_quotes` is `true` by default

This essentially means that when reading a CSV file, headers are required otherwise a `SimpleCsv::HeadersNotSet` exception will be thrown.
Also, when reading a CSV, all values will be parsed to their respective types, so `"1"` would become `1` as end value.

#### SimpleCsv::Writer additional default settings

Additionally, `SimpleCsv::Writer` has one additional default setting that ensures an entire row is written before being able to write another one.
This setting enforces you to call each method once before calling one of them again, if this condition is not met a `SimpleCsv::RowNotComplete` exception will be thrown

|         setting        |                   value               |
|------------------------|---------------------------------------|
|`:force_row_completion` | `true`                                |

#### Setting aliasses

An _alias_ can be used instead of it's respective _setting_.

|    setting    |     alias     |
|---------------|---------------|
| `:col_sep`    | `:seperator`  |
| `headers`     | `has_headers` |

#### Converters

The above `:converters` option is set to include `:all` converters and additionally, `:blank_to_nil` and `:null_to_nil`
The code for these two can be summed up in two lines:

```ruby
CSV::Converters[:blank_to_nil] = ->(f) { f && f.empty? ? nil : f }
CSV::Converters[:null_to_nil] = ->(f) { f && f == 'NULL' ? nil : f }
```

What they do replace empty values or the string `'NULL'` by nil within a column when it's being parsed.
For now, these are the default two and they are always used unless the `:converters` option is set to `nil` within `SimpleCsv#generate` or `SimpleCsv#read`

### Generating a CSV file

```ruby
SimpleCsv.generate path, options = { ... }, &block
```

The `SimpleCsv#generate` method takes a (required) path, an (optional) hash of options and a (required) block to start building a CSV file.
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

```ruby
SimpleCsv.read path, options = { ... }, &block
```

The `SimpleCsv#generate` method takes a (required) path, an (optional) hash of options and a (required) block to start building a CSV file.

To read a CSV file we use `SimpleCsv#read`, we will pass it a file path and a block as arguments.
Within the block we define the headers present in the file, these will be transformed into methods you can call within `SimpleCsv::Reader#each_row` to get that property's current value

```ruby
SimpleCsv.read('input.csv') do
  # assumes headers are set, they will be read and callable within each_row

  each_row do
    puts [first_name, last_name, birth_date, employed_at].compact.join ', '
  end
end
```

### Reading a CSV file without headers

Last but not least, if we have a CSV file that does not contain headers we can use the following setup.
Setting `:has_headers` to `false` means we do not expect the first line to be headers.
Therefore we have to explicitly define the headers before looping the CSV.

```ruby
SimpleCsv.read('headerless.csv', has_headers: false) do
  # first define the headers in the file manually if the file does not have them
  headers :first_name, :last_name, :birth_date, :employed_at

  each_row do
    # print each field defined in headers (that is not nil)
    puts [first_name, last_name, birth_date, employed_at].compact.join ', '
  end
end
```

### Batch operations

If we have a large CSV we might want to batch operations (say, if we are inserting this data into a database or through an API).
For this we can use `SimpleCsv::Reader#in_groups_of` and pass the size of the group.
Within that we call `SimpleCsv::Reader#each_row` as usual

```ruby
SimpleCsv.read('input.csv') do
  # assumes headers are set, they will be read and callable within each_row

  in_groups_of(100) do
    each_row do
      puts [first_name, last_name, birth_date, employed_at].compact.join ', '
    end
    # execute after every 100 rows
    sleep 2
  end
end
```

### Aliassing existing headers

Should you want to map existing headers to different names, this is possible by passing a hash at the end with key value pairs.
When generating a CSV file, aliasses are ignored and therefore should not be passed.

When defining columns manually using `headers` for a file without headers, ALL columns must be named before defining aliasses.
This means that if your CSV exists of 3 columns, 3 headers must be defined before aliassing any of those to something shorter or more concise.

To create an alias `date_of_birth` of `birth_date` *(In a CSV file without headers)* we would write *(notice `:birth_date` is present twice, once as column entry, and once more as key for an alias)*:

```ruby
headers :first_name, :last_name, :employed_at, :birth_date, birth_date: :date_of_birth
```

## Development

After checking out the repo, run `bundle` to install dependencies. Then, run `rspec` to run the tests. You can also use the `bin/console` file to play around and debug.

To install this gem onto your local machine, run `rake install`.

To release a new version:

* Run CI in dev branch, if tests pass, merge into master
* Update version number in _lib/simple_csv/version.rb_ according to [symver](http://semver.org/)
* Update _README.md_ to reflect your changes
* run `rake release` to push commits, create a tag for the current commit and push the `.gem` file to RubyGems

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sidofc/simple_csv. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
