require 'sql_tagger'
require 'pg'

# Adapter for +PG::Connection+ from the pg gem
module SqlTagger::PG
  extend SqlTagger::ModuleMethods

  # I wouldn't be surprised if I missed a method (checked against pg 0.18.4)

  [
    :async_exec,
    :async_query,
    :exec,
    :exec_params,
    :query,
    :send_query,
  ].each do |method|
    define_method("#{method}_with_sql_tagger") do |*args, &blk|
      sql = @sql_tagger.tag(args[0])
      __send__("#{method}_without_sql_tagger", sql, *args[1..-1], &blk)
    end
  end

  [:prepare, :send_prepare].each do |method|
    define_method("#{method}_with_sql_tagger") do |*args, &blk|
      sql = @sql_tagger.tag(args[1])
      __send__("#{method}_without_sql_tagger", args[0], sql, *args[2..-1], &blk)
    end
  end
end

PG::Connection.send(:include, SqlTagger::PG)
