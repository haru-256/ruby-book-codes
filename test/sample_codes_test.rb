require 'pathname'
require 'minitest/autorun'

class SampleCodesTest < Minitest::Test
  CONFIG = {
    'code_1.06.01.rb' => { run_ignore: [6] },
    'code_2.01.02.rb' => { run_ignore: :all },
    'code_2.02.08.rb' => { syntax_ignore: [29], run_ignore: [7] },
    'code_2.05.01.rb' => { run_ignore: [16..31] },
    'code_2.06.00.rb' => { syntax_ignore: [29..31] },
    'code_2.07.03.rb' => { run_ignore: [1..7] },
    'code_2.10.01.rb' => { run_ignore: [12..15] },
    'code_2.10.02.rb' => { syntax_ignore: [39, 46], run_ignore: [39..58] },
    'code_2.11.01.rb' => { run_ignore: [10, 17] },
    'code_2.11.03.rb' => { syntax_ignore: [22, 27] },
    'code_2.12.04.rb' => { syntax_ignore: [1] },
    'code_2.12.07.rb' => { run_ignore: [2, 10, 14] },
    'code_2.12.08.rb' => { run_ignore: :all },
    'code_2.12.09.rb' => { run_ignore: :all },
    'column_2.02.rb' => { run_ignore: [4, 18] },
    'code_3.02.02.rb' => { run_ignore: :all },
    'code_3.02.04.rb' => { run_ignore: :all },
    'code_3.02.05.rb' => { run_ignore: :all },
    'code_3.03.01.rb' => { run_ignore: [100..105] },
    'code_3.03.02.rb' => { syntax_ignore: [34], run_ignore: [32] },
    'column_3.01.rb' => { run_ignore: :all },
    'column_3.02.rb' => { run_ignore: :all },
    'code_4.01.02.rb' => { run_ignore: :all },
    'code_4.03.04.rb' => { run_ignore: [42] },
    'code_4.05.00.rb' => { run_ignore: [32, 38] },
    'code_4.06.00.rb' => { run_ignore: :all },
    'code_4.06.01.rb' => { run_ignore: [18, 29] },
    'code_4.06.03.rb' => { run_ignore: [1..3, 8, 37] },
    'code_4.07.02.rb' => { run_ignore: [5] },
    'code_4.10.05.rb' => { run_ignore: [32] },
    'code_4.10.06.rb' => { run_ignore: [1..9] },
    'code_4.11.02.rb' => { run_ignore: [24..34] },
    'code_4.11.03.rb' => { run_ignore: [42..45] },
    'code_5.01.02.rb' => { run_ignore: :all },
    'code_5.03.01.rb' => { run_ignore: [29] },
    'code_5.04.03.rb' => { run_ignore: [36..37, 57, 70] },
    'code_5.05.00.rb' => { run_ignore: :all },
    'code_5.05.01.rb' => { run_ignore: [18] },
    'code_5.05.02.rb' => { run_ignore: [2, 25] },
    'code_5.05.03.rb' => { run_ignore: [2, 22] },
    'code_5.06.02.rb' => { syntax_ignore: [6] },
    'code_5.06.04.rb' => { run_ignore: [6] },
    'code_5.06.05.rb' => { syntax_ignore: [24] },
    'code_5.06.06.rb' => { syntax_ignore: [17] },
    'code_5.06.07.rb' => { run_ignore: [12] },
    'code_5.07.01.rb' => { syntax_ignore: [13..16] },
    'code_5.07.03.rb' => { run_ignore: [5, 39] },
    'code_7.04.02.rb' => { syntax_ignore: [34] },
    'code_7.04.04.rb' => { syntax_ignore: [25..26] },
    'code_7.08.00.rb' => { syntax_ignore: [23] },
    'code_8.02.02.rb' => { syntax_ignore: [11, 14..15] },
    'code_8.04.03.rb' => { syntax_ignore: [25] },
    'code_8.06.02.rb' => { syntax_ignore: [3..6] },
    'code_11.03.08.rb' => { syntax_ignore: [2] },
    'code_11.04.04.rb' => { syntax_ignore: [4..8] },
    'code_A.02.rb' => { syntax_ignore: [5] },
  }

  def teardown
    delete_files = ['./sample.txt']
    delete_files.each do |file|
      FileUtils.rm(file) if File.exists?(file)
    end
  end

  def assert_syntax(basename, script)
    script_to_run = script
    if ranges = CONFIG.dig(basename, :syntax_ignore)
      assert_raises(SyntaxError) do
        RubyVM::InstructionSequence.compile(script_to_run)
      end
      script_to_run = comment_out(ranges, script)
      RubyVM::InstructionSequence.compile(script_to_run)
    else
      RubyVM::InstructionSequence.compile(script_to_run)
    end
    assert_runnable(basename, script_to_run)
  end

  def assert_runnable(basename, script)
    script_to_run = script
    if ranges = CONFIG.dig(basename, :run_ignore)
      return if ranges == :all
      script_to_run = comment_out(ranges, script_to_run)
    end
    result = RubyVM::InstructionSequence.compile(script_to_run).eval
    puts "result:\n#{result.inspect}"
  end

  def comment_out(ranges, script)
    script.lines.map.with_index(1) {|line, row|
      target = ranges.any?{|obj| ignore?(obj, row)}
      target ? "# #{line}" : line
    }.join
  end

  def ignore?(obj, row)
    case obj
    when Range
      obj.include?(row)
    when Integer
      obj == row
    end
  end

  def test_sample_codes
    files = Dir.glob("./sample_codes/**/*.rb")

    files.each do |file|
      File.open(file, 'r+:utf-8') do |f|
        pathname = Pathname.new(f.path)
        basename = pathname.basename.to_s
        print ',' + basename
        script = f.read
        assert_syntax(basename, script)
      end
    end
  end
end