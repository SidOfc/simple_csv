require 'spec_helper'

describe SimpleCsv do

  describe SimpleCsv::Writer do
    it 'can generate a CSV file' do
      csv_path = Helpers.generate_csv('spec/files/result.csv', rows: 100)
      expect(CSV.open(csv_path)).to be_instance_of(CSV)
    end

    it 'converts code-unfriendly headers to callable method aliasses' do
      expect do
        SimpleCsv.generate('spec/files/result.csv') do
          headers 'user name'

          user_name 'sidofc'
        end
      end.to_not raise_error
    end

    it 'headers return values when called without arguments' do
      SimpleCsv.generate('spec/files/result.csv') do
        headers 'user name'

        user_name 'sidofc'

        expect(user_name).to eq 'sidofc'
      end
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
        csv_path = Helpers.generate_csv('spec/files/result.csv', rows: 100,
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

    it 'headers return values when called without arguments' do
      SimpleCsv.generate('spec/files/result.csv') do
        headers 'First name'
        first_name 'foo'
      end

      SimpleCsv.read('spec/files/result.csv') do
        each_row { expect(first_name).to eq 'foo' }
      end
    end

    it 'can detect headers automatically' do
      # if the file has_headers
      res = []
      csv_path = Helpers.generate_csv('spec/files/result.csv', rows: 100)
      SimpleCsv.read(csv_path) do
        each_row { res = res.concat(headers.map { |mtd| send(mtd) }) }
      end

      # sanity check if atleast 70% of returned values are truthy
      expect(res.select { |v| v if v }.count).to be >= (res.count / 100) * 70
    end

    it 'allows aliassing headers' do
      # if the file has_headers
      csv_path = Helpers.generate_csv('spec/files/result.csv', rows: 100)

      SimpleCsv.read(csv_path) do
        headers :first_name, first_name: :aliassed_method
        each_row { expect(aliassed_method).to eq first_name }
      end
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

  describe SimpleCsv::Transformer do
    it 'can transform a CSV' do
      csv_path = Helpers.generate_csv('spec/files/result.csv', rows: 100, age: 40, first_name: 'hello')

      SimpleCsv.transform csv_path, output: 'spec/files/transformed.csv' do
        first_name { |s| s + 'hello' }
        age { |n| n * 2 }
      end

      SimpleCsv.read 'spec/files/transformed.csv' do
        each_row {
          expect(first_name).to eq "hellohello"
          expect(age).to eq 80
        }
      end
    end

    it 'allows reducing output with SimpleCsv::Transformer#output_headers' do
      csv_path = Helpers.generate_csv('spec/files/result.csv', rows: 100, first_name: 'hello')

      SimpleCsv.transform csv_path, output: 'spec/files/transformed.csv' do
        output_headers :first_name

        first_name { |s| s + 'hello' }
      end

      SimpleCsv.read 'spec/files/transformed.csv' do
        expect(headers).to eq ['first_name']
      end
    end
  end
end
