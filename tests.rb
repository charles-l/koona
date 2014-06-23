require './lib/compiler.rb'
require 'tempfile'
require 'test/unit'

class TestVarDecl < Test::Unit::TestCase
  def test_decl
    begin
      c = Koona::Compiler.new
      input_file = Tempfile.new('TestVarDecl')

      input_file << "int x = 5"
      exp_result = "int main()\n{\n{\nint x = 5;\n}\nreturn 0;\n}\n"
      input_file.read # ? Dunno why, but this line is neccessary for the next one to run.
      assert_equal(exp_result, c.compile(input_file))
    ensure # Make sure to delete the temp file
      input_file.close
      input_file.unlink
    end
  end

  def test_var_assign
    begin
      c = Koona::Compiler.new
      input_file = Tempfile.new('TestVarDecl')

      input_file << "int x = 5\nx = 2"
      exp_result = "int main()\n{\n{\nint x = 5;\nx = 2;\n}\nreturn 0;\n}\n"
      input_file.read # ? Dunno why, but this line is neccessary for the next one to run.
      assert_equal(exp_result, c.compile(input_file))
    ensure # Make sure to delete the temp file
      input_file.close
      input_file.unlink
    end
  end

  def test_func_decl
    begin
      c = Koona::Compiler.new
      input_file = Tempfile.new('TestVarDecl')

      input_file << "int test()\n{\nreturn 1\n}"
      exp_result = "int test()\n{\nreturn 1;\n}\nint main()\n{\n{\n}\nreturn 0;\n}\n"
      input_file.read # ? Dunno why, but this line is neccessary for the next one to run.
      assert_equal(exp_result, c.compile(input_file))
    ensure # Make sure to delete the temp file
      input_file.close
      input_file.unlink
    end
  end

  def test_func_call
    begin
      c = Koona::Compiler.new
      input_file = Tempfile.new('TestVarDecl')

      input_file << "int test()\n{\nreturn 1\n}\ntest()"
      exp_result = "int test()\n{\nreturn 1;\n}\nint main()\n{\n{\ntest();\n}\nreturn 0;\n}\n"
      input_file.read # ? Dunno why, but this line is neccessary for the next one to run.
      assert_equal(exp_result, c.compile(input_file))
    ensure # Make sure to delete the temp file
      input_file.close
      input_file.unlink
    end
  end
end
