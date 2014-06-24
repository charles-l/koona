require './lib/compiler.rb'
require 'tempfile'
require 'test/unit'

class TestVarDecl < Test::Unit::TestCase
  def result_test(input, exp_result)
    begin
      c = Koona::Compiler.new
      input_file = Tempfile.new('TestFile')

      input_file << input
      exp_result = exp_result
      input_file.read # ? Dunno why, but this line is neccessary for the next one to run.
      assert_equal(exp_result, c.compile(input_file))
    ensure # Make sure to delete the temp file
      input_file.close
      input_file.unlink
    end
  end

  def test_decl
    result_test("int x = 5", 
              "int main()\n{\n{\nint x = 5;\n}\nreturn 0;\n}\n")
  end

  def test_var_assign
    result_test("int x = 5\nx = 2", 
             "int main()\n{\n{\nint x = 5;\nx = 2;\n}\nreturn 0;\n}\n")
  end

  def test_func_decl
    result_test("int test()\n{\nreturn 1\n}", 
             "int test()\n{\nreturn 1;\n}\nint main()\n{\n{\n}\nreturn 0;\n}\n")
  end

  def test_func_call
    result_test("int test()\n{\nreturn 1\n}\ntest()", 
             "int test()\n{\nreturn 1;\n}\nint main()\n{\n{\ntest();\n}\nreturn 0;\n}\n")
  end

  def test_if_stmt
    result_test("if(true){return 0}", 
                "int main()\n{\n{\nif(true){\nreturn 0;\n}\n}\nreturn 0;\n}\n")
  end
end
