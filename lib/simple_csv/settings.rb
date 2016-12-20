module SimpleCsv
  class Settings
    DEFAULTS = { headers: true, col_sep: ',', seperator: ',',
                 converters: [:all, :blank_to_nil, :null_to_nil] }.freeze
    ALIASSED = { seperator: :col_sep, has_headers: :headers }.freeze

    def initialize(**opts)
      @settings = DEFAULTS.dup.merge opts
    end

    def [](setting)
      send setting
    end

    def for_csv
      settings = @settings.dup

      ALIASSED.each do |opt_alias, opt|
        settings[opt] = settings.delete(opt_alias) if settings.key? opt_alias
      end

      CSV::DEFAULT_OPTIONS.each_with_object({}) do |(prop, default), csv_hash|
        csv_hash[prop] = settings.key?(prop) ? settings[prop] : default
      end
    end

    def apply(*hashes)
      hashes.each { |opts| @settings.merge! opts }
      @settings
    end

    def any?
      @settings && @settings.any?
    end

    def respond_to_missing?(mtd, include_private = false)
      @settings.key?(mtd) || super
    end

    def method_missing(mtd, *args, &block)
      return super unless @settings.key?(mtd) || ALIASSED.key?(mtd)
      mtd = ALIASSED[mtd] if ALIASSED.key? mtd
      @settings[mtd]
    end
  end
end
