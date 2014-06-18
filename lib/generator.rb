module Koona
  class Generator
    def generate(ast)
      prog = ""
      prog += 
<<eos
#include <stdio.h>
eos

ObjectSpace.each_object do |o|
  if o.class == NFunctionDeclaration
    prog += o.generate
  end
end

prog +=
<<eos
int main(){
eos

prog += ast.generate +
<<eos
  
  return 0;
}
eos
      prog
    end
  end
end
