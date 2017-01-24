ON $*:TEXT:/^!date(\s@?\w+)?$/iS:#: {
  IF ($nick isop $chan) {
    IF (!$2) MSG $chan $followdate($nick)
    ELSE MSG $chan $IIF($twitch_name($remove($2,@)) != $null,$followdate($v1),$nick $+ $chr(44) $remove($2,@) is not a valid user on Twitch. FailFish)
  }
  ELSEIF ((!$($+(%,followdate_CD.,$nick),2)) && (!$2)) {
    SET -eu60 %followdate_CD. $+ $nick On
    MSG $chan $followdate($nick)
  }
}

alias followdate {
  IF (%fd == 1000) %fd = 0
  INC %fd
  VAR %nick $1
  JSONOpen -uw date $+ %fd https://api.twitch.tv/kraken/users/ $+ %nick $+ /follows/channels/ $+ %streamer $+ ?nocache= $+ $ticks
  JSONHttpHeader date $+ %fd Client-ID avm4vi7zv0xpjkpi3d4x0qzk8xbrdw8
  JSONHttpFetch date $+ %fd
  VAR %time $JSON(date $+ %fd, created_at).value
  IF ($v1 != $null) VAR %date $TwitchTime(%time)
  VAR %x %nick $IIF(%time != $null,has been following this channel for $DateXpander($calc($ctime - %date)) since $asctime(%date,mmm dd yyyy) $+ .,is not following the channel.)
  JSONClose date $+ %fd
  RETURN %x
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
