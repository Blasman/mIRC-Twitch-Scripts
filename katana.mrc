;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;; A_COLDER_VISION'S KATANA GAME ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; ********** SET A DEFAULT PAYOUT FIRST BY USING !KATANAPAYOUT **********

ON $*:TEXT:/^!katanapayout(\s\d+)?$/iS:%mychan: {
  IF ($nick isop $chan) {
    IF ($2) {
      SET %katanahonor.default $2
      MSG $chan The default payout for !katana and !spin has been set to %katanahonor.default %curname $+ .
    }
    ELSE MSG $chan The default payout for !katana and !spin is set to %katanahonor.default %curname $+ .
  }
}

ON $*:TEXT:/^!katana(\s\d+)?$/iS:%mychan: {
  IF ($nick isop $chan) {
    IF ($2) SET %katana.honor $2
    ELSE SET %katana.honor %katanahonor.default
    MSG $chan SPIN THE KATANA: In three minutes, %botname will spin the katana, and whoever it points to will receive %katana.honor %curname $+ . Of course, there's a catch. The winner must commit !seppuku in order to receive the %curname $+ . Are you willing to be timed out for two minutes? (must be ACTIVE in chat to participate)
    .timer.katana 1 180 katanaspin
  }
}

ON $*:TEXT:/^!spin(\s\d+)?$/iS:%mychan: {
  IF ($nick isop $chan) {
    IF ($2) SET %katana.honor $2
    ELSE SET %katana.honor %katanahonor.default
    katanaspin
  }
}

ON *:TEXT:!seppuku:%mychan: {
  IF ($nick !isop $chan) INC %seppuku.count
  IF ($nick == %katana.spin) {
    .timer.katana.fail.* off
    IF ($nick !isop $chan) {
      MSG $chan %katana.spin has commited Seppuku, resulting in banishment from chat for two minutes!  To date, seppuku has been commited %seppuku.count times!  %katana.spin has recieved %katana.honor %curname for their sacrifice!
      MSG $chan .timeout $nick 120
    }
    ELSEIF ($nick isop $chan) MSG $chan Doh! $nick attempted Seppuku, but forgot to remove the Mod Armor. $nick $+ 's Katana just snaps in half during the attempt. Poor $nick $+ !!!  %katana.spin has recieved %katana.honor %curname for their attempted sacrifice!
    ADDPOINTS $nick %katana.honor
    UNSET %katana.*
  }
  ELSEIF ($nick !isop $chan) {
    MSG $chan $nick has commited Seppuku, resulting in banishment from chat for two minutes!  To date, seppuku has been commited %seppuku.count times!
    MSG $chan .timeout $nick 120
  }
  ELSEIF ($nick isop $chan) MSG $chan Doh! $nick attempted Seppuku, but forgot to remove the Mod Armor. $nick $+ 's Katana just snaps in half during the attempt. Poor $nick $+ !!!
}

alias katanaspin {
  VAR %x = 1
  WHILE ($hget(activeusers, %x).item != $null) {
    VAR %nick $v1
    IF ((%nick ison %mychan) && ($calc($hget(activeusers, %nick) + 180) >= %activetime) && (%nick != %streamer)) VAR %activelist %activelist %nick
    INC %x
  }
  IF (%activelist != $null) {
    SET %katana.spin $gettok(%activelist, $rand(1, $numtok(%activelist, 32)), 32)
    MSG %mychan The Katana has been spun, and it's pointing to %katana.spin $+ ! %katana.spin $+ , you must commit !seppuku within the next 2 minutes to claim your %katana.honor %curname $+ !
    .timer.katana.fail.1 1 90 MSG %mychan %katana.spin $+ , you still havn't committed !seppuku!  %katana.spin $+ , you only have 30 seconds left to commit !seppuku to claim your %katana.honor %curname $+ !
    .timer.katana.fail.2 1 120 MSG %mychan %katana.spin $+ , you did not commit !seppuku within 2 minutes to claim your %katana.honor $curname $+ !  Too bad, %katana.spin $+ !  acvRAGE
    .timer.katana.fail.3 1 120 UNSET %katana.*
  }
  ELSE MSG %mychan The Katana has been spun, but there is no one around to claim %curname $+ !  BibleThump
}
