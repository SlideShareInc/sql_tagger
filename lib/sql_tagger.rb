require 'set'

# Instances of this class insert stack trace comments into SQL queries.
class SqlTagger
  VERSION = IO.read(
    File.join(File.dirname(__FILE__), '..', 'VERSION')
  ).chomp.freeze

  # @return [Regexp]
  #   regular expression used to match stack strings we should skip (usually
  #   because such stack strings aren't specific enough, like stack strings
  #   where the file belongs to a gem)
  attr_accessor :exclusion_pattern

  # @return [Set] set that holds stack strings we skipped before
  attr_reader :exclusion_cache

  def initialize
    @exclusion_pattern = /^#{RbConfig::CONFIG['prefix']}|\/vendor\//
    @exclusion_cache = Set.new
  end

  # Returns the given query string with a string from +Kernel#caller+ prepended
  # as a comment that reveals what code triggered the query.
  #
  # For example, given "SELECT 1", this will return something like
  # "/* program.rb:25:in `some_method' */ SELECT 1".
  #
  # @param [String] sql SQL query string
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

  @default = self.new

  class << self
    # @return [SqlTagger] default SqlTagger to use
    attr_accessor :default
  end

  # Mixin that monkey patches the receiver's +initialize+ method to set
  # +@sql_tagger+.
  module Initializer
    def self.included(base)
      base.send(:alias_method, :initialize_without_sql_tagger, :initialize)
      base.send(:alias_method, :initialize, :initialize_with_sql_tagger)
    end

    # @return [SqlTagger] the SqlTagger used to tag queries for this instance
    attr_accessor :sql_tagger

    def initialize_with_sql_tagger(*args, &block)
      @sql_tagger = SqlTagger.default
      initialize_without_sql_tagger(*args, &block)
    end
  end
end
