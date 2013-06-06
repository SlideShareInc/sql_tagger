require 'sql_tagger'
require 'mysql2'

module SqlTagger::Mysql2
  extend SqlTagger::ModuleMethods

  # @see Mysql2::Client#query
  def query_with_sql_tagger(sql, opts ={})
    query_without_sql_tagger(@sql_tagger.tag(sql), opts)
  end
end

Mysql2::Client.send(:include, SqlTagger::Mysql2)
