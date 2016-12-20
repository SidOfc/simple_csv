require 'spec_helper'

describe SimpleCsv do
  it 'Can generate a CSV file' do
    csv_path = Helpers.generate_csv('spec/files/output.csv', rows: 100)
    expect(CSV.open(csv_path)).to be_instance_of(CSV)
  end

  it 'Fails generation when a row is not completed before creating a new one' do
    expect do
      SimpleCsv.generate('spec/files/output.csv') do
        headers :username, :email, :age

        username 'sidofc'
        age 'unknown'
        username 'something@example.com'
      end
    end.to raise_error /Row not complete!/i
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

  it 'Allows to manually set headers if they are not present or raise' do
    expect do
      SimpleCsv.read('spec/files/headerless.csv', has_headers: false) do
        each_row {}
      end
    end.to raise_error /CSV does not contain headers/

    res = []
    SimpleCsv.read('spec/files/headerless.csv', has_headers: false) do
      headers :first_name, :last_name, :birth_date, :employed_at
      each_row { res = res.concat(headers.map { |mtd| send(mtd) }) }
    end

    expect(res.select { |v| v if v }.count).to be >= (res.count / 100) * 70
  end
end
