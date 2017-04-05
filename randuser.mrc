alias randuser {
  VAR %x = 1
  WHILE ($hget(activeusers, %x).item != $null) {
    VAR %nick $v1
    IF (!$1) { IF ((%nick ison %mychan) || ($calc($hget(activeusers, %nick) + 90) >= %activetime)) VAR %activelist %activelist %nick }
    ELSEIF ($1 == other) { IF (((%nick ison %mychan) || ($calc($hget(activeusers, %nick) + 90) >= %activetime)) && (%nick != $nick)) VAR %activelist %activelist %nick }
    ELSEIF ($1 == notme) { IF (((%nick ison %mychan) || ($calc($hget(activeusers, %nick) + 90) >= %activetime)) && (%nick != %streamer)) VAR %activelist %activelist %nick }
    ELSEIF ($1 == othernotme) { IF (((%nick ison %mychan) || ($calc($hget(activeusers, %nick) + 90) >= %activetime)) && (%nick != %streamer) && (%nick != $nick)) VAR %activelist %activelist %nick }
    ELSEIF ($1 == list) { IF ((%nick ison %mychan) || ($calc($hget(activeusers, %nick) + 90) >= %activetime)) VAR %activelist %activelist %nick }
    ELSE BREAK
    INC %x
  }
  IF ($1 == list) RETURN %activelist
  ELSE {
    VAR %randuser $gettok(%activelist, $rand(1, $numtok(%activelist, 32)), 32)
    IF (%randuser != $null) RETURN %randuser
    ELSE RETURN $nick
  }
}
