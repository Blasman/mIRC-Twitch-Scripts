;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BLASBOT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;; TWITCH.TV/BLASMAN13 ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;; RAID COMPANION SCRIPT 1.0.0.0 ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

alias raid_version return 1.0.0.0

ON *:LOAD: raid_setup
ON *:UNLOAD: UNSET %raid*

dialog raid_important {
  title "IMPORTANT!"
  size -1 -1 200 60
  option dbu
  text "You are NOT running the latest version of blasbot.mrc from Blasman's GitHub. This script will NOT work for you until you install it! Setup will exit once you click Okay.", 1, 8 8 180 30
  button "Okay", 3, 80 45 40 12, ok
}

alias raid_setup {
  IF ($blasbot_version < 1.0.0.5) {
    $dialog(raid_important,raid_important)
    url -m https://github.com/Blasman/mIRC-Twitch-Scripts/wiki/Script-Documentation
    unload -rs raids.mrc
    halt
  }
  IF (!%raid_topraiderscmd) SET %raid_topraiderscmd On
  :raidmsg
  $input(Please enter the Raid Message that you want your viewers to copy and paste (AVOID DOUBLE SPACING!):,eo,Required Input,%raid_msg)
  IF !$! { ECHO You need a Raid Message! | GOTO raidmsg }
  ELSE SET %raid_msg $!
  :payout
  $input(Please enter the amount of %curname that you want to pay to users who raid:,eo,Required Input,%raid_default_payout)
  IF ($! !isnum) { ECHO You must enter a valid amount of %curname $+ ! | GOTO payout }
  ELSE SET %raid_default_payout $floor($!)
  :matchmsg
  $input(Please enter the text that you want to match in the channels that you raid. If a user types a message that matches this text in the channel that you are raiding $chr(44) $+ then they will be treated as a successful raider. Just press "OK" if you want to match your raid message EXACTLY.  It is probably a good idea to just use an emote.,eo,Required Input,%raid_msg)
  IF !$! { ECHO You must enter a valid message! | GOTO matchmsg }
  ELSE SET %raid_matchmsg $!
}

ON *:TEXT:*:%raid.chan: {
  IF ((%raid_matchmsg isin $1-) && (!$($+(%,raid.name.,$nick),2))) {
    IF (($nick == %streamer) && (!$timer(.raid.active))) {
      .timer.raid.active 1 92 raidpayout
      .timer.raid.msg 1 2 MSG %mychan The Raid on %raid.url is happening right NOW! All Raiders will be given %raid.payout %curname in 90 seconds!
    }
    ELSEIF (($nick != %streamer) && ($timer(.raid.active))) {
      SET %raid.name. $+ $nick On
      SET %raid.list %raid.list $nick
    }
  }
}

ON *:ACTION:*:%raid.chan: {
  IF ((%raid_matchmsg isin $1-) && (!$($+(%,raid.name.,$nick),2))) {
    IF (($nick == %streamer) && (!$timer(.raid.active))) {
      .timer.raid.active 1 92 raidpayout
      .timer.raid.msg 1 2 MSG %mychan The Raid on %raid.url is happening right NOW! All Raiders will be given %raid.payout %curname in 90 seconds!
    }
    ELSEIF (($nick != %streamer) && ($timer(.raid.active))) {
      SET %raid.name. $+ $nick On
      SET %raid.list %raid.list $nick
    }
  }
}

ON $*:TEXT:/^!raid(\s|$)/iS:%mychan: {
  IF (($nick == %streamer) && ($2)) {
    IF (!%raid.name) {
      VAR %raid.temp $twitch_name($2)
      IF (%raid.temp != $null) {
        IF ($livecheck(%raid.temp)) raid_run %raid.temp $3
        ELSE MSG $chan $nick $+ , uhhh... %raid.temp doesn't appear to be live at the moment. FailFish
      }
      ELSE MSG $chan $nick $+ , uhhh... check the spelling of that name. FailFish
    }
    ELSE MSG $chan $nick $+ , there is a raid set up already for %raid.name $+ . Type !raidcancel if you want to cancel this raid.
  }
  ELSEIF (($ModCheck) && (%raid.name) && (!$2)) {
    DESCRIBE $chan GO TO http:// $+ %raid.url AND COPY AND PASTE THE FOLLOWING MESSAGE AFTER $upper(%streamer) DOES:
    DESCRIBE $chan %raid_msg
  }
  ELSEIF ((!%CD_raid_msg) && (!$2)) {
    SET -eu2 %CD_raid_msg On
    DESCRIBE $chan %raid_msg
  }
}

