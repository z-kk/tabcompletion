import
  std / [os, strutils, sequtils, unicode, terminal],
  eastasianwidth

const
  stylePrefix = "\e["

proc getSelList(pattern: seq[Rune]): seq[string] =
  ## Get pattern dirs and files
  result = toSeq(($pattern & "*").walkPattern)
  for idx, path in result:
    if path.dirExists:
      result[idx] &= "/"

proc selectNext(list: seq[string], idx: var int) =
  ## Show next file
  let w = list[idx].stringWidth
  stdout.cursorBackward(w)
  stdout.write ' '.repeat(w)
  stdout.cursorBackward(w)
  idx.inc
  if idx > list.high:
    idx = 0
  stdout.write list[idx]

proc selectPrev(list: seq[string], idx: var int) =
  ## Show prev file
  let w = list[idx].stringWidth
  stdout.cursorBackward(w)
  stdout.write ' '.repeat(w)
  stdout.cursorBackward(w)
  idx.dec
  if idx < 0:
    idx = list.high
  stdout.write list[idx]

proc readLineFromStdin*(): string =
  ## Read string from stdin
  template exitSelecting() =
    isSelecting = false
    res = selList[selIdx].toRunes
    pos = res.len
    selIdx = -1
  var
    res: seq[Rune]
    pref = ""
    pos = 0
    isSelecting = false
    selIdx = -1
    selList: seq[string]
  while true:
    let ch = getch()
    case ch.ord
    of 0x00:  # Win-Shift(0x10000)
      continue
    of 0x03:  # ^C
      quit()
    of 0x09:  # TAB
      if isSelecting:
        selList.selectNext(selIdx)
      else:
        selList = res.getSelList
        if selList.len == 0:
          continue
        selIdx = 0
        isSelecting = true
        if res.len > 0:
          stdout.cursorBackward(($res).stringWidth)
        stdout.write(selList[selIdx])
    of 0x0d:  # ENT
      echo ""
      if isSelecting:
        res = selList[selIdx].toRunes
      break
    of 0x1b:  # ESC
      pref = $ch
    of 0x7f, 0x08:  # BS
      if isSelecting:
        exitSelecting()
      if pos == 0:
        continue
      let w = ($res[pos - 1]).stringWidth
      res = res[0..<pos - 1] & res[pos..^1]
      pos.dec
      stdout.cursorBackward(w)
      stdout.write($res[pos..^1] & ' '.repeat(w))
      if w > 1:
        stdout.cursorBackward(w - 1)
      stdout.cursorBackward(($res[pos..^1]).stringWidth + 1)
    else:
      if pref == stylePrefix:
        case ch
        of 'A':  # ^
          if isSelecting:
            selList.selectPrev(selIdx)
        of 'B':  # v
          if isSelecting:
            selList.selectNext(selIdx)
        of 'C':  # >
          if isSelecting:
            exitSelecting()
          if pos < res.len:
            stdout.cursorForward(($res[pos]).stringWidth)
            pos.inc
        of 'D':  # <
          if isSelecting:
            exitSelecting()
          if pos > 0:
            pos.dec
            stdout.cursorBackward(($res[pos]).stringWidth)
        of 'Z':  # S-TAB
          if isSelecting:
            selList.selectPrev(selIdx)
          else:
            selList = res.getSelList
            if selList.len == 0:
              continue
            selIdx = selList.high
            isSelecting = true
            if res.len > 0:
              stdout.cursorBackward(($res).stringWidth)
            stdout.write(selList[selIdx])
        else: discard
        pref = ""
      elif pref & ch == stylePrefix:
        pref.add ch
      else:
        if isSelecting:
          exitSelecting()
        var str = $ch
        for i in 1..<($ch).runeLenAt(0):
          str.add getch()
        if pos < res.len:
          stdout.write(str & $res[pos..^1])
          res = res[0..<pos] & str.toRunes & res[pos..^1]
          pos.inc
          stdout.cursorBackward(($res[pos..^1]).stringWidth)
        else:
          stdout.write(str)
          res &= str.toRunes
          pos.inc
        pref = ""
  return $res

proc readLineFromStdin*(prompt: string): string =
  ## Read string from stdin
  stdout.write(prompt)
  stdout.flushFile
  return readLineFromStdin()
