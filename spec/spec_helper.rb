shared_examples_for 'connections with sql_tagger' do
  it 'assigns SqlTagger.default to @sql_tagger' do
    expect(@db.sql_tagger).to eq(SqlTagger.default)
  end
end
