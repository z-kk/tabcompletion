import unittest

import
  std / [os, strformat]

import tabcompletion
test "read line":
  var path = getTempDir() / "readlinetest"
  var samples: seq[tuple[path: string, exist: bool]]
  samples.add((path, path.fileExists))
  samples.add((path & "1", (path & "1").fileExists))
  samples.add((path & "2", (path & "2").fileExists))
  samples.add((path & "_a", (path & "_a").fileExists))
  samples.add((path & "_b", (path & "_b").fileExists))
  for s in samples:
    if not s.exist:
      s.path.writeFile("")

  path &= "_b"
  check "input '{path}': ".fmt.readLineFromStdin == path

  for s in samples:
    if not s.exist:
      s.path.removeFile
