;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; VARIABLES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

/*
HEY!  LOOK HERE!  This is what you need to change in this script...

Change the %scram_minbet and %scram_maxbet to the minimum and maximum
amount of points that must be spent in order to play the game.  The
%scram_cd variable is the per user cooldown time (in seconds) that a user
must wait before being able to use !scram again.

You will need to UNLOAD and RE-LOAD this script for any changes to the
variables below to take effect.  This can be done by pressing ALT-R in
mIRC > Select "View" > Select "scramble.mrc" > Click on "File" > "Unload."
Then, click on "File" and "Load..." and select the scramble.mrc file again.

Have fun!!!
*/

ON *:LOAD: {
  SET %scram_minbet 1
  SET %scram_maxbet 500
  SET %scram_cd 120
}

ON *:UNLOAD: { UNSET %scram_* }

alias scramble {

  IF ($len($1) >= 2) {
    WHILE (($len(%scrambled) < $len($1)) || ($1 == %scrambled)) {
      IF ($1 == %scrambled) { VAR %scrambled = "" | VAR %used = "" }
      VAR %current = $r(1,$len($1))
      IF ($istok(%used,%current,32) == $false) {
        VAR %scrambled = %scrambled $+ $mid($1,%current,1)
        VAR %used = %used %current
      }
    }
    RETURN %scrambled
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;; SCRAMBLE GAME ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON $*:TEXT:/^!scram(ble)?\s(on|off)/iS:#: {

  IF ($nick isop $chan) {
    IF ($2 == on) {
      IF (!%GAMES_SCRAM_ACTIVE) {
        SET %GAMES_SCRAM_ACTIVE On
        MSG $chan $twitch_name($nick) $+ , the word scramble game is now enabled!  Type !scram for more info!  Have fun!  PogChamp
      }
      ELSE MSG $chan $twitch_name($nick) $+ , !scram is already enabled.  FailFish
    }
    ELSEIF ($2 == off) {
      IF (%GAMES_SCRAM_ACTIVE) {
        UNSET %GAMES_SCRAM_ACTIVE
        MSG $chan $twitch_name($nick) $+ , the scramble game is now disabled.
      }
      ELSE MSG $chan $twitch_name($nick) $+ , !scram is already disabled.  FailFish
    }
  }
}

ON $*:TEXT:/^!scram(ble)?(\s|$)/iS:#: {

  IF ($($+(%,floodSCRAM.,$nick),2)) halt
  SET -u3 %floodSCRAM. $+ $nick On
  IF (!%GAMES_SCRAM_ACTIVE) {
    IF ((%floodSCRAM_ACTIVE) || ($($+(%,floodSCRAM_ACTIVE.,$nick),2))) halt
    SET -u15 %floodSCRAM_ACTIVE On
    SET -u120 %floodSCRAM_ACTIVE. $+ $nick On
    MSG $chan $twitch_name($nick) $+ , the word scramble game is currently disabled.
    halt
  }
  ELSEIF ($2 isnum %scram_minbet - %scram_maxbet) && (!%scram.p1) {
    IF ($($+(%,SCRAM_CD.,$nick),2)) MSG $nick $twitch_name($nick) $+ , please wait for your cooldown to expire in $duration(%SCRAM_CD. [ $+ [ $nick ] ]) before trying to play scramble again.
    ELSEIF ($checkpoints($nick, $2) == false) MSG $chan $twitch_name($nick) $+ , you don't have enough %curname to play.  FailFish
    ELSEIF (!$3) {
      SET %scram.p1 $twitch_name($nick)
      SET %scram.bet $floor($2)
      MSG $chan KAPOW %scram.p1 has issued a scramble challenge for %scram.bet %curname to the first person to accept within 90 seconds!  To accept this challenge type "!scram accept"
      .timer.scram.wait1 1 90 MSG $chan Sorry, %scram.p1 $+ , but nobody wanted to accept your scramble challenge!  FeelsBadMan
      .timer.scram.wait2 1 90 UNSET %scram.*
      .timer.scram.wait3 1 90 SET -z %SCRAM_CD. $+ $nick %scram_cd
    }
    ELSEIF ($3) && ($3 != $me) {
      VAR %target $remove($3, @)
      IF (%target ison $chan) {
        IF ($checkpoints(%target, $2) == false) MSG $chan $twitch_name($nick) $+ , $twitch_name(%target) doesn't have enough %curname to play.  FailFish
        ELSE {
          SET %scram.p1 $twitch_name($nick)
          SET %scram.p2 $twitch_name(%target)
          SET %scram.bet $floor($2)
          MSG $chan KAPOW %scram.p1 has issued a scramble challenge for %scram.bet %curname to %scram.p2 $+ !  %scram.p2 now has 90 seconds to accept this challenge by typing "!scram accept"
          .timer.scram.wait1 1 90 MSG $chan Sorry, %scram.p1 $+ , but %scram.p2 didn't want to accept your scramble challenge!  FeelsBadMan
          .timer.scram.wait2 1 90 UNSET %scram.*
          .timer.scram.wait3 1 90 SET -z %SCRAM_CD. $+ $nick %scram_cd
        }
      }
      ELSE MSG $chan $twitch_name($nick) $+ , %target is not the name of a user here in the channel.  Please check the spelling and make sure that they are actually here.
    }
  }
  ELSEIF ((%scram.p1) && ($nick != %scram.p1) && ($2 == accept)) {
    IF (!%scram.p2) {
      IF ($checkpoints($nick, %scram.bet) == false) MSG $chan $twitch_name($nick) $+ , you don't have enough %curname to play.  FailFish
      ELSE SET %scram.p2 $twitch_name($nick)
    }
    IF ((%scram.p2 == $nick) && (!$timer(.scram.start)) && (!%scram.origword)) {
      .timer.scram.wait* off
      MSG $chan %scram.p2 has accepted the scramble challenge of %scram.p1 $+ !  In a few moments, I will WHISPER both players with the scramble challenge, and the first player to WHISPER the correct answer to me will win %scram.bet %curname from the other player!
      .timer.scram.start 1 10 startscramble1
    }
  }
  ELSEIF (!%scram.p1) {
    IF (%floodSCRAMinfo) halt
    SET -u6 %floodSCRAMinfo On
    MSG $chan Try word scramble with a friend to try and win each others %curname $+ !  Just type "!scram $chr(91) $+ %scram_minbet $+ - $+ %scram_maxbet $+ $chr(93) $+ " to play against ANYONE, -or- type "!scram $chr(91) $+ %scram_minbet $+ - $+ %scram_maxbet $+ $chr(93) username" to play against a specific person! ▌ Example:  !scram %scram_maxbet ▌ Additional Commands: !scramtop  ▌ !scramstats  ▌ !scramstats username
  }
}

