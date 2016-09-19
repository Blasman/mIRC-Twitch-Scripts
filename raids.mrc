;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;; RAIDER SCRIPT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON *:LOAD: raid_setup
ON *:UNLOAD: UNSET %raid*

alias raid_setup {
  :raidmsg
  $input(Please enter the Raid Message that you want your viewers to copy and paste (AVOID DOUBLE SPACING!):,eo,Required Input,%raid_msg)
  IF !$! { ECHO You need a Raid Message! | GOTO raidmsg }
  ELSE SET %raid_msg $!
  :payout
  $input(Please enter the amount of %curname that you want to pay to users who raid:,eo,Required Input,%raid_default_payout)
  IF ($! !isnum) { ECHO You must enter a valid amount of %curname $+ ! | GOTO payout }
  ELSE SET %raid_default_payout $floor($!)
  :matchmsg
  $input(Please enter the text that you want to match in the channels that you raid.  If a user types a message that matches this text in the channel that you are raiding $chr(44) $+ then they will be treated as a successful raider.  Just press "OK" if you want to match your raid message EXACTLY.  It is probably a good idea to just use an emote.,eo,Required Input,%raid_msg)
  IF !$! { ECHO You must enter a valid message! | GOTO matchmsg }
  ELSE SET %raid_matchmsg $!
}

ON *:TEXT:*:%raid.chan: {
  IF ((%raid_matchmsg isin $1-) && (!$($+(%,raid.name.,$nick),2))) {
    IF (($nick == %streamer) && (!$timer(.raid.active))) {
      .timer.raid.active 1 92 raidpayout
      .timer.raid.msg 1 2 MSG %mychan The Raid on %raid.url is happening right NOW!  All Raiders will be given %raid.payout %curname in 90 seconds!
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
      .timer.raid.msg 1 2 MSG %mychan The Raid on %raid.url is happening right NOW!  All Raiders will be given %raid.payout %curname in 90 seconds!
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
        IF ($livecheck(%raid.temp) == $true) {
          IF ($3 isnum) SET %raid.payout $floor($3)
          ELSE SET %raid.payout %raid_default_payout
          SET %raid.name %raid.temp
          SET %raid.chan $chr(35) $+ $lower($2)
          SET %raid.url twitch.tv/ $+ %raid.name
          DESCRIBE $chan ATTENTION EVERYONE!  We are about to raid %raid.url !  Silently go to their channel and SAY NOTHING.  When %streamer starts the raid, paste the following message into their chat:
          DESCRIBE $chan %raid_msg
          .timer.raid.repeat 1 3 .timer.raid.repeat -m 5 200 DESCRIBE $chan http:// $+ %raid.url
          .timer.raid.joinchannel 1 5 JOIN %raid.chan
          .timer.raid.timeout 1 1800 raidcancel
        }
        ELSE MSG $chan $nick $+ , uhhh... %raid.temp doesn't appear to be live at the moment.  FailFish
      }
      ELSE MSG $chan $nick $+ , uhhh... check the spelling of that name.  FailFish
    }
    ELSE MSG $chan $nick $+ , there is a raid set up already for %raid.name $+ .  Type !raidcancel if you want to cancel this raid.
  }
  ELSEIF (($nick isop $chan) && (%raid.name) && (!$2)) {
    DESCRIBE $chan GO TO http:// $+ %raid.url AND COPY AND PASTE THE FOLLOWING MESSAGE AFTER $upper(%streamer) DOES:
    DESCRIBE $chan %raid_msg
  }
  ELSEIF ((!%CD_raid_msg) && (!$2)) {
    SET -eu2 %CD_raid_msg On
    DESCRIBE $chan %raid_msg
  }
}

alias -l raidpayout {
  IF ($timer(.raid.timeout)) .timer.raid.timeout off
  PART %raid.chan
  IF (%raid.list == $null) MSG %mychan Really?  NO ONE wanted to raid!?  BibleThump
  ELSE {
    VAR %x = 1
    WHILE ($gettok(%raid.list, %x, 32) != $null) {
      ADDPOINTS $v1 %raid.payout
      INC %x
    }
    VAR %raid.list $sorttok(%raid.list, 32, a)
    VAR %x = 1
    WHILE ($gettok(%raid.list, %x, 32) != $null) {
      VAR %sortlist %sortlist $v1 $+ $chr(44)
      INC %x
    }
    VAR %sortlist $left(%sortlist, -1)
    VAR %num $numtok(%sortlist, 32)
    WRITE raid_history.txt $asctime(mmm d h:nn TT) - %raid.name - %num Raiders: %sortlist
    MSG %mychan Thank you, Raiders!  Successfully payed out %raid.payout %curname to all of the following %num raiders:  %sortlist
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
  ELSEIF (($nick isop $chan) && (!$2)) MSG $chan %raid_msg
}

ON $*:TEXT:/^!raidpayout(\s|$)/iS:%mychan: {
  IF (($nick == %streamer) && ($2 isnum)) {
    SET %raid_default_payout $floor($2)
    MSG $chan The default payout for Raiders has been set to %raid_default_payout %curname $+ .
  }
  ELSEIF (($nick isop $chan) && (!$2)) MSG $chan The default payout for raiders is %raid_default_payout %curname $+ .
}

ON $*:TEXT:/^!raidmatchmsg(\s|$)/iS:%mychan: {
  IF (($nick == %streamer) && ($2)) {
    SET %raid_matchmsg $2-
    MSG $chan The match text for raiders has been changed to: %raid_matchmsg
  }
  ELSEIF (($nick isop $chan) && (!$2)) MSG $chan Raiders must match the following text in order to receive %curname $+ : %raid_matchmsg
}

ON *:TEXT:!raidsetup:%mychan: {
  IF ($nick == %streamer) {
    MSG $chan %streamer $+ , the !raid setup is now running in mIRC...
    .timer.raid.setup 1 0 raid_setup
  }
}

ON *:TEXT:!raidmatchtest *:%mychan: IF ($nick isop $chan) $IIF(%raid_matchmsg isin $2-,MSG $chan Success!,MSG $chan Fail!)

ON *:TEXT:!raidlast:%mychan: IF ($nick isop $chan) MSG $chan $read(raid_history.txt,$lines(raid_history.txt))

ON *:TEXT:!raidhelp:%mychan: {
  IF ($nick isop $chan) {
    MSG $chan STREAMER ONLY Commands ▌ !raid [user] - setup a raid with default payout ▌ !raid [user] [amount] - setup a raid with a specific payout ▌ !raidcancel - cancel a raid ▌ !raidmsg [message] - change raid message ▌ !raidpayout [amount] - change the default payout for raids ▌ !raidmatchmsg [message] - change match text ▌ !raidsetup - run the raid setup in mIRC
    .timer.raid.help 1 2 MSG $chan MOD ONLY Commands ▌ !raid - posts the raid message (and target if there is one) ▌ !raidmsg - posts the raid message ▌ !raidpayout - posts the default payout for raiders ▌ !raidmatchmsg - posts the match text ▌ !raidmatchtest [message] - test to see if your message will match the match text ▌ !raidlast - info on the last raid
  }
}

alias -l livecheck {
  JSONOpen -uw livecheck https://api.twitch.tv/kraken/streams/ $+ $1 $+ ?nocache= $+ $ticks
  JSONUrlHeader livecheck Client-ID e8e68mu4x2sxsewuw6w82wpfuyprrdx
  JSONUrlGet livecheck
  VAR %x $IIF($json(livecheck,stream),$true,$false)
  JSONClose livecheck
  RETURN %x
}
