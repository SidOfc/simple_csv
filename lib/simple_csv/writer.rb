module SimpleCsv
  class Writer < Base
    DEFAULTS = { force_quotes: true }.freeze

    def initialize(path, **opts, &block)
      settings merge: DEFAULTS.merge(opts)
      CSV.open(File.expand_path(path), 'w', @settings) do |csv|
        @csv = csv
        @current_row = []
        instance_eval(&block)
      end
    end

    private

    def respond_to_missing?(mtd, include_private = false)
      super
    end

    def method_missing(mtd, *args, &block)
      super unless @headers.include? mtd.to_s

      @current_row << args[0]
      row_complete = @current_row.count == @headers.count
      (@csv << @current_row) && @current_row = [] if row_complete
    end

    def headers(*column_names)
      super
      @csv << @headers if @csv
      @headers
    end
  end
end