alias startscramble1 {

  WRITEINI scramstats.ini %scram.p1 Games $calc($readini(scramstats.ini,%scram.p1,Games) + 1)
  WRITEINI scramstats.ini %scram.p2 Games $calc($readini(scramstats.ini,%scram.p2,Games) + 1)
  SET %scram.origword $read(ScrambleWords.txt)
  SET %scram.scramword $scramble(%scram.origword)
  MSG %scram.p1 %scram.p1 $+ , I'm going to WHISPER you the scrambled word to guess in ten seconds!  You may KEEP GUESSING until you get it right!  Get ready!
  MSG %scram.p2 %scram.p2 $+ , I'm going to WHISPER you the scrambled word to guess in ten seconds!  You may KEEP GUESSING until you get it right!  Get ready!
  .timer.scram.start2 1 10 startscramble2
}

alias startscramble2 {

  MSG %scram.p1 Scrambled word is $qt(%scram.scramword) $+ .  Start guessing now!
  MSG %scram.p2 Scrambled word is $qt(%scram.scramword) $+ .  Start guessing now!
  SET %scram.start $ticks
  .timer.scram.hint1 1 12 MSG %scram.p1 HINT:  $qt($left(%scram.origword,1) $+ ____)
  .timer.scram.hint2 1 12 MSG %scram.p2 HINT:  $qt($left(%scram.origword,1) $+ ____)
  .timer.scram.hint3 1 24 MSG %scram.p1 HINT:  $qt($left(%scram.origword,2) $+ ___)
  .timer.scram.hint4 1 24 MSG %scram.p2 HINT:  $qt($left(%scram.origword,2) $+ ___)
  .timer.scram.hint5 1 36 MSG %scram.p1 HINT:  $qt($left(%scram.origword,3) $+ __)
  .timer.scram.hint6 1 36 MSG %scram.p2 HINT:  $qt($left(%scram.origword,3) $+ __)
  .timer.scram.end1 1 46 MSG %scram.p1 The !scramble game took too long!  Nobody wins!  The word was $qt(%scram.origword) $+ .
  .timer.scram.end2 1 46 MSG %scram.p2 The !scramble game took too long!  Nobody wins!  The word was $qt(%scram.origword) $+ .
  .timer.scram.end3 1 46 WRITEINI scramstats.ini %scram.p1 Losses $calc($readini(scramstats.ini,%scram.p1,Losses) + 1)
  .timer.scram.end4 1 46 WRITEINI scramstats.ini %scram.p1 Losses_VS_ $+ %scram.p2 $calc($readini(scramstats.ini,%scram.p1,Losses_VS_ $+ %scram.p2) + 1)
  .timer.scram.end5 1 46 WRITEINI scramstats.ini %scram.p2 Losses $calc($readini(scramstats.ini,%scram.p2,Losses) + 1)
  .timer.scram.end6 1 46 WRITEINI scramstats.ini %scram.p2 Losses_VS_ $+ %scram.p1 $calc($readini(scramstats.ini,%scram.p2,Losses_VS_ $+ %scram.p1) + 1)
  .timer.scram.end7 1 46 UNSET %scram.*
  .timer.scram.end8 1 47 MSG %mychan Nobody won the game of !scramble between %scram.p1 and %scram.p2 $+ !  They were both WAY too slow!  The word was $qt(%scram.origword) scrambled as $qt(%scram.scramword) $+ .
}

