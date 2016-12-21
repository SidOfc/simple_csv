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
        first_name 'foo'
        last_name 'bar'
        birth_date (Date.today << 1000)
        employed_at ['bizz', nil].sample
      end
    end

    path
  end
end
