require 'set'

# Instances of this class insert stack trace comments into SQL queries.
class SqlTagger
  # Version string
  VERSION = IO.read(
    File.join(File.dirname(__FILE__), '..', 'VERSION')
  ).chomp.freeze

  # @return [Regexp]
  #   regular expression used to match stack strings we should skip (usually
  #   because such stack strings aren't specific enough, like stack strings
  #   where the file belongs to a gem)
  attr_reader :exclusion_pattern

  # @return [Set] set that holds stack strings we skipped before
  attr_reader :exclusion_cache

  def initialize
    @exclusion_pattern = %r{\A#{RbConfig::CONFIG['prefix']}|/gems/}
    @exclusion_cache = Set.new
  end

  # Returns the given query string with a string from +Kernel#caller+ prepended
  # as a comment that reveals what code triggered the query.
  #
  # For example, given "SELECT 1", this will return something like
  # "/* program.rb:25:in `some_method' */ SELECT 1".
  #
  # @param sql [String] SQL query string
  # @return [String] query string with a comment at the beginning
  def tag(sql)
    caller(2).each do |string|
      next if @exclusion_cache.member?(string)
      if string !~ @exclusion_pattern
        return "/* #{string} */ #{sql}"
      else
        @exclusion_cache.add(string)
      end
    end

    # Just in case we skip the whole stack somehow ...
    "/* SqlTagger#tag skipped the whole stack */ #{sql}"
  end

  # Sets +@exclusion_pattern+.
  #
  # @param regexp [Regexp] regular expression to be used to skip stack strings
  def exclusion_pattern=(regexp)
    @exclusion_pattern = regexp
    @exclusion_cache.clear
  end

  @default = self.new

  class << self
    # @return [SqlTagger] default SqlTagger to use
    attr_accessor :default
  end

  # @see .included
  module Initializer
    # Callback that monkey patches the receiver's +initialize+ method to set
    # +@sql_tagger+.
    #
    # @param base [Module]
    def self.included(base)
      base.send(:alias_method, :initialize_without_sql_tagger, :initialize)
      base.send(:alias_method, :initialize, :initialize_with_sql_tagger)

      # This is for the odd case where a SQL gem/library is used before
      # sql_tagger is required.
      ObjectSpace.each_object(base) do |obj|
        obj.sql_tagger ||= SqlTagger.default
      end
    end

    # @return [SqlTagger] the SqlTagger used to tag queries for this instance
    attr_accessor :sql_tagger

    # Sets +@sql_tagger+ before initializing
    def initialize_with_sql_tagger(*args, &block)
      @sql_tagger = SqlTagger.default
      initialize_without_sql_tagger(*args, &block)
    end
  end

  # Extend this module in your adapter module
  module ModuleMethods
    # Callback that includes SqlTagger::Initializer and does method aliasing.
    #
    # @param base [Module]
    def included(base)
      base.send(:include, SqlTagger::Initializer)
      self.instance_methods.map(&:to_s).grep(/_with_sql_tagger$/).each do |with_method|
        target = with_method.sub(/_with_sql_tagger$/, '')
        if base.method_defined?(target)
          base.send(:alias_method, "#{target}_without_sql_tagger", target)
          base.send(:alias_method, target, with_method)
        end
      end
    end
  end
end
