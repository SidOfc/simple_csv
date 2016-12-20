module SimpleCsv
  class Base
    attr_reader :index

    COMMON_DELIMITERS = %w(, ; |).freeze
    DEFAULTS = { headers: true, col_sep: ',', seperator: ',',
                 converters: [:all, :blank_to_nil, :null_to_nil] }.freeze

    private

    def settings(**opts)
      return @settings.merge opts if opts.any? && @settings
      @settings ||= Settings.new opts
    end

    def headers(*cols, **col_map)
      @headers = cols.any? && cols.map(&:to_s) || []
      @col_map = col_map.any? && stringify_col_map(col_map) || {}
      @headers_set = @headers.any?
      @headers
    end

    def stringify_col_map(col_map)
      col_map.to_a.map { |m| m.reverse.map(&:to_s) }.to_h
    end

    def respond_to_missing?(mtd, include_private = false)
      @headers.include?(mtd) || super
    end
  end
end
