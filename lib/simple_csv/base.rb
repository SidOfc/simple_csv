module SimpleCsv
  class Base
    attr_reader :index

    COMMON_DELIMITERS = %w(, ; |).freeze

    private

    def settings(**opts)
      return @settings.merge opts if opts.any? && @settings
      @settings ||= Settings.new opts
    end

    def headers(*cols, **col_map)
      @headers ||= []

      if cols.any?
        @headers.concat cols.map(&:to_s)
        alias_to_friendly_headers
      end

      @col_map ||= {}
      @col_map.merge! stringify_col_map(col_map) if col_map.any?

      @headers_set ||= @headers.any?
      @headers
    end

    def alias_to_friendly_headers
      @col_map ||= {}
      aliasses = headers.each_with_object({}) do |hdr, h|
        n = hdr.to_s.strip.gsub(/([a-z])([A-Z])/, '\1_\2').downcase
               .gsub(/[^\w]|\s/, '_')
        h[n] = hdr unless @col_map.key? n
      end

      @col_map.merge! aliasses
    end

    def method_missing(mtd, *args, &block)
      super
    end

    def stringify_col_map(col_map)
      col_map.to_a.map { |m| m.reverse.map(&:to_s) }.to_h
    end

    def respond_to_missing?(mtd, include_private = false)
      @headers.include?(mtd) || @col_map.key?(mtd.to_s) || super
    end
  end
end