ON $*:TEXT:/^!raidforce\s\w+(\s\d+)?$/iS:%mychan: IF ($nick == %streamer) raid_run $2 $3

alias -l raid_run {
  SET %raid.name $1
  SET %raid.chan $chr(35) $+ $lower($1)
  IF ($2 isnum) SET %raid.payout $floor($2)
  ELSE SET %raid.payout %raid_default_payout
  SET %raid.url twitch.tv/ $+ %raid.name
  DESCRIBE %mychan ATTENTION EVERYONE!  We are about to raid %raid.url ! Silently go to their channel and SAY NOTHING. When %streamer starts the raid, paste the following message into their chat:
  DESCRIBE %mychan %raid_msg
  .timer.raid.repeat 1 3 .timer.raid.repeat -m 5 200 DESCRIBE %mychan http:// $+ %raid.url
  .timer.raid.joinchannel 1 5 JOIN %raid.chan
  .timer.raid.timeout 1 1800 raidcancel
}

alias -l raidpayout {
  IF ($timer(.raid.timeout)) .timer.raid.timeout off
  PART %raid.chan
  IF (%raid.list == $null) MSG %mychan Really? NO ONE wanted to raid!? BibleThump
  ELSE {
    IF (!$isfile(raiders.ini)) raid_fix
    VAR %x = 1
    WHILE ($gettok(%raid.list,%x,32) != $null) {
      VAR %nick $v1
      ADDPOINTS %nick %raid.payout
      WRITEINI raiders.ini %nick $calc($readini(raiders.ini,%nick,Raids) + 1)
      INC %x
    }
    VAR %raid.list $sorttok(%raid.list, 32, a)
    VAR %x = 1
    WHILE ($gettok(%raid.list,%x,32) != $null) {
      VAR %sortlist %sortlist $v1 $+ $chr(44)
      INC %x
    }
    VAR %sortlist $left(%sortlist, -1)
    VAR %num $numtok(%sortlist,32)
    WRITE raid_history.txt $asctime(mmm d h:nn TT) - %raid.name - %num Raiders: %sortlist
    MSG %mychan Thank you, Raiders! Successfully paid out %raid.payout %curname to all of the following %num raiders: %sortlist
  }
  UNSET %raid.*
}

ON $*:TEXT:/^!raidcancel(\s|$)/iS:%mychan: IF (($nick == %streamer) && (%raid.name)) raidcancel

alias -l raidcancel {
  IF ($timer(.raid.timeout)) { MSG %mychan We are no longer going to raid %raid.name $+ . | .timer.raid.* off }
  IF ($me ison %raid.chan) PART %raid.chan
  UNSET %raid.*
}

ON $*:TEXT:/^!raidmsg(\s|$)/iS:%mychan: {
  IF (($nick == %streamer) && ($2)) {
    SET %raid_msg $2-
    MSG $chan The Raid Message has been changed to: $2-
  }
  ELSEIF (($ModCheck) && (!$2)) MSG $chan %raid_msg
}

ON $*:TEXT:/^!raidpayout(\s|$)/iS:%mychan: {
  IF (($nick == %streamer) && ($2 isnum)) {
    SET %raid_default_payout $floor($2)
    MSG $chan The default payout for Raiders has been set to %raid_default_payout %curname $+ .
  }
  ELSEIF (($ModCheck) && (!$2)) MSG $chan The default payout for raiders is %raid_default_payout %curname $+ .
}

