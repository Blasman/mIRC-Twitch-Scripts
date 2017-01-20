/*
*******************************************************************************
********************************* BLASBOT *************************************
***************************** PAYACTIVE SCRIPT ********************************
*************************** CREATED BY BLASMAN13 ******************************
*************************** TWITCH.TV/BLASMAN13 *******************************
*******************************************************************************
*/

; DOCUMENTATION: https://docs.google.com/document/d/1AT49IMOmZXtkQQtOQpjEIBEAwrsZn090v6GL1hjyMRo/

ON *:LOAD: {
  IF (!%activetime) SET %activetime 900
  IF (!$hget(activeusers)) HMAKE activeusers
  IF (!%paylimit) SET %paylimit 1000000
  IF (!%commonbots) SET %commonbots moobot nightbot revlobot vivbot xanbot wizebot
}

ON *:CONNECT: IF (($server == tmi.twitch.tv) && (!$hget(activeusers))) HMAKE activeusers

ON $*:TEXT:/^!set\sactivetime\s\d+$/iS:%mychan: IF ($ModCheck) { SET %activetime $3 | MSG $chan The time since last user activity to be considered an active user has been set to $3 seconds. }

ON $*:TEXT:/^!paylimit($|\s\d+)/iS:%mychan: {
  IF ($ModCheck) {
    IF (!$2) MSG $chan The current max amount for !payactive is %paylimit %curname $+ .
    ELSEIF ($2) {
      SET %paylimit $floor($2)
      MSG $chan The max amount for !payactive has been set to %paylimit %curname $+ .
    }
  }
}

ON $*:TEXT:/^!payactive(x)?\s/iS:%mychan: {
  IF (($regex($2,^[1-9](\d+)?(-[1-9](\d+)?)?$)) && ($editorcheck($nick) == true)) {
    IF (($1 == !payactivex) && (!$regex($3,^[1-9](\d+)?(\.\d+)?(\w+)?(-[1-9](\d+)?(\.\d+)?(\w+)?)?$))) halt
    IF (($regex($2,^(\d+)-(\d+)$)) && (($regml(1) >= $regml(2)))) halt
    IF (($regex(pa_timer,$3,^(((\d+(\.\d+)?(\w+)?)))-(((\d+(\.\d+)?(\w+)?)))$)) && (($getsecs($regml(pa_timer,1)) >= $getsecs($regml(pa_timer,6))))) halt
    IF ($IIF($regex(pa_limit,$2,^(((\d+(\.\d+)?(\w+)?)))-(((\d+(\.\d+)?(\w+)?)))$),$getsecs($regml(pa_limit,6)),$2) > %paylimit) {
      MSG $chan $nick $+ , that amount is above the max limit of %paylimit %curname for payactive's.
      halt
    }
    IF (!$3) VAR %timer 0
    ELSE VAR %timer $IIF($regex(pa_timer,$3,^(((\d+(\.\d+)?(\w+)?)))-(((\d+(\.\d+)?(\w+)?)))$),$rand($getsecs($regml(pa_timer,1)),$getsecs($regml(pa_timer,6))),$getsecs($3))
    $IIF($1 == !payactive,payactive_start,payactivex_start) $IIF($regex($2,^(\d+)-(\d+)?$),$rand($regml(1),$regml(2)),$2) %timer command
  }
}

