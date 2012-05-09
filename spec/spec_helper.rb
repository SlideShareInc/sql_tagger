shared_examples_for 'connections with sql_tagger' do
  it 'assigns SqlTagger.default to @sql_tagger' do
    @db.sql_tagger.should == SqlTagger.default
  end
end
