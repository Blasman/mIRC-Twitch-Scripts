/*
*******************************************************************************
**************************** TWITCH.TV/BLASMAN13 ******************************
*********************** PAYACTIVE AND RANDUSER SCRIPT *************************
*******************************************************************************

This is a similar command to AnkhBot's $randuser, except it allows for more
flexability when writing your own commands in mIRC.  Simply use $randuser in your
mIRC commands to have the command pick a random ACTIVE user from chat that is
STILL in your channel.  Use $randuser(other) to pick a random active user from
chat that will not be the person who initiated the command.  Use $randuser(notme)
to pick a random active user that is not you (the streamer).  Use
$randuser(othernotme) to pick a random active user that is not you (the streamer)
and is also not the person who initiated the command.  If the command cannot find
an active user, then it will use the name of the person who initiated the command
with the $randuser command in it.  Use $randuser(list) to simply return a list
of active users, useful for some commands.

The other command is a !payactive command that is similar to AnkhBot's
"!points add +viewers #" command, except that it will only give points to the users
who have been active in the last X seconds (or what you set the time to).
Simply type "!payactive [number of points to give] [optional timer]"

The default time for a user to be considered active is 900 seconds (15 minutes).
You can change the active time required from 900 seconds by typing
"!set activetime #" where # is the amount of time in seconds for a user to be
considered active.
*/

ON *:LOAD: {
  IF (!%activetime) SET %activetime 900
  IF (!$hget(activeusers)) HMAKE activeusers
  IF (!%paylimit) SET %paylimit 1000000
  IF (!%commonbots) SET %commonbots moobot nightbot revlobot vivbot xanbot wizebot
}

ON *:CONNECT: IF (($server == tmi.twitch.tv) && (!$hget(activeusers))) HMAKE activeusers

ON $*:TEXT:/^!set\sactivetime\s\d+$/iS:%mychan: IF ($nick isop $chan) { SET %activetime $3 | MSG $chan The time since last user activity to be considered an active user has been set to $3 seconds. }

ON $*:TEXT:/^!payactive\s\d+(\s\d+)?$/iS:%mychan: {
  IF ($editorcheck($nick) == true) {
    IF ($2 <= %paylimit) payactive_start $2 $3
    ELSE MSG $chan $nick $+ , that amount is above the max limit of %paylimit %curname for !payactive.
  }
}

ON $*:TEXT:/^!payauto/iS:%mychan: {
  IF ($editorcheck($nick) == true) {
    IF (($regex($2,^\d+$)) && ($regex($3,^\d+$)) && ($regex($4,^\d+$))) {
      IF ($2 >= %paylimit) MSG $chan $nick $+ , that amount is above the max limit of %paylimit %curname for !payactive.
      ELSE {
        VAR %repeat $IIF($regex($5,^\d+$),$5,0)
        .timer.payauto %repeat $4 payactive_start $2 $3
        IF (%repeat == 0) MSG $chan KAPOW Every $IIF($regex($calc($4 / 30),^\d+$),$calc($4 / 60) minutes,$4 seconds) there will be an automatic !payactive $2 $3
        ELSE MSG $chan KAPOW Every $IIF($regex($calc($4 / 30),^\d+$),$calc($4 / 60) minutes,$4 seconds) $+ , for the next $IIF($regex($calc(%repeat * $4 / 30),^\d+$),$calc(%repeat * $4 / 60) minutes,$4 seconds) $+ , there will be an automatic !payactive $2 $3 for a total of %repeat times.
      }
    }
    ELSEIF (($0 == 2) && ($2 == off) && ($timer(.payauto))) {
      .timer.payauto off
      MSG $chan The automatic !payactive has been turned off.
    }
    ELSE MSG $chan $nick $+ , use !payauto [AMOUNT of %curname $+ ] [TIMER OF !payactive] [HOW OFTEN the !payactive] [OPTIONAL: HOW MANY TIMES to keep repeating the !payactive] ••• To turn off the !payauto, type !payauto off
  }
}

ON $*:TEXT:/^!paylimit($|\s\d+)/iS:%mychan: {
  IF ($nick isop $chan) {
    IF (!$2) MSG $chan The current max amount for !payactive is %paylimit %curname $+ .
    ELSEIF ($2) {
      SET %paylimit $2
      MSG $chan The max amount for !payactive has been set to %paylimit %curname $+ .
    }
  }
}

alias payactive_start {
  IF (!$2) payactive $1
  ELSE {
    MSG %mychan KAPOW Attention all lurkers!  In $IIF($regex($calc($2 / 30),^\d+$),$calc($2 / 60) minutes,$2 seconds) $+ , everyone who has been chatting in the previous $calc(%activetime / 60) minutes from that point will receive $1 %curname $+ !
    .timer.payactive 1 $2 payactive $1
  }
}

alias payactive {
  VAR %x = 1
  WHILE ($hget(activeusers, %x).item != $null) {
    VAR %nick $v1
    IF ((%nick != %streamer) && ((%nick ison %mychan) || ($calc($hget(activeusers, %nick) + 90) >= %activetime))) VAR %paylist %paylist %nick
    INC %x
  }
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

ON *:TEXT:*:%mychan:IF (($nick != twitchnotify) && ($nick != $me) && (!$istok(%commonbots,$nick,32))) HADD -z activeusers $nick %activetime
ON *:ACTION:*:%mychan:IF (($nick != twitchnotify) && ($nick != $me) && (!$istok(%commonbots,$nick,32))) HADD -z activeusers $nick %activetime
