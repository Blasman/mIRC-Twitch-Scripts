ON *:CONNECT: {
  IF ($server == tmi.twitch.tv) {
    UNSET %istream.*
    IF ($timer(.istream)) .timer.istream off
  }
}

ON $*:TEXT:/^!istream$/iS:%mychan: {
  IF (($nick isop $chan) && (!$timer(.istream))) {
    .timer.istream 1 60 istream
    MSG %mychan If you're a streamer and want to build your community press 1 now so we can all follow each other! PandaPaw thaiLove PandaPaw
  }
}

ON $*:TEXT:/^1$/iS:%mychan: {
  IF (($timer(.istream)) && (!$istok(%istream.list,$nick,32))) {
    SET -e %istream.list %istream.list $nick
  }
}

alias istream {
  VAR %x = 1
  WHILE (%x <= $numtok(%istream.list,32)) {
    VAR %list %list twitch.tv/ $+ $gettok(%istream.list,%x,32) •
    INC %x
  }
  MSG %mychan A big thank you to everyone for taking the time to follow and support eachother, you all are the best! $left(%list, -1) PandaPaw thaiLove PandaPaw
  UNSET %istream.*
}
