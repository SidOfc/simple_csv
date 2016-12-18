module SimpleCsv
  class Reader < Base
    attr_reader :index

    def initialize(path, **opts, &block)
      settings merge: opts

      unless opts[:seperator]
        settings merge: { seperator: detect_delimiter(path) }
      end

      headers(*find_headers(path)) if settings[:headers]

      @csv = @original = CSV.open File.expand_path(path), settings
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

      @csv.each do |record|
        @record = record
        instance_eval(&block)
        @index += 1 if @index
      end
    end

    def respond_to_missing?(mtd, include_private = false)
      super
    end

    def method_missing(mtd, *args, &block)
      @headers.include?(mtd.to_s) ? @record[mtd.to_s] : super
    end

    private

    def find_headers(csv_path)
      sep = detect_delimiter(csv_path)
      first_line(csv_path).split(sep).map { |h| h.gsub(/^"*|"*$/, '') }
    end

    def detect_delimiter(csv_path)
      line = first_line(csv_path)
      @delimiters = COMMON_DELIMITERS.map { |sep| [sep, line.scan(sep).length] }
                                     .sort { |a, b| b[1] <=> a[1] }
      @delimiter ||= @delimiters[0][0]
    end

    def first_line(csv_path)
      @first_line ||= File.open(File.expand_path(csv_path), &:readline)
    end
  end
end
