# Koona
### A *really* simple compiler

Koona is a simple compiler I wrote a few years ago to learn about compiler design. It's over-engineered and poorly written (since I was still quite a noob when I initially wrote it), so forgive code quality in the parsing/lexing/code generation. If I get some free time, I'll clean it up and make it easier to understand.

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
- Garbage collection
- FFI
- Mathematic operations (+, -, \*, /)

A valid `.kn` file:

    int x=3
    x = x+1
    string myString = "this is a string"

    // Call an external C function:
    call printf("test")

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
