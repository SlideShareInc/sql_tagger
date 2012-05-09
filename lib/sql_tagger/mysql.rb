require 'sql_tagger'
require 'mysql'

class Mysql
  include SqlTagger::Initializer

  # @see Mysql#query
  def query_with_sql_tagger(sql, &block)
    query_without_sql_tagger(@sql_tagger.tag(sql), &block)
  end

  # @see Mysql#prepare
  def prepare_with_sql_tagger(query)
    prepare_without_sql_tagger(@sql_tagger.tag(query))
  end

  ['query', 'prepare'].each do |method|
    alias_method "#{method}_without_sql_tagger", method
    alias_method method, "#{method}_with_sql_tagger"
  end
end