ON $*:TEXT:/^!payauto(x)?(\s|$)/iS:%mychan: {
  IF ($editorcheck($nick) == true) {
    IF (($regex($2,^[1-9](\d+)?(-[1-9](\d+)?)?$)) && ($regex($3,^\d+(\.\d+)?(\w+)?(-[1-9](\d+)?(\.\d+)?(\w+)?)?$)) && ($regex($4,^[1-9](\d+)?(\.\d+)?(\w+)?(-[1-9](\d+)?(\.\d+)?(\w+)?)?$))) {
      IF (($1 == !payautox) && (!$regex($3,^[1-9](\d+)?(\.\d+)?(\w+)?(-[1-9](\d+)?(\.\d+)?(\w+)?)?$))) halt
      IF (($regex($2,^(\d+)-(\d+)$)) && (($regml(1) >= $regml(2)))) halt
      IF (($regex(3,$3,^(((\d+(\.\d+)?(\w+)?)))-(((\d+(\.\d+)?(\w+)?)))$)) && (($getsecs($regml(3,1)) >= $getsecs($regml(3,6))))) halt
      IF (($regex(4,$4,^(((\d+(\.\d+)?(\w+)?)))-(((\d+(\.\d+)?(\w+)?)))$)) && (($getsecs($regml(4,1)) >= $getsecs($regml(4,6))))) halt
      IF ($IIF($regex(pa_limit,$2,^(((\d+(\.\d+)?(\w+)?)))-(((\d+(\.\d+)?(\w+)?)))$),$getsecs($regml(pa_limit,6)),$2) > %paylimit) {
        MSG $chan $nick $+ , that amount is above the max limit of %paylimit %curname for payactive's.
        halt
      }
      UNSET %pa_*
      SET %pa_amount $IIF($regex(pa_amount,$2,^(\d+)-(\d+)?$),$getsecs($regml(pa_amount,1)) $+ - $+ $getsecs($regml(pa_amount,2)),$getsecs($2))
      SET %pa_timer $IIF($regex(pa_timer,$3,^(((\d+(\.\d+)?(\w+)?)))-(((\d+(\.\d+)?(\w+)?)))$),$getsecs($regml(pa_timer,1)) $+ - $+ $getsecs($regml(pa_timer,6)),$getsecs($3))
      SET %pa_frequency $IIF($regex(pa_freq,$4,^(((\d+(\.\d+)?(\w+)?)))-(((\d+(\.\d+)?(\w+)?)))$),$getsecs($regml(pa_freq,1)) $+ - $+ $getsecs($regml(pa_freq,6)),$getsecs($4))
      IF ($1 == !payautox) SET %pa_x On
      IF ($regex($5,^(\d+)$)) SET %pa_repeat $regml(1)
      ELSE SET %pa_forever On
      VAR %msg
      IF (%pa_repeat) VAR %msg $IIF($regex(%pa_frequency,^\d+$),for the next $ext_dur($calc(%pa_frequency * %pa_repeat)) for a total of %pa_repeat times.,$null)
      IF ($regex(pa_freq,$4,^(((\d+(\.\d+)?(\w+)?)))-(((\d+(\.\d+)?(\w+)?)))$)) MSG $chan KAPOW Every $ext_dur($getsecs($regml(pa_freq,1))) to $ext_dur($getsecs($regml(pa_freq,6))) there will be an automatic $IIF($1 == !payauto,!PayActive,!PayActiveX) %pa_amount %pa_timer %msg
      ELSE MSG $chan KAPOW Every $ext_dur($getsecs($4)) $+ , there will be an automatic $IIF($1 == !payauto,!PayActive,!PayActiveX) %pa_amount %pa_timer %msg
      payauto_queue
    }
    ELSEIF (($0 == 2) && ($2 == off)) {
      IF ($timer(.payauto)) {
        .timer.payauto off
        MSG $chan The automatic $IIF(%pa_x,!PayActiveX,!PayActive) has been turned off.
        UNSET %pa_*
      }
      ELSE MSG $chan There is no !payauto currently active.
    }
    ELSEIF ((!$2) && ($timer(.payauto))) {
      IF ($regex(pa_freq,%pa_frequency,^(((\d+(\.\d+)?(\w+)?)))-(((\d+(\.\d+)?(\w+)?)))$)) VAR %freq $ext_dur($getsecs($regml(pa_freq,1))) to $ext_dur($getsecs($regml(pa_freq,6)))
      ELSE VAR %freq $ext_dur($getsecs(%pa_frequency))
      IF (%pa_repeat) VAR %msg $IIF($regex(%pa_frequency,^\d+$),for the next $ext_dur($calc(%pa_frequency * %pa_repeat)) for a total of %pa_repeat more times.,$null)
      ELSE VAR %msg
      MSG $chan The !PayAuto is currently active. Every %freq $+ , there is an automatic $IIF(%pa_x,!PayActiveX,!PayActive) %pa_amount %pa_timer %msg
    }
    ELSE MSG $chan $nick $+ , use !payauto [AMOUNT of %curname $+ ] [TIMER OF !payactive] [HOW OFTEN the !payactive] [OPTIONAL: HOW MANY TIMES to keep repeating the !payactive] ••• To turn off the !payauto, type !payauto off
  }
}

alias payauto_queue {
  VAR %amount $IIF($regex(%pa_amount,^(\d+)-(\d+)?$),$rand($regml(1),$regml(2)),%pa_amount)
  VAR %timer $IIF($regex(%pa_timer,^(\d+)-(\d+)?$),$rand($regml(1),$regml(2)),%pa_timer)
  VAR %frequency $IIF($regex(%pa_frequency,^(\d+)-(\d+)?$),$rand($regml(1),$regml(2)),%pa_frequency)
  .timer.payauto 1 %frequency payauto %amount %timer
}

alias payauto {
  $IIF(%pa_x,payactivex_start,payactive_start) $1 $2 auto
  IF (%pa_forever) payauto_queue
  ELSE {
    DEC %pa_repeat
    IF (%pa_repeat) payauto_queue
    ELSE UNSET %pa_*
  }
}

