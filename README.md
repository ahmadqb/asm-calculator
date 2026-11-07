# x86 Assembly Calculator

A simple command-line calculator written in x86 assembly (MASM) using the Irvine32 library.

*Originally written in January 2026.*

## Features

- Supports `+`, `-`, `*` and `/` on signed integers
- Negative numbers (e.g. `-5+3`, `4*-2`)
- Prints the full equation followed by the result
- Division by zero detection with an error message

## Usage

Type an expression and finish it with `=` or `?`:

```
Enter expression: 12+3*4=
12 + 3 * 4 = +60
```

Notes:

- Expressions are evaluated **left to right**, with no operator precedence (`2+3*4` gives `20`, not `14`).
- Integer division only; the result is truncated.
- Characters other than digits and operators are ignored.

## Build

Requires:

- Windows
- Visual Studio with MASM enabled (Build Customizations > masm)
- The [Irvine32 library](https://asmirvine.com) (not included in this repository)

Build it as an **x86 (Win32)** console project:

1. Add `main.asm` to a new empty C++ project and enable the `masm` build customization.
2. Set the platform to **x86**.
3. Set the include path and library directory to your Irvine32 folder.
4. Add `irvine32.lib;kernel32.lib;user32.lib` to the linker dependencies.
5. Build and run.

## Files

- `main.asm` – the full source code
