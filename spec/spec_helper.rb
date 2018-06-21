require 'coveralls'
Coveralls.wear!

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'faker'
require 'simple_csv'

module Helpers
  HEADERS = [:first_name, :last_name, :age, :birth_date, :employed_at].freeze

  def self.generate_csv(path, **options)
    n = options.delete(:rows) || 10
    fn = options.delete(:first_name) || 'foo'
    ln = options.delete(:last_name) || 'bar'
    bd = options.delete(:birth_date) || (Date.today << 1000)
    ea = options.delete(:employed_at) || ['bizz', nil].sample
    ag = options.delete(:age) || 20

    SimpleCsv.generate(path, options) do
      headers(*HEADERS)

      n.times do
        first_name fn
        last_name ln
        age ag
        birth_date bd
        employed_at ea
      end
    end

    path
  end
end
