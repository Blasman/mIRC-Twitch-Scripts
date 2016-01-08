;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; VARIABLES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

/*
HEY!  LOOK HERE!  This is what you need to change in this script...

Change the %rps_minbet and %rps_maxbet to the minimum and maximum
amount of points that must be spent in order to play the game.  The
%rps_cd variable is the per user cooldown time (in seconds) that a user
must wait before being able to use !rps again.

You will need to UNLOAD and RE-LOAD this script for any changes to the
variables below to take effect.  This can be done by pressing ALT-R in
mIRC > Select "View" > Select "rps.mrc" > Click on "File" > "Unload."
Then, click on "File" and "Load..." and select the rps.mrc file again.

Have fun!!!
*/

ON *:LOAD: {
  SET %rps_minbet 1
  SET %rps_maxbet 500
  SET %rps_cd 120
}

ON *:UNLOAD: { UNSET %rps_* }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;; ROCK/PAPER/SCISSORS GAME ;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


ON $*:TEXT:/^!rps\s(on|off)/iS:#: {

  IF ($nick isop $chan) {
    IF ($2 == on) {
      IF (!%GAMES_RPS_ACTIVE) {
        SET %GAMES_RPS_ACTIVE On
        MSG $chan $twitch_name($nick) $+ , the Rock/Paper/Scissors game is now enabled!  Type !rps for more info!  Have fun!  PogChamp
      }
      ELSE MSG $chan $twitch_name($nick) $+ , !rps is already enabled.  FailFish
    }
    ELSEIF ($2 == off) {
      IF (%GAMES_RPS_ACTIVE) {
        UNSET %GAMES_RPS_ACTIVE
        MSG $chan $twitch_name($nick) $+ , the Rock/Paper/Scissors game is now disabled.
      }
      ELSE MSG $chan $twitch_name($nick) $+ , !rps is already disabled.  FailFish
    }
  }
}


ON $*:TEXT:/^!rps(\s|$)/iS:#: {

  IF ($($+(%,floodRPS.,$nick),2)) halt
  SET -u3 %floodRPS. $+ $nick On
  IF (!%GAMES_RPS_ACTIVE) {
    IF ((%floodRPS_ACTIVE) || ($($+(%,floodRPS_ACTIVE.,$nick),2))) halt
    SET -u15 %floodRPS_ACTIVE On
    SET -u120 %floodRPS_ACTIVE. $+ $nick On
    MSG $chan $twitch_name($nick) $+ , the Rock/Paper/Scissors game is currently disabled.
    halt
  }
  ELSEIF ($2 isnum %rps_minbet - %rps_maxbet) && (!%rps.p1) {
    IF ($($+(%,RPS_CD.,$nick),2)) MSG $nick $twitch_name($nick) $+ , please wait for your cooldown to expire in $duration(%RPS_CD. [ $+ [ $nick ] ]) before trying to play RPS again.
    ELSEIF ($checkpoints($nick, $2) == false) MSG $chan $twitch_name($nick) $+ , you don't have enough %curname to play.  FailFish
    ELSEIF (!$3) {
      SET %rps.p1 $twitch_name($nick)
      SET %rps.bet $floor($2)
      MSG $chan KAPOW %rps.p1 has issued a Rock/Paper/Scissors challenge for %rps.bet %curname to the first person to accept within 90 seconds!  To accept this challenge type "!rps accept"
      .timer.rps.wait1 1 90 MSG $chan Sorry, %rps.p1 $+ , but nobody wanted to accept your RPS challenge!  FeelsBadMan
      .timer.rps.wait2 1 90 UNSET %rps.*
      .timer.rps.wait3 1 90 SET -z %RPS_CD. $+ $nick %rps_cd
    }
    ELSEIF ($3) && ($3 != $me) {
      VAR %target $remove($3, @)
      IF (%target ison $chan) {
        IF ($checkpoints(%target, $2) == false) MSG $chan $twitch_name($nick) $+ , $twitch_name(%target) doesn't have enough %curname to play.  FailFish
        ELSE {
          SET %rps.p1 $twitch_name($nick)
          SET %rps.p2 $twitch_name(%target)
          SET %rps.bet $floor($2)
          MSG $chan KAPOW %rps.p1 has issued a Rock/Paper/Scissors challenge for %rps.bet %curname to %rps.p2 $+ !  %rps.p2 now has 90 seconds to accept this challenge by typing "!rps accept"
          .timer.rps.wait1 1 90 MSG $chan Sorry, %rps.p1 $+ , but %rps.p2 didn't want to accept your RPS challenge!  FeelsBadMan
          .timer.rps.wait2 1 90 UNSET %rps.*
          .timer.rps.wait3 1 90 SET -z %RPS_CD. $+ $nick %rps_cd
        }
      }
      ELSE MSG $chan $twitch_name($nick) $+ , %target is not the name of a user here in the channel.  Please check the spelling and make sure that they are actually here.
    }
  }
  ELSEIF ((%rps.p1) && ($nick != %rps.p1) && ($2 == accept)) {
    IF (!%rps.p2) {
      IF ($checkpoints($nick, %rps.bet) == false) MSG $chan $twitch_name($nick) $+ , you don't have enough %curname to play.  FailFish
      ELSE SET %rps.p2 $twitch_name($nick)
    }
    IF ((%rps.p2 == $nick) && (!$timer(.rps.start)) && (!%rps.on) && (!$timer(.rps.end))) {
      .timer.rps.wait* off
      MSG $chan %rps.p2 has accepted the RPS challenge of %rps.p1 $+ !  In a few seconds, I will WHISPER both players and ask for their choice, and the winning player will win %rps.bet %curname from the other player!
      .timer.rps.start 1 4 rps_start
    }
  }
  ELSEIF (!%rps.p1) {
    IF (%floodrpsinfo) halt
    SET -u6 %floodrpsinfo On
    MSG $chan Play Rock/Paper/Scissors with a friend to try and win each others %curname $+ !  Just type "!rps $chr(91) $+ %rps_minbet $+ - $+ %rps_maxbet $+ $chr(93) $+ " to play against ANYONE, -or- type "!rps $chr(91) $+ %rps_minbet $+ - $+ %rps_maxbet $+ $chr(93) username" to play against a specific person! ▌ Example:  !rps %rps_maxbet
  }
}


