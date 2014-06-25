module Koona
  class Token
    def initialize(value, filename, lineno)
      @value = value
      @filename = filename
      @lineno = lineno
    end
    attr_reader :value, :filename, :lineno
  end

  class Lexer
    require 'strscan'
    attr_reader :lineno
    attr_reader :filename

    def action &block
      yield
    end

    def scan_file(filename)
      @filename = filename
      File.open(filename, "r") do |f|
        scan_evaluate f.read
      end
    end
    def scan_evaluate (str)
      @rex_tokens = []
      @lineno = 1
      ss = StringScanner.new(str)
      state = nil
      until ss.eos?
        text = ss.peek(1)
        @lineno += 1 if text == "\n"
        case state
        when nil
          case
          when (text = ss.scan(/[\ \t\n]/));

          when (text = ss.scan(/\/\/.*$/));

          when (text = ss.scan(/return/))
            @rex_tokens.push action {[:TRETURN, Token.new(text, @filename, @lineno)]}

          when (text = ss.scan(/call/))
            @rex_tokens.push action {[:TCALL, Token.new(text, @filename, @lineno)]}

          when (text = ss.scan(/if/))
            @rex_tokens.push action {[:TIF, Token.new(text, @filename, @lineno)]}

          when (text = ss.scan(/else/)) #TODO add support for if statements
            @rex_tokens.push action {[:TELSE, Token.new(text, @filename, @lineno)]}

          when (text = ss.scan(/true/))
            @rex_tokens.push action {[:TTRUE, Token.new(text, @filename, @lineno)]}

          when (text = ss.scan(/false/))
            @rex_tokens.push action {[:TFALSE, Token.new(text, @filename, @lineno)]}

          when (text = ss.scan(/[a-zA-Z_][a-zA-Z0-9_]*/))
            @rex_tokens.push action {[:TIDENTIFIER, Token.new(text, @filename, @lineno)]}

          when (text = ss.scan(/[0-9]+\.[0-9]*/))
            @rex_tokens.push action {[:TFLOAT, Token.new(text.to_f, @filename, @lineno)]}

          when (text = ss.scan(/[0-9]+/))
            @rex_tokens.push action {[:TINTEGER, Token.new(text.to_i, @filename, @lineno)]}

          when (text = ss.scan(/==/))
            @rex_tokens.push action {[:TCEQ, Token.new(text, @filename, @lineno)]}

          when (text = ss.scan(/\!=/))
            @rex_tokens.push action {[:TCNE,Token.new(text, @filename, @lineno)]}

          when (text = ss.scan(/\</))
            @rex_tokens.push action {[:TCLT,Token.new(text, @filename, @lineno)]}

          when (text = ss.scan(/\<=/))
            @rex_tokens.push action {[:TCLE,Token.new(text, @filename, @lineno)]}

          when (text = ss.scan(/\>/))
            @rex_tokens.push action {[:TCGT,Token.new(text, @filename, @lineno)]}

          when (text = ss.scan(/\>=/))
            @rex_tokens.push action {[:TCGE,Token.new(text, @filename, @lineno)]}

          when (text = ss.scan(/=/))
            @rex_tokens.push action {[:TEQUAL, Token.new(text, @filename, @lineno)]}

          when (text = ss.scan(/\(/))
                @rex_tokens.push action {[:TLPAREN,Token.new(text, @filename, @lineno)]}

          when (text = ss.scan(/\)/))
            @rex_tokens.push action {[:TRPAREN,Token.new(text, @filename, @lineno)]}

          when (text = ss.scan(/\{/))
            @rex_tokens.push action {[:TLBRACE,Token.new(text, @filename, @lineno)]}

          when (text = ss.scan(/\}/))
            @rex_tokens.push action {[:TRBRACE,Token.new(text, @filename, @lineno)]}

          when (text = ss.scan(/\./))
            @rex_tokens.push action {[:TDOT,Token.new(text, @filename, @lineno)]}

          when (text = ss.scan(/\,/))
            @rex_tokens.push action {[:TCOMMA,Token.new(text, @filename, @lineno)]}

          when (text = ss.scan(/\+/))
            @rex_tokens.push action {[:TPLUS, Token.new(text, @filename, @lineno)]}

          when (text = ss.scan(/\-/))
            @rex_tokens.push action {[:TMINUS,Token.new(text, @filename, @lineno)]}

          when (text = ss.scan(/\*/))
            @rex_tokens.push action {[:TMUL,Token.new(text, @filename, @lineno)]}

          when (text = ss.scan(/\//))
            @rex_tokens.push action {[:TDIV,Token.new(text, @filename, @lineno)]}

          when (text = ss.scan(/".*"/))
            @rex_tokens.push action {[:TSTRING,Token.new(text, @filename, @lineno)]}

          when (text = ss.scan(/./))
            @rex_tokens.push action { return "Unexpected character!"}

          else
            text = ss.string[ss.pos .. -1]
            raise StandardError, "can not match: '" + text + "'"
          end
        else
          raise StandardError, "undefined state: '" + state.to_s + "'"
        end
      end
      @rex_tokens
    end
  end
end
