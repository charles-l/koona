class Generator
  def generate(ast)
    prog = 
<<-eos
#require <stdio.h>
eos

    # Generate functions here

prog +=
<<-eos
int main(){
eos
    prog += ast.generate
    prog +=
<<-eos
  
  return 0;
}
eos
  end
end
