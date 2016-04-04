require 'sql_tagger'
require 'mysql2'

# Adapter for +Mysql2::Client+ from the mysql2 gem
module SqlTagger::Mysql2
  extend SqlTagger::ModuleMethods

  # @see Mysql2::Client#query
  def query_with_sql_tagger(sql, opts ={})
    query_without_sql_tagger(@sql_tagger.tag(sql), opts)
  end

  # @see Mysql2::Client#prepare
  def prepare_with_sql_tagger(sql)
    prepare_without_sql_tagger(@sql_tagger.tag(sql))
  end
end

Mysql2::Client.send(:include, SqlTagger::Mysql2)
