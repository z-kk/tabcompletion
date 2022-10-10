import unittest

import
  std / osproc

import tabcompletion
test "read line":
  discard execCmd "touch /tmp/readlinetest"
  discard execCmd "touch /tmp/readlinetest1"
  discard execCmd "touch /tmp/readlinetest2"
  discard execCmd "touch /tmp/readlinetest_a"
  discard execCmd "touch /tmp/readlinetest_b"
  check "input '/tmp/readlinetest_b': ".readLineFromStdin == "/tmp/readlinetest_b"
