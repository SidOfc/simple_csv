require 'coveralls'
Coveralls.wear!

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'faker'
require 'simple_csv'

module Helpers
  HEADERS = [:first_name, :last_name, :birth_date, :employed_at].freeze

  def self.generate_csv(path, **options)
    n = options.delete(:rows) || 1000
    SimpleCsv.generate('spec/files/output.csv', options) do
      headers(*HEADERS)

      n.times do
        first_name Faker::Name.first_name
        last_name Faker::Name.last_name
        birth_date Faker::Date.between(Date.today << 1000, Date.today << 200)
        employed_at [Faker::Company.name, nil].sample
      end
    end

    path
  end
end