ON *:TEXT:*:?: {

  IF (%scram.start) {
    IF (($1 == %scram.origword) && (($nick == %scram.p1) || ($nick == %scram.p2))) {
      VAR %diff = $ticks - %scram.start
      VAR %scram.finish = $regsubex($duration($calc(%diff / 1000),1),/\D+/g,) $+ . $+ $right(%diff,3)
      .timer.scram.* off
      IF ($nick == %scram.p1) { SET %scram.winner %scram.p1 | SET %scram.loser %scram.p2 }
      IF ($nick == %scram.p2) { SET %scram.winner %scram.p2 | SET %scram.loser %scram.p1 }
      WRITEINI scramstats.ini %scram.winner Wins $calc($readini(scramstats.ini,%scram.winner,Wins) + 1)
      WRITEINI scramstats.ini %scram.winner Wins_VS_ $+ %scram.loser $calc($readini(scramstats.ini,%scram.winner,Wins_VS_ $+ %scram.loser) + 1)
      WRITEINI scramstats.ini %scram.loser Losses $calc($readini(scramstats.ini,%scram.loser,Losses) + 1)
      WRITEINI scramstats.ini %scram.loser Losses_VS_ $+ %scram.winner $calc($readini(scramstats.ini,%scram.loser,Losses_VS_ $+ %scram.winner) + 1)
      VAR %w.wins $readini(scramstats.ini,%scram.winner,Wins)
      VAR %w.losses $readini(scramstats.ini,%scram.winner,Losses)
      VAR %l.wins $readini(scramstats.ini,%scram.loser,Wins)
      VAR %l.losses $readini(scramstats.ini,%scram.loser,Losses)
      VAR %vs.wins $readini(scramstats.ini,%scram.winner,Wins_VS_ $+ %scram.loser)
      VAR %vs.losses $readini(scramstats.ini,%scram.winner,Losses_VS_ $+ %scram.loser)
      IF (%w.losses == $null) VAR %w.losses = 0
      IF (%l.wins == $null) VAR %l.wins = 0
      IF (%vs.losses == $null) VAR %vs.losses = 0
      .timer.scram.loser 1 1 MSG %scram.loser You lost, %scram.loser $+ !  %scram.winner got the correct answer!  It was %scram.origword $+ !  FeelsBadMan  [Total Wins: %l.wins $+ ] [Total Losses: %l.losses $+ ] [Wins vs %scram.winner $+ : %vs.losses $+ ] [Losses vs %scram.winner $+ : %vs.wins $+ ]
      .timer.scram.winner 1 2 MSG %scram.winner That's correct! Great job, %scram.winner $+ ! You won %scram.bet %curname from %scram.loser $+ !  PogChamp  [Total Wins: %w.wins $+ ] [Total Losses: %w.losses $+ ] [Wins vs %scram.loser $+ : %vs.wins $+ ] [Losses vs %scram.loser $+ : %vs.losses $+ ]
      MSG %mychan Congrats to %scram.winner who just won %scram.bet %curname from %scram.loser in %scram.finish seconds in the scramble challenge!  The word was $qt(%scram.origword) scrambled as $qt(%scram.scramword) $+ .
      ADDPOINTS %scram.winner %scram.bet
      REMOVEPOINTS %scram.loser %scram.bet
      IF ($readini(scramstats.ini,%scram.winner,Best_Time) == $null) WRITEINI scramstats.ini %scram.winner Best_Time %scram.finish
      ELSEIF ($readini(scramstats.ini,%scram.winner,Best_Time) > %scram.finish) {
        WRITEINI scramstats.ini %scram.winner Best_Time %scram.finish
        .timer.scram.newtime 1 5 MSG %scram.winner You got a new personal BEST TIME of %scram.finish seconds for completing a game of scramble!  Congrats!
      }
      SET -z %SCRAM_CD. $+ %scram.p1 %scram_cd
      UNSET %scram.*
    }
  }
}

