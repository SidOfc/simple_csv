require 'csv'

require 'simple_csv/version'
require 'simple_csv/base'
require 'simple_csv/reader'
require 'simple_csv/writer'

module SimpleCsv
  @converters_initialized = false

  def self.row_not_complete!(mtd, value)
    raise "Row not complete! #{mtd} called twice with value #{value}"
  end

  def self.csv_cannot_be_parsed!
    raise 'CSV cannot be parsed, please check the format of the file.'
  end

  def self.csv_manually_set_headers!
    raise ['CSV does not contain headers',
           'please add headers in them manually or in the file'].join ', '
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
