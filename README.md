# tabcompletion
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