ON *:TEXT:!scramstats*:#: {

  IF ($($+(%,floodSCRAMstats.,$nick),2)) halt
  SET -u3 %floodSCRAMstats. $+ $nick On
  VAR %nick $twitch_name($nick)
  IF ($2) VAR %target $remove($2, @)
  IF ($ini(scramstats.ini,%nick) == $null) MSG $chan %nick $+ , you have yet to play a game of word scramble here!
  ELSEIF (!$2) {
    VAR %wins $readini(scramstats.ini,%nick,Wins)
    VAR %losses $readini(scramstats.ini,%nick,Losses)
    VAR %besttime $readini(scramstats.ini,%nick,Best_Time)
    MSG $chan %nick ▌ Scramble Stats ▌ Wins: %wins ▌ Losses: %losses ▌ Fastest Time: %besttime seconds
  }
  ELSEIF ($ini(scramstats.ini,%target) == $null) MSG $chan %nick $+ , %target is not the name of a user who has played scramble here before!
  ELSEIF ($readini(scramstats.ini,%nick,Wins_VS_ $+ %target) == $null) && ($readini(scramstats.ini,%nick,Losses_VS_ $+ %target) == $null) MSG $chan %nick $+ , you have never played scramble against %target before!
  ELSE {
    VAR %vs.nick $twitch_name(%target)
    VAR %vs.wins $readini(scramstats.ini,%nick,Wins_VS_ $+ %vs.nick)
    VAR %vs.losses $readini(scramstats.ini,%nick,Losses_VS_ $+ %vs.nick)
    IF (%vs.wins == $null) VAR %vs.wins = 0
    IF (%vs.losses == $null) VAR %vs.losses = 0
    MSG $chan %nick ▌ Scramble Win/Loss Record vs %vs.nick ▌ Wins: %vs.wins ▌ Losses: %vs.losses
  }
}

ON *:TEXT:!scramtop:#: {

  IF (%floodSCRAMtop) halt
  SET -u10 %floodSCRAMtop On
  window -h @. | var %i 1
  WHILE $ini(scramstats.ini,%i) {
    aline @. $v1 $readini(scramstats.ini,$v1,Wins)
    INC %i
  }
  filter -cetuww 2 32 @. @.
  VAR %i 1 | while %i <= 5 {
    tokenize 32 $line(@.,%i)
    VAR %name $chr(35) $+ %i $1 $chr(40) $+ $2 $+ $chr(41) -
    VAR %list $addtok(%list, %name, 32)
    INC %i
  }
  VAR %list $left(%list, -1)
  VAR %list Scramble Top Players ▌ Most Wins: %list ▌ Fastest Times:
  window -c @.
  window -h @. | var %i 1
  WHILE $ini(scramstats.ini,%i) {
    aline @. $v1 $readini(scramstats.ini,$v1,Best_Time)
    INC %i
  }
  filter -ctuww 2 32 @. @.
  VAR %i 1 | while %i <= 5 {
    tokenize 32 $line(@.,%i)
    VAR %name $chr(35) $+ %i $1 $chr(40) $+ $2 $+ $chr(41) -
    VAR %list $addtok(%list, %name, 32)
    INC %i
  }
  VAR %list $left(%list, -1)
  MSG $chan %list
  window -c @.
}
