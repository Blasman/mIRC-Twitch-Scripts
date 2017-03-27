;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;; POINTS RAFFLE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON $*:TEXT:/^!syphon\s(end|\d+(\s\d+\s\d+)?)$/iS:%mychan: {
  IF ($isEditor) {
    IF (($2 isnum) && (!%syphon.active)) {
      SET %syphon.active On
      SET %syphon.cost $2
      IF (($3) && ($4)) {
        SET %syphon.max.entries $3
        SET %syphon.timer $4
        VAR %syphon.msg The syphon will automatically close after %syphon.max.entries entries or $IIF($regex($calc($4 / 30),^\d+$),$calc($4 / 60) minutes,$4 seconds) $+ $chr(44) whichever comes first.
      }
      MSG $chan KAPOW A $upper($mid(%curname,1,1)) $+ $mid(%curname,2-) Syphon has been started in the channel! The entry fee is %syphon.cost %curname $+ ! The winner will receive all the %curname that are entered into the raffle! To enter, simply type !syphon in chat. %syphon.msg
      IF ($4) .timer.syphon.end 1 %syphon.timer endsyphon
    }
    ELSEIF (($2 == end) && (%syphon.active)) endsyphon
  }
}

ON $*:TEXT:/^!syphon$/iS:%mychan: {
  IF ((%syphon.active) && (!$istok(%syphon.entries,$nick,32))) {
    IF ($GetPoints($nick) < %syphon.cost) {
      IF (!$($+(%,flood2poor4syphon.,$nick),2)) {
        SET -eu60 %flood2poor4syphon. $+ $nick On
        $wdelay(MSG $nick You do not have %syphon.cost %curname to enter the %curname syphon!  FeelsBadMan)
      }
    }
    ELSE {
      SET %syphon.entries %syphon.entries $nick
      REMOVEPOINTS $nick %syphon.cost
      $wdelay(MSG $nick You have entered %syphon.cost %curname into the %curname syphon!  Good luck!)
      IF ((%syphon.max.entries) && ($numtok(%syphon.entries,32) >= %syphon.max.entries)) endsyphon
    }
  }
}

alias -l entries {
  VAR %x = 1
  WHILE ($gettok(%syphon.entries,%x,32)) {
    VAR %names %names $v1 $+ $chr(44)
    INC %x
  }
  RETURN $left($sorttok(%names,32,a),-1)
}

alias -l endsyphon {
  IF ($timer(.syphon.end)) .timer.syphon.end off
  UNSET %syphon.active
  IF ($numtok(%syphon.entries,32) == 0) { MSG %mychan Wow! Nobody entered the %curname syphon! Nobody wins! FeelsBadMan | UNSET %syphon.* }
  ELSEIF ($numtok(%syphon.entries,32) == 1) { MSG %mychan Wow! Only %syphon.entries entered the %curname syphon! %syphon.entries just got their %syphon.cost %curname back! | ADDPOINTS %syphon.entries %syphon.cost | UNSET %syphon.* }
  ELSE {
    MSG %mychan The $upper($mid(%curname,1,1)) $+ $mid(%curname,2-) Syphon is now closed! Good luck to all $numtok(%syphon.entries,32) people who entered: $entries
    VAR %syphon.total $calc(%syphon.cost * $numtok(%syphon.entries,32))
    VAR %syphon.winner $gettok(%syphon.entries, $rand(1, $numtok(%syphon.entries, 32)), 32)
    .timer.syphon.1 1 6 MSG %mychan I am now choosing a winner at random!
    .timer.syphon.2 1 12 MSG %mychan Congratulations to %syphon.winner who just won %syphon.total %curname in the $upper($mid(%curname,1,1)) $+ $mid(%curname,2-) Syphon!
    .timer.syphon.3 1 12 ADDPOINTS %syphon.winner %syphon.total
    .timer.syphon.4 1 12 UNSET %syphon.*
  }
}
