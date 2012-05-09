require 'spec_helper'
require 'sql_tagger/mysql'

describe Mysql do
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
      result.fetch_row.should == ['2']
      result.free
    end

    it 'works when given a block' do
      @db.query('SELECT 5') do |result|
        result.fetch_row.should == ['5']
      end
    end

    it 'calls SqlTagger#tag' do
      @db.sql_tagger.should_receive(:tag).and_return('/* something.rb */ SELECT 1')
      @db.query('SELECT 1').free
    end
  end

  describe '#prepare' do
    it 'works' do
      stmt = @db.prepare('SELECT ?')
      stmt.execute(9)
      stmt.fetch.should == ['9']
      stmt.free_result
      stmt.close
    end

    it 'calls SqlTagger#tag' do
      @db.sql_tagger.should_receive(:tag).and_return('/* something.rb */ SELECT 1')
      @db.prepare('SELECT 1').close
    end
  end
end
