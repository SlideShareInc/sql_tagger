require 'sql_tagger'
require 'mysql'

module SqlTagger::Mysql
  extend SqlTagger::ModuleMethods

  # @see Mysql#query
  def query_with_sql_tagger(sql, &block)
    query_without_sql_tagger(@sql_tagger.tag(sql), &block)
  end

  # @see Mysql#prepare
  def prepare_with_sql_tagger(query)
    prepare_without_sql_tagger(@sql_tagger.tag(query))
  end
end

Mysql.send(:include, SqlTagger::Mysql)
