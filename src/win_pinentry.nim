
# =======
# Imports
# =======

import os
import rdstdin
import unicode
import strutils
import sequtils

import winim/lean
import winim/inc/winbase
import winim/inc/wincred

# =====
# Types
# =====

type
  ReplyType = enum
    Okay = "OK",
    Data = "D",
    Error = "ERR"

# =========
# Functions
# =========

proc offset(base: ByteAddress, index: int, size: int): pointer =
  let length = index * size
  let src = base + length
  return cast[pointer](src)

proc reply(t: ReplyType) =
  echo "$1" % [$t]

proc reply(t: ReplyType, info: string) =
  echo "$1 $2" % [$t, info]

proc getUserPin(key: string = getEnv("WIN_PINENTRY_CREDENTIAL_NAME", "GPG Private Key Password")): string =
  let cred_name = LPCWSTR(key)
  let cred_type = DWORD(CRED_TYPE_GENERIC)
  let cred_flags = DWORD(0)
  var value_init = CREDENTIALW()
  var value = cast[ptr PCREDENTIALW](unsafeAddr value_init)
  let status = CredReadW(cred_name, cred_type, cred_flags, value)
  let found_credential = winimConverterBOOLToBoolean(status)
  if not found_credential:
    Error.reply("Unable to find credential item with name matching")
    return ""
  var password = ""
  let blob_length = int(value.CredentialBlobSize / sizeof(WCHAR))
  let base = cast[ByteAddress](value.CredentialBlob)
  var index = 0
  while index < blob_length:
    let src = base.offset(index, sizeof(WCHAR))
    var data: WCHAR
    copyMem(addr data, src, sizeof(data))
    let rune = Rune(data).toUTF8()
    password.add(rune)
    inc(index)
  return password

# ================
# Main Entry Point
# ================

Okay.reply("Your orders please")
var input: TaintedString
while readLineFromStdIn("", input):
  let response = strutils.split(input, maxsplit = 1).mapIt(strutils.strip(it))
  if response.len == 0:
    continue
  let command = response[0].toLowerAscii()
  case command
  of "getpin":
    let pin = getUserPin()
    if pin.len == 0:
      Error.reply()
    else:
      Data.reply(pin)
      Okay.reply()
  of "getinfo":
    if response.len == 1:
      Error.reply()
      continue
    let subcmd = strutils.split(response[1], maxsplit = 1).mapIt(strutils.strip(it))
    case subcmd[0]
    of "pid":
      let pid = $GetCurrentProcessId()
      Data.reply(pid)
    else:
      Okay.reply()
  of "bye":
    Okay.reply("closing connection")
    break
  else:
    Okay.reply()
quit(QuitSuccess)
