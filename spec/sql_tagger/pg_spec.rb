require 'spec_helper'
require 'sql_tagger/pg'

RSpec.describe PG::Connection do
  let(:query) { 'SELECT 1 AS num' }

  before :context do
    @db = PG.connect(dbname: 'postgres')
  end

  after :context do
    @db.finish
  end

  it_should_behave_like 'connections with sql_tagger'

  [
    :async_exec,
    :async_query,
    :exec,
    :exec_params,
    :query,
    :send_query,
  ].each do |method|
    describe "##{method}" do
      it 'works' do
        result = @db.__send__(method, query)
        if method == :send_query
          result = @db.get_last_result
        end
        expect(result.to_a).to eq([{'num' => '1'}])
      end

      it 'passes a tagged query to the original method' do
        allow(@db.sql_tagger).to receive(:tag).with(query).
          and_return("/* something.rb */ #{query}")
        expect(@db).to receive("#{method}_without_sql_tagger").
          with("/* something.rb */ #{query}")
        @db.__send__(method, query)
      end
    end
  end

  [:prepare, :send_prepare].each do |method|
    describe "##{method}" do
      it 'works' do
        statement_name = "#{method}_test_works"
        @db.__send__(method, statement_name, query)
        result = @db.exec_prepared(statement_name)
        expect(result.to_a).to eq([{'num' => '1'}])
      end

      it 'passes a tagged query to the original method' do
        statement_name = "#{method}_test_calls"
        allow(@db.sql_tagger).to receive(:tag).with(query).
          and_return("/* something.rb */ #{query}")
        expect(@db).to receive("#{method}_without_sql_tagger").
          with(statement_name, "/* something.rb */ #{query}")
        @db.__send__(method, statement_name, query)
      end
    end
  end
end
