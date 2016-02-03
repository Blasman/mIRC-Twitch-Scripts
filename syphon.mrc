;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;; POINTS RAFFLE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON $*:TEXT:/^!syphon\s(\d+|end)$/iS:%mychan: {
  IF ($editorcheck($nick) == true) {
    IF (($2 isnum) && (!%syphon.active)) {
      SET %syphon.active On
      SET %syphon.cost $2
      MSG $chan A $upper($mid(%curname,1,1)) $+ $mid(%curname,2-) Syphon has been started in the channel! The entry fee is %syphon.cost %curname $+ ! The winner will receive all the %curname that are entered into the raffle! To enter, simply type !syphon in chat.
    }
    ELSEIF (($2 == end) && (%syphon.active)) {
      UNSET %syphon.active
      MSG $chan The $upper($mid(%curname,1,1)) $+ $mid(%curname,2-) Syphon is now closed! Good luck to everyone who entered: $entries
      VAR %syphon.total $calc(%syphon.cost * $numtok(%syphon.entries,32))
      VAR %syphon.winner $gettok(%syphon.entries, $rand(1, $numtok(%syphon.entries, 32)), 32)
      .timer.syphon.1 1 6 MSG $chan I am now choosing a winner at random!
      .timer.syphon.2 1 12 MSG $chan Congratulations to %syphon.winner who just won %syphon.total %curname in the $upper($mid(%curname,1,1)) $+ $mid(%curname,2-) Syphon!
      .timer.syphon.3 1 12 ADDPOINTS %syphon.winner %syphon.total
      .timer.syphon.4 1 12 UNSET %syphon.*
    }
  }
}

ON $*:TEXT:/^!syphon$/iS:%mychan: {
  IF ((%syphon.active) && (!$istok(%syphon.entries,$nick,32))) {
    IF ($checkpoints($nick,%syphon.cost) == false) {
      IF (!$($+(%,flood2poor4syphon.,$nick),2)) {
        SET -eu60 %flood2poor4syphon. $+ $nick On
        $wdelay(MSG $nick You do not have %syphon.cost %curname to enter the %curname syphon!  FeelsBadMan)
      }
    }
    ELSE {
      SET %syphon.entries %syphon.entries $nick
      REMOVEPOINTS $nick %syphon.cost
      $wdelay(MSG $nick You have entered %syphon.cost %curname into the %curname syphon!  Good luck!)
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
