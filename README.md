# Koona
### A *really* simple programming language

Koona is a simple programing language I'm writing to learn about compiler design. It's written in Ruby, but I'll eventually port it to more permanent C++ code. However, this repository will stick around as an example of a simple compiler.

## What it does
At the moment, Koona will compile a simple syntax into valid C code. What's currently supported:

- Variable declaration
- Function declaration (and function calls)
- Return statements
- If statements
- Integers
- Doubles
- Booleans
- Strings
- Mathematic operations (+, -, \*, /)

A valid `.kn` file:

    int x=3
    x = x+1
    string myString = "this is a string"
    // this is a comment
    int addVal(int var, int val, bool do_add)
    {
      if(do_add)
      {
        return (var + val)
      }
    }
    addVal(x, 2, true)

## Use
To compile a `.kn` file, run: `bin/koona compile *file.kn*`. A C file will be generated (which you can then edit, or compile).

If you want to compile straight to an executible, you can use the `--clang` flag to compile the `.c` file with clang.
