# frozen_string_literal: true

module SimpleCsv
  class Transformer < Base
    DEFAULT_FILENAME = 'converted.csv'

    def initialize(path, **opts, &block)
      @transforms = {}
      @output_headers = []

      @caller_self = eval 'self', block.binding

      if settings.for_csv[:headers]
        @csv_path = File.expand_path path
        headers(*find_headers) unless headers.any?
      end

      instance_exec(self, &block)

      apply_transforms path, **opts
    end

    def output_headers(*out_headers)
      return @output_headers if @output_headers.any?

      @output_headers = out_headers.map(&:to_s)
      alias_to_friendly_headers @output_headers
      @output_headers
    end

    private

    def apply_transforms(path, **opts)
      received_headers = headers
      timestamp        = Time.new.strftime '%d-%m-%Y-%S%7N'
      output_path      = opts.delete(:output) || "#{path.split('.')[0..-2].join}-#{timestamp}.csv"
      output_headers   = @output_headers.any? ? @output_headers : received_headers

      SimpleCsv.read path, opts do |reader|
        SimpleCsv.generate output_path, opts do |writer|
          writer.headers *output_headers

          reader.each_row do
            output_headers.each do |column|
              transform = find_transform column
              result    = transform ? transform.call(reader.send(column))
                                    : reader.send(column)

              writer.send column, result
            end
          end
        end
      end
    end

    def find_transform(column)
      @transforms[(@col_map.key(column.to_s) || column).to_sym]
    end

    def method_missing(mtd, *args, &block)
      mstr = mtd.to_s

      if headers.include?(mstr) || @output_headers.include?(mstr) || @col_map.key?(mstr)
        @transforms[mtd] = block || args.first unless @transforms.key? mtd
      else
        @caller_self.send mtd, *args, &block
      end
    end
  end
end
