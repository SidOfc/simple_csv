require 'spec_helper'

describe SimpleCsv do

  describe SimpleCsv::Writer do
    it 'can generate a CSV file' do
      csv_path = Helpers.generate_csv('spec/files/output.csv', rows: 100)
      expect(CSV.open(csv_path)).to be_instance_of(CSV)
    end

    it 'converts code-unfriendly headers to callable method aliasses' do
      res = nil
      SimpleCsv.generate('spec/files/output.csv') do
        headers 'user name'

        user_name 'sidofc'

        res = user_name
      end
      expect(res).to eq 'sidofc'
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

  describe SimpleCsv::Reader do
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

    it 'allows aliassing headers' do
      # if the file has_headers
      csv_path = Helpers.generate_csv('spec/files/output.csv', rows: 100)
      res = []
      SimpleCsv.read(csv_path) do
        headers first_name: :aliassed_method
        each_row { res << aliassed_method }
      end

      expect(res.compact.any?).to be true
    end

    it 'raises an exception when not enough headers are present' do
      expect do
        SimpleCsv.read('spec/files/headerless.csv', has_headers: false) do
          headers :first_name, :last_name, :birth_date
          each_row {}
        end
      end.to raise_error SimpleCsv::NotEnoughHeaders
    end

    it 'raises an exception if headers are not set' do
      expect do
        SimpleCsv.read('spec/files/headerless.csv', has_headers: false) do
          each_row {}
        end
      end.to raise_error SimpleCsv::HeadersNotSet
    end

    it 'allows to manually set headers if they are not present' do
      res = []
      SimpleCsv.read('spec/files/headerless.csv', has_headers: false) do
        headers :first_name, :last_name, :birth_date, :employed_at
        each_row { res = res.concat(headers.map { |mtd| send(mtd) }) }
      end

      expect(res.select { |v| v if v }.count).to be >= (res.count / 100) * 70
    end
  end
end
