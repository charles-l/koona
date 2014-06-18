# Koona
### A *really* simple programming language
**NOTE: I've been developing in Ruby 1.8, because rex doesn't support the latest versions of Ruby. I would recommend using [RVM](https://rvm.io/) so you can easily switch between versions of Ruby.**

Koona is a simple programing language I'm writing to learn about compiler design. It's written in Ruby, but I'll eventually port it to more permanent C++ code.

## What it does
At the moment, Koona will compile a simple syntax into valid C code. What's currently supported:

- Variable declaration
- Function declaration (and function calls)
- Integers
- Doubles
- Mathematic operations (+, -, \*, /)

A valid `.kn` file:

    int x=3
    x = x+1
    // this is a comment
    int addVal(int var, int val)
    {
      return (var + val)
    }
    addVal((x), 2)

## Use
To compile a `.kn` file, run: `bin/koona *file.kn*`. A C file will be generated (which you can then edit, or compile).

## TODO
- Either update Rex, or write a new lexer. It'll make Koona compatible with newer versions of Ruby.

## Known bugs
- You have to wrap variables in parenthesise when using in a function call (dunno why, but it's a bug with the parser somewhere)
