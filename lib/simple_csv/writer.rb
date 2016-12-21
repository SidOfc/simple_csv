module SimpleCsv
  class Writer < Base
    def initialize(path, **opts, &block)
      settings.apply({force_row_completion: true}, opts)
      CSV.open(File.expand_path(path), 'w', settings.for_csv) do |csv|
        @csv = csv
        @current_row = {}
        instance_eval(&block)
      end
    end

    private

    def respond_to_missing?(mtd, include_private = false)
      super unless headers.include?(mtd.to_s) || @col_map.key?(mtd.to_s)
    end

    def method_missing(mtd, *args, &block)
      return @current_row[mtd] unless args.any?
      SimpleCsv.csv_manually_set_headers! unless @headers_written
      super unless headers.include?(mtd.to_s) || @col_map.key?(mtd.to_s)

      if settings.force_row_completion && @current_row.key?(mtd) &&
         @current_row.size != headers.size
        SimpleCsv.row_not_complete!(mtd, args.first)
      end

      @current_row[mtd] = args.first

      return unless @current_row.size == headers.size

      @csv << @current_row.values
      @current_row = {}
      args.first
    end

    def headers(*args)
      super
      (@csv << @headers) && @headers_written = true if !@headers_written && @csv
      @headers
    end
  end
end
