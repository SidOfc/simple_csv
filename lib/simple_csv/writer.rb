# frozen_string_literal: true

module SimpleCsv
  class Writer < Base
    def initialize(path, **opts, &block)
      @caller_self = eval 'self', block.binding

      settings.apply({force_row_completion: true}, opts)
      CSV.open(File.expand_path(path), 'w', settings.for_csv) do |csv|
        @csv = csv
        @last_row = {}
        @current_row = {}
        instance_exec(self, &block)
      end
    end

    def headers(*args)
      super
      (@csv << @headers) && @headers_written = true if !@headers_written && @csv
      @headers
    end

    private

    def method_missing(mtd, *args, &block)
      SimpleCsv.csv_manually_set_headers! unless @headers_written

      current_val = @current_row[mtd] if @current_row.key?(mtd)
      current_val = @last_row[mtd] if @last_row.key?(mtd)

      return current_val if args.empty? && current_val

      unless headers.include?(mtd.to_s) || @col_map.key?(mtd.to_s)
        return @caller_self.send mtd, *args, &block
      end

      if settings.force_row_completion && @current_row.key?(mtd) && args.any?
        SimpleCsv.row_not_complete!(mtd, args.first)
      end

      current_val = @current_row[mtd] = args.first || current_val

      return current_val unless @current_row.size == headers.size

      @last_row = @current_row
      @csv << @current_row.values
      @current_row = {}
      current_val
    end

    def respond_to_missing?(*)
      true
    end
  end
end
