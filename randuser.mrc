/*
*******************************************************************************
****************************** RANDUSER SCRIPT ********************************
*******************************************************************************

This is a similar command to AnkhBot's $randuser, except it allows for more
flexability when writing your own commands in mIRC.  Simply use $randuser in your
mIRC commands to have the command pick a random ACTIVE user from chat.  Use
$randotheruser to pick a random active user from chat that will not be the person
who initiated the command, unless there are no other active users.

The default time for a user to be considered active is 1800 seconds (30 minutes),
and they must have been active in the last 100 lines of chat.
You can change the active time required from 1800 seconds by typing
"!set activetime #" where # is the amount of time in seconds for a user to be
considered active.

There is an example !hug command below that you can use to test out the alias.

The other command is a !payactive command that is similar to AnkhBot's
"!points add +viewers #" command, except that it will only give points to the users
who have been active in the last 30 minutes (or what you set the time to) and have
spoken in the last 100 lines of chat.  Simply "!payactive #"
*/


ON *:LOAD: { IF (!%activetime) SET %activetime 1800 }


;**************************** EXAMPLE !HUG COMMAND ****************************
ON *:TEXT:!hug:%mychan: { MSG $chan $twitch_name($nick) gives $randotheruser a loving hug! }
;******************************************************************************


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
    WHILE ($read(randuser.txt, %x) != $null) {
      VAR %avnick $wildtok($read(randuser.txt, %x), *, 1, 32)
      VAR %avtime $wildtok($read(randuser.txt, %x), *, 2, 32)
	  VAR %streamer $remove(%mychan, $chr(35))
      IF ($calc($ctime - %avtime) <= %activetime) && (%avnick ison %mychan) && (%avnick != %streamer) VAR %avusers $addtok(%avusers,$cached_name(%avnick),32)
      INC %x
    }
    IF (%avusers == $null) { MSG %mychan There are no active users to give points to!  BibleThump | halt }
    VAR %x = 1
    WHILE ($gettok(%avusers, %x, 32) != $null) {
      VAR %avnick $gettok(%avusers, %x, 32)
      ADDPOINTS %avnick %payout
      INC %x
    }
    VAR %avusers $sorttok(%avusers, 32, a)
    VAR %x = 1
    WHILE ($gettok(%avusers, %x, 32) != $null) {
      VAR %avnick $gettok(%avusers, %x, 32)
      VAR %avusers2 $addtok(%avusers2,%avnick $+ $chr(44),32)
      INC %x
    }
    VAR %numausers $numtok(%avusers2, 32)
    VAR %avusers2 $left(%avusers2, -1)
    MSG %mychan Successfully payed out %payout points to all of the following %numausers active users:  %avusers2
  }
}


alias activeuser {

  IF ($nick != twitchnotify) && ($nick != $me) {
    INC %randusernum
    WRITE -l $+ %randusernum randuser.txt $nick $ctime
    IF (%randusernum == 100) %randusernum = 0
  }
}


alias randuser {

  VAR %x = 1
  WHILE ($read(randuser.txt, %x) != $null) {
    VAR %runick $wildtok($read(randuser.txt, %x), *, 1, 32)
    VAR %rutime $wildtok($read(randuser.txt, %x), *, 2, 32)
    IF ($calc($ctime - %rutime) <= %activetime) && (%runick ison %mychan) VAR %randusers $addtok(%randusers,%runick,32)
    INC %x
  }
  VAR %getrunumbers $numtok(%randusers, 32)
  VAR %finalrunum $rand(1,%getrunumbers)
  VAR %randuser $wildtok(%randusers, *, %finalrunum, 32)
  RETURN $twitch_name(%randuser)
}


alias randotheruser {

  VAR %x = 1
  WHILE ($read(randuser.txt, %x) != $null) {
    VAR %runick = $wildtok($read(randuser.txt, %x), *, 1, 32)
    VAR %rutime = $wildtok($read(randuser.txt, %x), *, 2, 32)
    IF ($calc($ctime - %rutime) <= %activetime) && (%runick ison %mychan) && (%runick != $nick) VAR %randusers $addtok(%randusers,%runick,32)
    INC %x
  }
  VAR %getrunumbers $numtok(%randusers, 32)
  VAR %finalrunum $rand(1,%getrunumbers)
  VAR %randuser $wildtok(%randusers, *, %finalrunum, 32)
  IF (%randuser != $null) RETURN $twitch_name(%randuser)
  ELSE RETURN $twitch_name($nick)
}


ON *:TEXT:*:%mychan: { activeuser }
ON *:ACTION:*:%mychan: { activeuser }
