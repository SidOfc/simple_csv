module SimpleCsv
  class Reader < Base
    attr_reader :index

    def initialize(path, **opts, &block)
      @csv_path = File.expand_path path

      opts[:seperator] ||= detect_delimiter
      settings merge: opts

      load_csv_with_auto_headers if settings[:headers] || settings[:has_headers]

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

      load_csv_with_manual_headers unless @csv

      @csv.each do |record|
        @record = record
        instance_eval(&block)
        @index += 1 if @index
      end
    end

    private

    def load_csv_with_auto_headers
      if settings[:headers].is_a? Array
        headers(*settings[:headers])
      elsif settings[:headers]
        headers(*find_headers)
      end

      @csv = @original = CSV.open @csv_path, settings if headers
    end

    def load_csv_with_manual_headers
      SimpleCsv.csv_manually_set_headers! unless @headers_set

      csv_str = CSV.open(@csv_path).to_a.unshift(headers).map(&:to_csv).join
      @csv = @original = CSV.new csv_str, settings(merge: { headers: true })

      @csv || SimpleCsv.csv_cannot_be_parsed!
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
      binding.pry
      return @record[m] if headers.include?(m)
      return @record[@col_map[m]] if @col_map[m]
      super
    end
  end
end
