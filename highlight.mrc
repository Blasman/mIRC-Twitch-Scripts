ON *:TEXT:!highlight *:%mychan: {
  IF ($nick isop $chan) {
    VAR %uptime $streamuptime(%streamer)
    WRITE highlights.txt $asctime(mmm d h:nn TT) - %uptime - $2-
    MSG $chan $nick $+ , highlight note has been created at %uptime of the stream.
  }
}

alias -l streamuptime {
  JSONOpen -ud streamuptime https://api.twitch.tv/kraken/streams/ $+ $1 $+ ?client_id=avm4vi7zv0xpjkpi3d4x0qzk8xbrdw8
  IF ($JSON(streamuptime, stream, created_at)) return $duration($calc($ctime - $TwitchTime($JSON(streamuptime, stream, created_at))),2)
  ELSE return ????
  JSONClose streamuptime
}

alias -l TwitchTime {
  if ($regex($1-, /^(\d\d(?:\d\d)?)-(\d\d)-(\d\d)T(\d\d)\:(\d\d)\:(\d\d)(?:(?:Z$)|(?:([+-])(\d\d)\:(\d+)))?$/i)) {
    var %m = $Gettok(January February March April May June July August September October November December, $regml(2), 32), %d = $ord($base($regml(3),10,10)), %o = +0, %t
    if ($regml(0) > 6) %o = $regml(7) $+ $calc($regml(8) * 3600 + $regml(9))
    %t = $calc($ctime(%m %d $regml(1) $regml(4) $+ : $+ $regml(5) $+ : $+ $regml(6)) - %o)
    if ($asctime(zz) !== 0 && $regex($v1, /^([+-])(\d\d)(\d+)$/)) {
      %o = $regml(1) $+ $calc($regml(2) * 3600 + $regml(3))
      %t = $calc(%t + %o )
    }
    return %t
  }
}
