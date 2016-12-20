module SimpleCsv
  class Writer < Base
    DEFAULTS = { force_quotes: true }.freeze

    def initialize(path, **opts, &block)
      settings merge: DEFAULTS.merge(opts)
      CSV.open(File.expand_path(path), 'w', @settings) do |csv|
        @csv = csv
        @current_row = {}
        instance_eval(&block)
      end
    end

    private

    def respond_to_missing?(mtd, include_private = false)
      super
    end

    def method_missing(mtd, *args, &block)
      SimpleCsv.csv_manually_set_headers! unless @headers_written
      super unless headers.include? mtd.to_s
      SimpleCsv.row_not_complete!(mtd, args.first) if @current_row[mtd]

      @current_row[mtd] = args.first || ''

      return unless @current_row.size == headers.size

      @csv << @current_row.values
      @current_row = {}
    end

    def headers(*col_names)
      return @headers if col_names.empty?
      super(*col_names)
      (@csv << @headers) && @headers_written = true if @csv
    end
  end
end
