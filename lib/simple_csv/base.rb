module SimpleCsv
  class Base
    attr_reader :index

    COMMON_DELIMITERS = %w(, ; |).freeze

    def debug_headers
      p "@headers is now: #{@headers.join ','}"
      p "@col_map is now #{@col_map}"
    end

    private

    def settings(**opts)
      return @settings.merge opts if opts.any? && @settings
      @settings ||= Settings.new opts
    end

    def headers(*cols, **col_map)
      @headers ||= []
      @headers.concat cols.map(&:to_s) if cols.any?

      @col_map ||= {}
      @col_map.merge! stringify_col_map(col_map) if col_map.any?

      @headers_set ||= @headers.any?

      @headers
    end

    def stringify_col_map(col_map)
      col_map.to_a.map { |m| m.reverse.map(&:to_s) }.to_h
    end

    def respond_to_missing?(mtd, include_private = false)
      @headers.include?(mtd) || @col_map.key?(mtd.to_s) || super
    end
  end
end