alias payactive_start {
  IF ($hget(payactivex_command)) HFREE payactivex_command
  IF ($2 == 0) payactive $1 reg
  ELSE {
    MSG %mychan KAPOW Attention all lurkers! In $ext_dur($2) $+ , everyone who has been chatting in the previous $ext_dur(%activetime) from that point will receive $1 %curname $+ !
    .timer.payactive. $+ $IIF($3 == command,command,auto) 1 $2 payactive $1 $3 reg
  }
}

alias payactivex_start {
  IF (($3 == command) && (!$hget(payactivex_command))) HMAKE payactivex_command
  ELSEIF (($3 == auto) && (!$hget(payactivex_auto))) HMAKE payactivex_auto
  MSG %mychan KAPOW Attention all lurkers! In $ext_dur($2) $+ , everyone who has been chatting in the previous $ext_dur($2) from that point will receive $1 %curname $+ !
  .timer.payactivex. $+ $IIF($3 == command,command,auto) 1 $2 payactive $1 $3 x
}

alias payactive {
  VAR %x = 1
  IF (($2 == reg) || ($3 == reg)) VAR %htable activeusers
  ELSEIF ($3 == x) {
    IF ($2 == command) VAR %htable payactivex_command
    ELSEIF ($2 == auto) VAR %htable payactivex_auto
  }
  WHILE ($hget(%htable, %x).item != $null) {
    VAR %nick $v1
    IF ((%nick != %streamer) && ((%nick ison %mychan) || ($calc($hget(%htable, %nick) + 90) >= %activetime))) VAR %paylist %paylist %nick
    INC %x
  }
  IF ((%htable == payactivex_command) && ($hget(payactivex_command))) HFREE payactivex_command
  ELSEIF ((%htable == payactivex_auto) && ($hget(payactivex_auto))) HFREE payactivex_auto
  IF (%paylist == $null) MSG %mychan There are no active users to give $1 %curname to!  BibleThump
  ELSE {
    VAR %x = 1
    WHILE ($gettok(%paylist, %x, 32) != $null) {
      ADDPOINTS $v1 $1
      INC %x
    }
    VAR %paylist $sorttok(%paylist, 32, a)
    VAR %x = 1
    WHILE ($gettok(%paylist, %x, 32) != $null) {
      VAR %sortlist %sortlist $v1 $+ $chr(44)
      INC %x
    }
    MSG %mychan Successfully paid out $1 %curname to all of the following $numtok(%sortlist, 32) active users: $left(%sortlist, -1)
  }
}

alias getsecs {
  IF ($regex($1,\d+)) {
    VAR %result
    IF ($regex($1,(\d+)(s|$))) VAR %result $calc($regml(1))
    IF ($regex($1,((\d+)(\.\d+)?)m)) VAR %result $calc($regml(1) * 60 + %result)
    IF ($regex($1,((\d+)(\.\d+)?)h)) VAR %result $calc($regml(1) * 3600 + %result)
    IF ($regex($1,((\d+)(\.\d+)?)d)) VAR %result $calc($regml(1) * 86400 + %result)
    RETURN $round(%result,0)
  }
}

alias ext_dur {
  VAR %result $left($replacex($duration($1),wks,$chr(32) weeks $+ $chr(44),wk,$chr(32) week $+ $chr(44),days,$chr(32) days $+ $chr(44),day,$chr(32) day $+ $chr(44),hrs,$chr(32) hours $+ $chr(44),hr,$chr(32) hour $+ $chr(44),mins,$chr(32) minutes $+ $chr(44),min,$chr(32) minute $+ $chr(44),secs,$chr(32) seconds $+ $chr(44),sec,$chr(32) second $+ $chr(44)),-1)
  IF ($numtok(%result,32) > 2) RETURN $replace(%result,$gettok(%result,$calc($numtok(%result,32) - 2),32),$replace($gettok(%result,$calc($numtok(%result,32) - 2),32),$chr(44),$chr(32) and))
  ELSE RETURN %result
}

ON *:TEXT:*:%mychan:IF (($nick != twitchnotify) && ($nick != $me) && (!$istok(%commonbots,$nick,32))) activeuser
ON *:ACTION:*:%mychan:IF (($nick != twitchnotify) && ($nick != $me) && (!$istok(%commonbots,$nick,32))) activeuser

alias activeuser {
  HADD -z activeusers $nick %activetime
  IF ($hget(payactivex_command)) HADD payactivex_command $nick True
  IF ($hget(payactivex_auto)) HADD payactivex_auto $nick True
}
