require 'spec_helper'
require 'sql_tagger/mysql2'

describe Mysql2::Client do
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
      @db.sql_tagger.should_receive(:tag).and_return('/* something.rb */ SELECT 1')
      @db.query('SELECT 1')
    end
  end
end
