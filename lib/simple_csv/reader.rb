# frozen_string_literal: true

module SimpleCsv
  class Reader < Base
    attr_reader :index

    def initialize(path, **opts, &block)
      @csv_path = File.expand_path path
      @caller_self = eval 'self', block.binding

      opts[:seperator] ||= detect_delimiter
      settings.apply opts

      load_csv_with_auto_headers if settings.for_csv[:headers]

      instance_exec(self, &block)
    end

    def in_groups_of(size, &block)
      @original.each_slice(size) do |group|
        @csv = group
        instance_exec(self, &block)
      end
      @index = nil
      @csv = @original
    end

    def each_row(*arr_opts, &block)
      @index ||= 0 if arr_opts.include?(:with_index)

      load_csv_with_manual_headers unless @csv

      @csv.each do |record|
        @record = record
        instance_exec(self, &block)
        @index += 1 if @index
      end
    end

    private

    def load_csv_with_auto_headers
      headers(*find_headers)

      @csv = @original = CSV.open @csv_path, settings.for_csv
    end

    def load_csv_with_manual_headers
      SimpleCsv.csv_manually_set_headers! unless headers?
      csv_arr = CSV.open(@csv_path).to_a

      if csv_arr.first.size == headers.size
        csv_str = csv_arr.unshift(headers).map(&:to_csv).join
        settings.apply(headers: true)
        @csv = @original = CSV.new csv_str, settings.for_csv
      else
        SimpleCsv.csv_not_enough_headers!
      end
    end

    def method_missing(mtd, *args, &block)
      m = mtd.to_s
      return @record[m] if headers.include?(m)
      return @record[@col_map[m]] if @col_map.key?(m)
      @caller_self.send mtd, *args, &block
    end

    def respond_to_missing?(mtd, include_private = false)
      @headers.include?(mtd) || @col_map.key?(mtd.to_s) || super
    end
  end
end
