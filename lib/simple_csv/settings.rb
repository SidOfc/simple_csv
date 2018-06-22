# frozen_string_literal: true

module SimpleCsv
  class Settings
    DEFAULTS = { headers: true, col_sep: ',', seperator: ',',
                 force_quotes: true,
                 converters: [:all, :blank_to_nil, :null_to_nil] }.freeze
    ALIASSED = { seperator: :col_sep, has_headers: :headers }.freeze
    INVERTED_ALIASSES = ALIASSED.to_a.map(&:reverse).to_h.freeze

    def initialize(**opts)
      @settings = DEFAULTS.dup.merge opts
    end

    def []=(m, val)
      @settings[m] = val
      return @settings[ALIASSED[m]] = val if ALIASSED.key? m
      return @settings[INVERTED_ALIASSES[m]] = val if INVERTED_ALIASSES.key? m
      val
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
      hashes.each { |opts| opts.each { |k, v| self[k] = v } } && @settings
    end

    def method_missing(mtd, *args, &block)
      return super unless accepted_method? mtd
      mtd = ALIASSED[mtd] if ALIASSED.key? mtd
      mtd = INVERTED_ALIASSES[mtd] if INVERTED_ALIASSES.key? mtd
      @settings[mtd]
    end

    def accepted_method?(mtd)
      @settings.key?(mtd) || ALIASSED.key?(mtd) || INVERTED_ALIASSES.key?(mtd)
    end
  end
end
