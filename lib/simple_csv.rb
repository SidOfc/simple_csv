require 'csv'

require 'simple_csv/version'
require 'simple_csv/settings'
require 'simple_csv/base'
require 'simple_csv/reader'
require 'simple_csv/writer'

module SimpleCsv
  @converters_initialized = false

  class RowNotComplete < StandardError; end
  class UnparseableCsv < StandardError; end
  class HeadersNotSet < UnparseableCsv; end
  class NotEnoughHeaders < UnparseableCsv; end

  def self.row_not_complete!(mtd, value)
    raise RowNotComplete,
          "Row not complete! #{mtd} called twice with value #{value}"
  end

  def self.csv_not_enough_headers!
    raise NotEnoughHeaders, 'Not enough headers defined!'
  end

  def self.csv_manually_set_headers!
    raise HeadersNotSet,
          ['CSV does not contain headers',
           'please add headers in them manually or in the file'].join(', ')
  end

  def self.read(path, **options, &block)
    initialize_converters unless converters_initialized
    Reader.new path, options, &block
  end

  def self.generate(path, **options, &block)
    initialize_converters unless converters_initialized
    Writer.new path, options, &block
  end

  def self.initialize_converters
    CSV::Converters[:blank_to_nil] = ->(f) { f && f.empty? ? nil : f }
    CSV::Converters[:null_to_nil] = ->(f) { f && f == 'NULL' ? nil : f }
    @converters_initialized = true
  end

  def self.converters_initialized
    @converters_initialized
  end
end
