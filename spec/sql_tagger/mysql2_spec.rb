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
end
