module SimpleCsv
  class Base
    attr_reader :index

    COMMON_DELIMITERS = %w(, ; |)
    DEFAULTS = { headers: true, col_sep: ',', seperator: ',',
                 converters: [:all, :blank_to_nil, :null_to_nil] }.freeze

    private

    def settings(**opts)
      @settings ||= DEFAULTS.dup
      @settings = @settings.merge opts[:merge] if opts[:merge]

      @settings[:col_sep] = @settings.delete :seperator if @settings[:seperator]

      @settings
    end

    def headers(*column_names)
      return @headers if column_names.empty?
      @headers = column_names.map(&:to_s)
    end

    def respond_to_missing?(mtd, include_private = false)
      @headers.include?(mtd) || super
    end
  end
end
