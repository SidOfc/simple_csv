module SimpleCsv
  class Reader < Base
    attr_reader :index

    def initialize(path, **opts, &block)
      @csv_path = File.expand_path path

      opts[:seperator] ||= detect_delimiter
      settings.apply opts

      load_csv_with_auto_headers if settings.for_csv[:headers]

      instance_eval(&block)
    end

    def in_groups_of(size, &block)
      @original.each_slice(size) do |group|
        @csv = group
        instance_eval(&block)
      end
      @index = nil
      @csv = @original
    end

    def each_row(*arr_opts, &block)
      @index ||= 0 if arr_opts.include?(:with_index)

      load_csv_with_manual_headers unless settings.for_csv[:headers]

      @csv.each do |record|
        @record = record
        instance_eval(&block)
        @index += 1 if @index
      end
    end

    private

    def load_csv_with_auto_headers
      headers(*find_headers)
      @csv = @original = CSV.open @csv_path, settings.for_csv
    end

    def load_csv_with_manual_headers
      SimpleCsv.csv_manually_set_headers! unless @headers_set
      csv_arr = CSV.open(@csv_path).to_a

      if csv_arr.first.size == headers.size
        csv_str = csv_arr.unshift(headers).map(&:to_csv).join
        settings.apply(headers: true)
        @csv = @original = CSV.new csv_str, settings.for_csv
      else
        SimpleCsv.csv_not_enough_headers!
      end
    end

    def find_headers
      first_line.split(detect_delimiter).map { |h| h.gsub(/^"*|"*$/, '') }
    end

    def detect_delimiter
      line = first_line
      @delimiters = COMMON_DELIMITERS.map { |sep| [sep, line.scan(sep).length] }
                                     .sort { |a, b| b[1] <=> a[1] }
      @delimiter ||= @delimiters[0][0]
    end

    def first_line
      @first_line ||= File.open @csv_path, &:readline
    end

    def respond_to_missing?(mtd, include_private = false)
      headers.include?(mtd.to_s) || super
    end

    def method_missing(mtd, *args, &block)
      m = mtd.to_s
      return @record[m] if headers.include?(m)
      return @record[@col_map[m]] if @col_map[m]
      super
    end
  end
end
