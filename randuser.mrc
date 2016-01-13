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
with the $randuser command in it.

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

ON *:CONNECT: { IF (($server == tmi.twitch.tv) && (!$hget(activeusers))) HMAKE activeusers }


ON $*:TEXT:/^!set\sactivetime\s\d+/iS:%mychan: {

  IF ($nick isop $chan) {
    SET %activetime $3
    MSG $chan The time since last user activity to be considered an active user has been set to $3 seconds.
  }
}


ON $*:TEXT:/^!payactive\s\d+/iS:%mychan: {

  IF ($nick isop $chan) && ($2 isnum) {
    VAR %payout = $floor($2)
    VAR %x = 1
    WHILE ($hget(activeusers, %x).item != $null) {
      VAR %nick $hget(activeusers, %x).item
      IF ((%nick != %streamer) && (%nick ison %mychan)) VAR %paylist $addtok(%paylist, $cached_name(%nick), 32)
      INC %x
    }
    IF (%paylist == $null) MSG %mychan There are no active users to give %curname to!  BibleThump
    ELSE {
      VAR %x = 1
      WHILE ($gettok(%paylist, %x, 32) != $null) {
        VAR %nick $gettok(%paylist, %x, 32)
        ADDPOINTS %nick %payout
        INC %x
      }
      VAR %paylist $sorttok(%paylist, 32, a)
      VAR %x = 1
      WHILE ($gettok(%paylist, %x, 32) != $null) {
        VAR %nick $gettok(%paylist, %x, 32)
        VAR %sortlist $addtok(%sortlist, %nick $+ $chr(44), 32)
        INC %x
      }
      VAR %numusers $numtok(%sortlist, 32)
      VAR %sortlist $left(%sortlist, -1)
      MSG %mychan Successfully payed out %payout %curname to all of the following %numusers active users:  %sortlist
    }
  }
}


alias randuser {

  VAR %x = 1
  WHILE ($hget(activeusers, %x).item != $null) {
    VAR %nick $hget(activeusers, %x).item
    IF (!$1) { IF (%nick ison %mychan) VAR %activelist $addtok(%activelist, %nick, 32) }
    ELSEIF ($1 == other) { IF ((%nick ison %mychan) && (%nick != $nick)) VAR %activelist $addtok(%activelist, %nick, 32) }
    ELSEIF ($1 == notme) { IF ((%nick ison %mychan) && (%nick != %streamer)) VAR %activelist $addtok(%activelist, %nick, 32) }
    ELSEIF ($1 == othernotme) { IF ((%nick ison %mychan) && (%nick != %streamer) && (%nick != $nick)) VAR %activelist $addtok(%activelist, %nick, 32) }
    ELSE BREAK
    INC %x
  }
  VAR %rutotal $numtok(%activelist, 32)
  VAR %choose $rand(1, %rutotal)
  VAR %randuser $wildtok(%activelist, *, %choose, 32)
  IF (%randuser != $null) RETURN $twitch_name(%randuser)
  ELSE RETURN $twitch_name($nick)
}


ON *:TEXT:*:%mychan:IF (($nick != twitchnotify) && ($nick != $me)) HADD -z activeusers $nick %activetime
ON *:ACTION:*:%mychan:IF (($nick != twitchnotify) && ($nick != $me)) HADD -z activeusers $nick %activetime