ON $*:TEXT:/^!raidmatchmsg(\s|$)/iS:%mychan: {
  IF (($nick == %streamer) && ($2)) {
    SET %raid_matchmsg $2-
    MSG $chan The match text for raiders has been changed to: %raid_matchmsg
  }
  ELSEIF (($ModCheck) && (!$2)) MSG $chan Raiders must match the following text in order to receive %curname $+ : %raid_matchmsg
}

ON *:TEXT:!raidsetup:%mychan: {
  IF ($nick == %streamer) {
    MSG $chan %streamer $+ , the !raid setup is now running in mIRC...
    .timer.raid.setup 1 0 raid_setup
  }
}

ON *:TEXT:!raidmatchtest *:%mychan: IF ($ModCheck) $IIF(%raid_matchmsg isin $2-,MSG $chan Success!,MSG $chan Fail!)

ON *:TEXT:!raidlast:%mychan: IF ($ModCheck) MSG $chan $read(raid_history.txt,$lines(raid_history.txt))

ON *:TEXT:!raidtopcmd:%mychan: {
  IF ($ModCheck) {
    IF (%raid_topraiderscmd == On) {
      UNSET %raid_topraiderscmd
      MSG $chan The !topraiders command has now been disabled!
    }
    ELSE {
      SET %raid_topraiderscmd On
      MSG $chan The !topraiders command has now been enabled!
    }
  }
}

ON *:TEXT:!raidhelp:%mychan: {
  IF ($ModCheck) {
    MSG $chan STREAMER ONLY Commands ▌ !raid [user] - setup a raid ▌ !raid [user] [amount] - setup a raid with a specific payout ▌ !raidcancel - cancel a raid ▌ !raidmsg [message] - change raid message ▌ !raidpayout [amount] - change the default payout ▌ !raidmatchmsg [message] - change match text ▌ !raidsetup - run raid setup in mIRC ▌ !raidforce [user] - FORCE a raid (bypass checks)
    .timer.raid.help 1 2 MSG $chan MOD ONLY Commands ▌ !raid - posts the raid message (and target if there is one) ▌ !raidmsg - posts the raid message ▌ !raidpayout - posts the default payout for raiders ▌ !raidmatchmsg - posts the match text ▌ !raidmatchtest [message] - test to see if your message will match the match text ▌ !raidlast - info on the last raid ▌ !raidtopcmd - toggle !topraiders command
  }
}

ON $*:TEXT:/^!top(\s)?raiders$/iS:%mychan: {
  IF (%raid_topraiderscmd) {
    IF (!%CD_topraiders) {
      SET -eu10 %CD_topraiders On
      IF (!$isfile(raiders.ini)) raid_fix
      VAR %i = 1
      WINDOW -h @raiders | VAR %i 1
      WHILE $ini(raiders.ini,%i) {
        ALINE @raiders $v1 $readini(raiders.ini,$v1,Raids)
        INC %i
      }
      FILTER -cetuww 2 32 @raiders @raiders
      VAR %i 1 | while %i <= 10 {
        TOKENIZE 32 $line(@raiders,%i)
        VAR %name $chr(35) $+ %i $1 $chr(40) $+ $2 $+ $chr(41) -
        VAR %list $addtok(%list, %name, 32)
        INC %i
      }
      MSG $chan Users who have raided with %streamer the most: $left(%list, -1)
      WINDOW -c @raiders
    }
  }
}

alias raid_fix {
  IF ($isfile(raiders.ini)) REMOVE raiders.ini
  VAR %i = 1
  WHILE $read(raid_history.txt,%i) {
    TOKENIZE 58 $read(raid_history.txt,%i)
    VAR %names $remove($3-,$chr(44)), %x = 1
    WHILE ($gettok(%names,%x,32)) {
      VAR %nick $v1
      WRITEINI raiders.ini %nick Raids $calc($readini(raiders.ini,%nick,Raids) + 1)
      INC %x
    }
    INC %i
  }
}
