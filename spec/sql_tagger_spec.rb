require 'sql_tagger'

RSpec.describe SqlTagger do
  subject(:sql_tagger) { SqlTagger.new }

  describe '#tag' do
    let(:prefix) { '/usr' }
    let(:stack_strings_to_skip) do
      [
        "#{prefix}/lib/gems/activerecord-2.3.5/lib/active_record/base.rb:500",
        "#{prefix}/gems/actionpack-2.3.5/lib/something.rb:20",
      ]
    end
    let(:valid_stack_string) { '/home/app/myapp/lib/user.rb:150' }
    let(:caller_result) { stack_strings_to_skip + [valid_stack_string] }
    let(:sql) { 'SELECT 1' }

    before :each do
      sql_tagger.exclusion_pattern = /^#{prefix}/
      allow(sql_tagger).to receive(:caller).and_return(caller_result)
    end

    it 'skips stack strings that match @exclusion_pattern' do
      expect(sql_tagger.tag(sql)).to eq("/*  #{valid_stack_string} */ #{sql}")
    end

    it 'returns the 1st stack string that does not match @exclusion_pattern' do
      caller_result.push(
        '/home/app/myapp/lib/document.rb:788',
        '/home/app/myapp/runner.rb:29'
      )
      expect(sql_tagger.tag(sql)).to eq("/*  #{valid_stack_string} */ #{sql}")
    end

    it 'adds skipped stack strings into @exclusion_cache' do
      expect(sql_tagger.exclusion_cache).to be_empty
      sql_tagger.tag(sql)
      stack_strings_to_skip.each do |string|
        expect(sql_tagger.exclusion_cache).to include(string)
      end
      expect(sql_tagger.exclusion_cache.size).to eq(stack_strings_to_skip.length)
    end

    it 'skips strings in @exclusion_cache' do
      correct_string = '/home/myapp/i.rb:2890'
      caller_result.push(correct_string)
      sql_tagger.exclusion_cache.add(valid_stack_string)
      expect(sql_tagger.tag(sql)).to eq("/*  #{correct_string} */ #{sql}")
    end

    context 'when @custom_tag_prefix is set as a proc' do
      it 'prefixes the tag with a freshly resolved @custom_tag_prefix proc' do
        string_stack = ['a', 'b']
        sql_tagger.custom_tag_prefix = proc { string_stack.pop }
        expect(sql_tagger.tag(sql)).
          to eq("/* b #{valid_stack_string} */ #{sql}")
        expect(sql_tagger.tag(sql)).
          to eq("/* a #{valid_stack_string} */ #{sql}")
      end
    end

    context 'when @custom_tag_prefix is set as a string' do
      it 'prefixes the tag with the set @custom_tag_prefix' do
        sql_tagger.custom_tag_prefix = 'a'
        expect(sql_tagger.tag(sql)).
          to eq("/* a #{valid_stack_string} */ #{sql}")
      end
    end
  end

  describe '#exclusion_pattern=' do
    it 'sets @exclusion_pattern' do
      sql_tagger.exclusion_pattern = /regexp/
      expect(sql_tagger.exclusion_pattern).to eq(/regexp/)
    end

    it 'clears @exclusion_cache' do
      sql_tagger.exclusion_cache.merge(['/usr', '/opt'])
      sql_tagger.exclusion_pattern = /regexp/
      expect(sql_tagger.exclusion_cache).to be_empty
    end
  end

  describe '.default' do
    it 'returns a functional SqlTagger' do
      expect(SqlTagger.default).to be_a(SqlTagger)
      # The following is to ensure that SqlTagger.default is set after
      # #initialize is defined.
      expect(SqlTagger.default.exclusion_pattern).to be_a(Regexp)
    end
  end

  describe SqlTagger::ModuleMethods do
    describe '#included' do
      let(:adapter_class) do
        Module.new do
          extend SqlTagger::ModuleMethods

          def foo_with_sql_tagger; end

          def bar_with_sql_tagger; end
        end
      end

      let(:receiver_class) do
        Class.new do
          def foo; end
        end
      end

      it 'does not fail for methods that do not exist on the receiver' do
        expect {
          receiver_class.send(:include, adapter_class)
        }.not_to raise_error
      end
    end
  end
end
