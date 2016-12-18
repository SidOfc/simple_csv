require 'spec_helper'

describe SimpleCsv do
  it 'Can generate a CSV file' do
    csv_path = Helpers.generate_csv('spec/files/output.csv', rows: 100)
    expect(CSV.open(csv_path)).to be_instance_of(CSV)
  end

  it 'Can detect and read CSV files delimited by either ",", ";" or "|"' do
    %w(, ; |).each do |sep|
      res = []
      csv_path = Helpers.generate_csv('spec/files/output.csv', rows: 100,
                                                              seperator: sep)
      SimpleCsv.read(csv_path) do
        headers(*Helpers::HEADERS)
        each_row { res = res.concat(headers.map { |mtd| send(mtd) }) }
      end

      # sanity check if atleast 70% of returned values are truthy
      # it could be that this value is too strict for the type of CSV you are
      # dealing with. In that case adjust the number 70 to your needs.
      expect(res.select { |v| v if v }.count).to be >= (res.count / 100) * 70
    end
  end

  it 'Can detect headers automatically' do
    res = []
    csv_path = Helpers.generate_csv('spec/files/output.csv', rows: 100)
    SimpleCsv.read(csv_path) do
      each_row { res = res.concat(headers.map { |mtd| send(mtd) }) }
    end

    # sanity check if atleast 70% of returned values are truthy
    expect(res.select { |v| v if v }.count).to be >= (res.count / 100) * 70
  end
end
