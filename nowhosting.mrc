RAW *:*: {
  IF (($nick == tmi.twitch.tv) && (HOSTTARGET isin $rawmsg) && (%mychan isin $rawmsg)) {
    tokenize 32 $rawmsg
    IF ($chr(45) !isin $4) {
      SET %current.host $twitch_name($remove($4, :))
      IF (%current.host != $null) && ($5 isnum 2-) MSG %mychan We are now hosting %current.host with $5 active viewers. %current.host is playing $currentgame(%current.host) for $viewers(%current.host) viewers. Uptime: $streamuptime(%current.host) $+ . Go visit them at twitch.tv/ $+ %current.host and say hello, but also remember to keep your name HERE in chat to earn extra %curname $+ !
      ELSEIF (%current.host != $null) && ($5 isnum 0-1) MSG %mychan We are now hosting %current.host who is playing $currentgame(%current.host) for $viewers(%current.host) viewers. Uptime: $streamuptime(%current.host) $+ . Go visit them at twitch.tv/ $+ %current.host and say hello, but also remember to keep your name HERE in chat to earn extra %curname $+ !
    }
  }
}

alias currentgame {
  JSONOpen -ud currentgame https://api.twitch.tv/kraken/channels/ $+ $1 $+ ?client_id=avm4vi7zv0xpjkpi3d4x0qzk8xbrdw8
  IF ($json(currentgame, game)) return $v1
  ELSE return ????
  JSONClose currentgame
}

alias viewers {
  JSONOpen -ud viewers https://api.twitch.tv/kraken/streams/ $+ $1 $+ ?client_id=avm4vi7zv0xpjkpi3d4x0qzk8xbrdw8
  IF ($json(viewers, stream, viewers)) return $v1
  ELSE return ????
  JSONClose viewers
}

alias streamuptime {
  JSONOpen -ud uptime https://api.twitch.tv/kraken/streams/ $+ $1 $+ ?client_id=avm4vi7zv0xpjkpi3d4x0qzk8xbrdw8
  IF ($JSON(uptime, stream, created_at)) return $duration($calc($ctime - $TwitchTime($JSON(uptime, stream, created_at))),2)
  ELSE return ????
  JSONClose streamuptime
}

alias TwitchTime {
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