alias rps_start {
  SET %rps.on On
  MSG %rps.p1 %rps.p1 $+ , please enter your choice of rock, paper, or scissors. (you only need to enter the first letter of your choice) View the result in %streamer $+ 's main chat.
  MSG %rps.p2 %rps.p2 $+ , please enter your choice of rock, paper, or scissors. (you only need to enter the first letter of your choice) View the result in %streamer $+ 's main chat.
  .timer.rps.tooslow 1 60 rps_tooslow
}


ON *:TEXT:*:?:{
  IF (%rps.on) {
    IF ($nick == %rps.p1) && (!%rps.p1c) {
      IF ($left($1,1) == r) SET %rps.p1c Rock
      ELSEIF ($left($1,1) == p) SET %rps.p1c Paper
      ELSEIF ($left($1,1) == s) SET %rps.p1c Scissors
    }
    ELSEIF ($nick == %rps.p2) && (!%rps.p2c) {
      IF ($left($1,1) == r) SET %rps.p2c Rock
      ELSEIF ($left($1,1) == p) SET %rps.p2c Paper
      ELSEIF ($left($1,1) == s) SET %rps.p2c Scissors
    }
    IF (%rps.p1c) && (%rps.p2c) {
      .timer.rps.tooslow off
      UNSET %rps.on
      IF (%rps.p1c == %rps.p2c) .timer.rps.end 1 3 rps_draw
      ELSEIF (%rps.p1c == Paper) && (%rps.p2c == Rock) .timer.rps.end 1 3 rps_win1
      ELSEIF (%rps.p1c == Scissors) && (%rps.p2c == Paper) .timer.rps.end 1 3 rps_win1
      ELSEIF (%rps.p1c == Rock) && (%rps.p2c == Scissors) .timer.rps.end 1 3 rps_win1
      ELSEIF (%rps.p1c == Rock) && (%rps.p2c == Paper) .timer.rps.end 1 3 rps_win2
      ELSEIF (%rps.p1c == Paper) && (%rps.p2c == Scissors) .timer.rps.end 1 3 rps_win2
      ELSEIF (%rps.p1c == Scissors) && (%rps.p2c == Rock) .timer.rps.end 1 3 rps_win2
      SET -z %RPS_CD. $+ %rps.p1 %rps_cd
    }
  }
}


alias rps_tooslow {
  IF (!%rps.p1c) && (!%rps.p2c) {
    MSG %mychan Both %rps.p1 and %rps.p2 did not make a choice!  They both lose %rps.bet %curname $+ !
    REMOVEPOINTS %rps.p1 %rps.bet
    REMOVEPOINTS %rps.p2 %rps.bet
  }
  ELSEIF (!%rps.p1c) {
    MSG %mychan %rps.p1 did not make a choice!  %rps.p2 wins %rps.bet %curname from %rps.p1 $+ !
    ADDPOINTS %rps.p2 %rps.bet
    REMOVEPOINTS %rps.p1 %rps.bet
  }
  ELSEIF (!%rps.p2c) {
    MSG %mychan %rps.p2 did not make a choice!  %rps.p1 wins %rps.bet %curname from %rps.p2 $+ !
    ADDPOINTS %rps.p1 %rps.bet
    REMOVEPOINTS %rps.p2 %rps.bet
  }
  UNSET %rps.*
}

alias rps_draw {
  MSG %mychan %rps.p1 and %rps.p2 both chose %rps.p1c $+ .  The game is tied!
  UNSET %rps.*
}

alias rps_win1 {
  MSG %mychan %rps.p1c beats %rps.p2c $+ ! %rps.p1 wins %rps.bet %curname from %rps.p2 $+ !
  ADDPOINTS %rps.p1 %rps.bet
  REMOVEPOINTS %rps.p2 %rps.bet
  UNSET %rps.*
}

alias rps_win2 {
  MSG %mychan %rps.p2c beats %rps.p1c $+ ! %rps.p2 wins %rps.bet %curname from %rps.p1 $+ !
  ADDPOINTS %rps.p2 %rps.bet
  REMOVEPOINTS %rps.p1 %rps.bet
  UNSET %rps.*
}
