require 'sql_tagger'

describe SqlTagger do
  before :each do
    @sql_tagger = SqlTagger.new
  end

  describe '#tag' do
    before :each do
      prefix = '/usr'
      @sql_tagger.exclusion_pattern = /^#{prefix}/

      @stack_strings_to_skip = [
        "#{prefix}/lib//gems/activerecord-2.3.5/lib/active_record/base.rb:500",
        "#{prefix}//gems/actionpack-2.3.5/lib/something.rb:20",
      ]
      @valid_stack_string = '/home/app/myapp/lib/user.rb:150'
      @caller_result = @stack_strings_to_skip + [@valid_stack_string]
      @sql_tagger.stub!(:caller => @caller_result)

      @sql = 'SELECT 1'
    end

    it 'skips stack strings that match @exclusion_pattern' do
      @sql_tagger.tag(@sql).should == "/* #{@valid_stack_string} */ #{@sql}"
    end

    it 'returns the 1st stack string that does not match @exclusion_pattern' do
      @caller_result.push(
        '/home/app/myapp/lib/document.rb:788',
        '/home/app/myapp/runner.rb:29'
      )
      @sql_tagger.tag(@sql).should == "/* #{@valid_stack_string} */ #{@sql}"
    end

    it 'adds skipped stack strings into @exclusion_cache' do
      @sql_tagger.exclusion_cache.should be_empty
      @sql_tagger.tag(@sql)
      @stack_strings_to_skip.each do |string|
        @sql_tagger.exclusion_cache.should include(string)
      end
      @sql_tagger.exclusion_cache.size.should == @stack_strings_to_skip.length
    end

    it 'skips strings in @exclusion_cache' do
      correct_string = '/home/myapp/i.rb:2890'
      @caller_result.push(correct_string)
      @sql_tagger.exclusion_cache.add(@valid_stack_string)
      @sql_tagger.tag(@sql).should == "/* #{correct_string} */ #{@sql}"
    end
  end

  describe '#exclusion_pattern=' do
    it 'sets @exclusion_pattern' do
      @sql_tagger.exclusion_pattern = /regexp/
      @sql_tagger.exclusion_pattern.should == /regexp/
    end

    it 'clears @exclusion_cache' do
      @sql_tagger.exclusion_cache.merge(['/usr', '/opt'])
      @sql_tagger.exclusion_pattern = /regexp/
      @sql_tagger.exclusion_cache.should be_empty
    end
  end

  describe '.default' do
    it 'returns a functional SqlTagger' do
      SqlTagger.default.should be_a(SqlTagger)
      # The following is to ensure that SqlTagger.default is set after
      # #initialize is defined.
      SqlTagger.default.exclusion_pattern.should be_a(Regexp)
    end
  end
end
