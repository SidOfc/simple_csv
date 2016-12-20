require 'spec_helper'

describe SimpleCsv do

  describe SimpleCsv::Writer do
    it 'can generate a CSV file' do
      csv_path = Helpers.generate_csv('spec/files/output.csv', rows: 100)
      expect(CSV.open(csv_path)).to be_instance_of(CSV)
    end

    it 'raises RowNotComplete if a property is called twice in the same loop' do
      expect do
        SimpleCsv.generate('spec/files/output.csv') do
          headers :username, :email, :age

          username 'sidofc'
          age 'unknown'
          username 'something@example.com'
        end
      end.to raise_error SimpleCsv::RowNotComplete
    end
  end

  it 'read CSV files delimited by ",", ";" or "|"' do
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

  it 'can detect headers automatically' do
    # if the file has_headers
    res = []
    csv_path = Helpers.generate_csv('spec/files/output.csv', rows: 100)
    SimpleCsv.read(csv_path) do
      each_row { res = res.concat(headers.map { |mtd| send(mtd) }) }
    end

    # sanity check if atleast 70% of returned values are truthy
    expect(res.select { |v| v if v }.count).to be >= (res.count / 100) * 70
  end

  it 'allows to manually set headers if they are not present or raise' do
    # headers not set at all
    expect do
      SimpleCsv.read('spec/files/headerless.csv', has_headers: false) do
        each_row {}
      end
    end.to raise_error SimpleCsv::HeadersNotSet

    # column count isn't equal to the amount of headers set
    expect do
      SimpleCsv.read('spec/files/headerless.csv', has_headers: false) do
        headers :first_name, :last_name, :birth_date
        each_row {}
      end
    end.to raise_error SimpleCsv::NotEnoughHeaders

    # successfull usecase
    res = []
    SimpleCsv.read('spec/files/headerless.csv', has_headers: false) do
      headers :first_name, :last_name, :birth_date, :employed_at
      each_row { res = res.concat(headers.map { |mtd| send(mtd) }) }
    end

    expect(res.select { |v| v if v }.count).to be >= (res.count / 100) * 70
  end

  it 'properly converts'
end
