require 'spec_helper'
require 'sql_tagger/mysql2'

RSpec.describe Mysql2::Client do
  before :all do
    @db = Mysql2::Client.new
  end

  after :all do
    @db.close
  end

  it_should_behave_like 'connections with sql_tagger'

  describe '#query' do
    it 'works' do
      results = @db.query('SELECT 1 AS one', :symbolize_keys => true)
      expect(results.to_a).to eq([{:one => 1}])
    end

    it 'calls SqlTagger#tag' do
      query = 'SELECT 1'
      expect(@db.sql_tagger).to receive(:tag).with(query).
        and_return("/* something.rb */ #{query}")
      @db.query(query)
    end
  end

  describe '#prepare' do
    let(:query) { 'SELECT ? AS num' }

    it 'works' do
      stmt = @db.prepare(query)
      result = stmt.execute(7)
      expect(result.to_a).to eq([{'num' => 7}])
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
