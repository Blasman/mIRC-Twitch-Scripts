/*
*******************************************************************************
****************************** RANDUSER SCRIPT ********************************
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
Simply type "!payactive [number of points to give]"

The default time for a user to be considered active is 1800 seconds (30 minutes).
You can change the active time required from 1800 seconds by typing
"!set activetime #" where # is the amount of time in seconds for a user to be
considered active.
*/

ON *:LOAD: {
  IF (!%activetime) SET %activetime 1800
  IF (!$hget(activeusers)) HMAKE activeusers
}

ON *:CONNECT: IF (($server == tmi.twitch.tv) && (!$hget(activeusers))) HMAKE activeusers

ON $*:TEXT:/^!set\sactivetime\s\d+$/iS:%mychan: IF ($nick isop $chan) { SET %activetime $3 | MSG $chan The time since last user activity to be considered an active user has been set to $3 seconds. }

ON $*:TEXT:/^!payactive\s\d+(\s\d+)?$/iS:%mychan: {
  IF ($editorcheck($nick) == true) {
    IF (!$3) payactive $2
    ELSEIF ($3) {
      MSG $chan KAPOW Attention all lurkers!  In $IIF($regex($calc($3 / 30),^\d+$),$calc($3 / 60) minutes,$3 seconds) $+ , everyone who has been chatting in the previous $calc(%activetime / 60) minutes from that point will receive $2 %curname $+ !
      .timer.payactive 1 $3 payactive $2
    }
  }
}

alias payactive {
  VAR %x = 1
  WHILE ($hget(activeusers, %x).item != $null) {
    IF (($v1 != %streamer) && (($v1 ison %mychan) || ($calc($hget(activeusers, $v1) + 60) >= %activetime))) VAR %paylist %paylist $hget(activeusers, %x).item
    INC %x
  }
  IF (%paylist == $null) MSG %mychan There are no active users to give %curname to!  BibleThump
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
    MSG %mychan Successfully payed out $1 %curname to all of the following $numtok(%sortlist, 32) active users:  $left(%sortlist, -1)
  }
}

alias randuser {
  VAR %x = 1
  WHILE ($hget(activeusers, %x).item != $null) {
    VAR %nick $v1
    IF (!$1) { IF ((%nick ison %mychan) || ($calc($hget(activeusers, %nick) + 60) >= %activetime)) VAR %activelist %activelist %nick }
    ELSEIF ($1 == other) { IF (((%nick ison %mychan) || ($calc($hget(activeusers, %nick) + 60) >= %activetime)) && (%nick != $nick)) VAR %activelist %activelist %nick }
    ELSEIF ($1 == notme) { IF (((%nick ison %mychan) || ($calc($hget(activeusers, %nick) + 60) >= %activetime)) && (%nick != %streamer)) VAR %activelist %activelist %nick }
    ELSEIF ($1 == othernotme) { IF (((%nick ison %mychan) || ($calc($hget(activeusers, %nick) + 60) >= %activetime)) && (%nick != %streamer) && (%nick != $nick)) VAR %activelist %activelist %nick }
    ELSEIF ($1 == list) { IF ((%nick ison %mychan) || ($calc($hget(activeusers, %nick) + 60) >= %activetime)) VAR %activelist %activelist %nick }
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

ON *:TEXT:*:%mychan:IF (($nick != twitchnotify) && ($nick != $me)) HADD -z activeusers $nick %activetime
ON *:ACTION:*:%mychan:IF (($nick != twitchnotify) && ($nick != $me)) HADD -z activeusers $nick %activetime
