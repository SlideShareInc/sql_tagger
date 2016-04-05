require 'spec_helper'
require 'sql_tagger/mysql'

RSpec.describe Mysql do
  let(:query) { 'SELECT 1' }

  before :all do
    @db = Mysql.new
  end

  after :all do
    @db.close
  end

  it_should_behave_like 'connections with sql_tagger'

  describe '#query' do
    it 'works' do
      result = @db.query('SELECT 2')
      expect(result.fetch_row).to eq(['2'])
      result.free
    end

    it 'works when given a block' do
      @db.query('SELECT 5') do |result|
        expect(result.fetch_row).to eq(['5'])
      end
    end

    it 'passes a tagged query to the original method' do
      allow(@db.sql_tagger).to receive(:tag).with(query).
        and_return("/* something.rb */ #{query}")
      expect(@db).to receive(:query_without_sql_tagger).
        with("/* something.rb */ #{query}")
      @db.query(query)
    end
  end

  describe '#prepare' do
    it 'works' do
      stmt = @db.prepare('SELECT ?')
      stmt.execute(9)
      expect(stmt.fetch).to eq(['9'])
      stmt.free_result
      stmt.close
    end

    it 'passes a tagged query to the original method' do
      allow(@db.sql_tagger).to receive(:tag).with(query).
        and_return("/* something.rb */ #{query}")
      expect(@db).to receive(:prepare_without_sql_tagger).
        with("/* something.rb */ #{query}")
      @db.prepare(query)
    end
  end
end
