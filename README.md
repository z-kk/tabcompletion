# tabcompletion [![nimble](https://raw.githubusercontent.com/yglukhov/nimble-tag/master/nimble.png)](https://github.com/yglukhov/nimble-tag)
Nim stdin tab completion library

## Usage

### readLineFromStdin\*

```nim
proc readLineFromStdin*(): string =
```

```nim
proc readLineFromStdin*(prompt: string): string =
```

Reads a line from stdin.

It's the same as rdstdin.readLineFromStdin() with tab completion.
