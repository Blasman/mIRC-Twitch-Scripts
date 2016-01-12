;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; VARIABLES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

/*
HEY!  LOOK HERE!  This is what you need to change in this script...

Change the %rr_minbet and %rr_maxbet to the minimum and maximum
amount of points that must be spent in order to use !rr.  The
%rr_cd variable is the per user cooldown time (in seconds) that a user
must wait before being able to use !rr again.

You will need to UNLOAD and RE-LOAD this script for any changes to the
variables below to take effect.  This can be done by pressing ALT-R in
mIRC > Select "View" > Select "rr.mrc" > Click on "File" > "Unload."
Then, click on "File" and "Load..." and select the rr.mrc file again.

Have fun!!!
*/

ON *:LOAD: {
  SET %rr_minbet 100
  SET %rr_maxbet 1000
  SET %rr_cd 300
}

ON *:UNLOAD: { UNSET %rr_* }
ON *:CONNECT: {
  IF ($server == tmi.twitch.tv) {
    UNSET %rr.*
    UNSET %RR_CD.*
    IF ($isfile(rrbets.txt)) REMOVE rrbets.txt
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;; RUSSIAN ROULETTE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


ON $*:TEXT:/^!rr\s(on|off)$/iS:#: {

  IF ($nick isop $chan) {
    IF ($2 == on) {
      IF (!%GAMES_RR_ACTIVE) {
        SET %GAMES_RR_ACTIVE On
        MSG $chan $twitch_name($nick) $+ , the Russian Roulette game is now enabled!  Type !rr for more info!  Have fun!  PogChamp
      }
      ELSE MSG $chan $twitch_name($nick) $+ , !rr is already enabled.  FailFish
    }
    ELSEIF ($2 == off) {
      IF (%GAMES_RR_ACTIVE) {
        UNSET %GAMES_RR_ACTIVE
        MSG $chan $twitch_name($nick) $+ , the Russian Roulette game is now disabled.
      }
      ELSE MSG $chan $twitch_name($nick) $+ , Russian Roulette is already disabled.  FailFish
    }
  }
}


ON $*:TEXT:/^!rr(\s|$)/iS:#: {

  IF (($($+(%,floodRR.,$nick),2)) || ((%rr.p1) && (%rr.p2)) || (%ActiveGame) || ($isfile(roulbets.txt))) halt
  SET -u3 %floodRR. $+ $nick On
  IF (!%GAMES_RR_ACTIVE) {
    IF ((%floodRR_ACTIVE) || ($($+(%,floodRR_ACTIVE.,$nick),2))) halt
    SET -u15 %floodRR_ACTIVE On
    SET -u120 %floodRR_ACTIVE. $+ $nick On
    MSG $chan $twitch_name($nick) $+ , the Russian Roulette game is currently disabled.
    halt
  }
  ELSEIF (($2 isnum %rr_minbet - %rr_maxbet) && (!%rr.p1)) {
    IF ($($+(%,RR_CD.,$nick),2)) MSG $nick $twitch_name($nick) $+ , please wait for your cooldown to expire in $duration(%RR_CD. [ $+ [ $nick ] ]) before trying to play Russian Roulette again.
    ELSEIF ($checkpoints($nick, $2) == false) MSG $chan $twitch_name($nick) $+ , you don't have enough %curname to play.  FailFish
    ELSEIF (!$3) {
      SET %rr.p1 $twitch_name($nick)
      SET %rr.bet $floor($2)
      MSG $chan KAPOW %rr.p1 has issued a Russian Roulette challenge for %rr.bet %curname to the first person to accept within 90 seconds!  To accept this challenge type "!rr accept"
      .timer.rr.wait1 1 90 MSG $chan Sorry, %rr.p1 $+ , but nobody wanted to accept your Russian Roulette challenge!  FeelsBadMan
      .timer.rr.wait2 1 90 UNSET %rr.*
      .timer.rr.wait3 1 90 SET -z %RR_CD. $+ $nick %rr_cd
    }
    ELSEIF ($3) && ($3 != $me) {
      VAR %target $remove($3, @)
      IF (%target ison $chan) {
        IF ($checkpoints(%target, $2) == false) MSG $chan $twitch_name($nick) $+ , $twitch_name(%target) doesn't have enough %curname to play.  FailFish
        ELSE {
          SET %rr.p1 $twitch_name($nick)
          SET %rr.p2 $twitch_name(%target)
          SET %rr.bet $floor($2)
          MSG $chan KAPOW %rr.p1 has issued a Russian Roulette challenge for %rr.bet %curname to %rr.p2 $+ !  %rr.p2 now has 90 seconds to accept this challenge by typing "!rr accept"
          .timer.rr.wait1 1 90 MSG $chan Sorry, %rr.p1 $+ , but %rr.p2 didn't want to accept your Russian Roulette challenge!  FeelsBadMan
          .timer.rr.wait2 1 90 UNSET %rr.*
          .timer.rr.wait3 1 90 SET -z %RR_CD. $+ $nick %rr_cd
        }
      }
      ELSE MSG $chan $twitch_name($nick) $+ , $3 is not the name of a user here in the channel.  Please check the spelling and make sure that they are actually here.
    }
  }
  ELSEIF ((%rr.p1) && ($nick != %rr.p1) && ($2 == accept)) {
    IF (!%rr.p2) {
      IF ($checkpoints($nick, %rr.bet) == false) MSG $chan $twitch_name($nick) $+ , you don't have enough %curname to play.  FailFish
      ELSE SET %rr.p2 $twitch_name($nick)
    }
    IF ((%rr.p2 == $nick) && (!%rr.safeguard)) {
      .timer.rr.wait* off
      MSG $chan %rr.p2 has accepted the Russian Roulette challenge of %rr.p1 $+ !  Betting is now open for the next 90 seconds on who will be the survivor!  To place bets, type !rrbet [user] $chr(91) $+ %rr_minbet $+ - $+ %rr_maxbet $+ $chr(93) ▌ Example: !rrbet %rr.p1 %rr_maxbet
      SET %rr.safeguard On
      SET %rr.openbets On
      timer.rr.start 1 90 rrstart
    }
  }
  ELSEIF (!%rr.p1) {
    IF (%floodrrinfo) halt
    SET -u10 %floodrrinfo On
    MSG $chan Play Russian Roulette with a friend to try and win each others %curname $+ !  Just type "!rr $chr(91) $+ %rr_minbet $+ - $+ %rr_maxbet $+ $chr(93) $+ " to play against ANYONE, -or- type "!rr $chr(91) $+ %rr_minbet $+ - $+ %rr_maxbet $+ $chr(93) username" to play against a specific person! ▌ Example:  !rps %rr_maxbet
  }
}


ON $*:TEXT:/^!rrbet\s/iS:#: {

  IF ((%rr.openbets) && ($nick != %rr.p1) && ($nick != %rr.p2) && (!%rr.bet. [ $+ [ $nick ] ]) && (($2 == %rr.p1) || ($2 == %rr.p2)) && ($3 isnum %rr_minbet - %rr_maxbet)) {
    IF ($checkpoints($nick, $floor($3)) == false) {
      IF ($($+(%,floodRR_TOOPOOR.,$nick),2)) halt
      SET -u10 %floodRR_TOOPOOR. $+ $nick On
      MSG $chan $twitch_name($nick) $+ , you don't have enough %curname to make that bet!  FailFish
    }
    ELSE {
      VAR %nick $twitch_name($nick)
      VAR %wager $floor($3)
      REMOVEPOINTS $nick %wager
      IF ($2 == %rr.p1) VAR %beton %rr.p1
      ELSE VAR %beton %rr.p2
      SET %rr.bet. [ $+ [ $nick ] ] On
      WRITE rrbets.txt %nick %beton %wager
      $wdelay(MSG $nick %nick $+ $chr(44) you have bet %wager %curname that %beton will be the survivor.  Good luck!  BloodTrail)
    }
  }
}


alias rrstart {

  UNSET %rr.openbets
  MSG %mychan It has begun!  %rr.p1 loads one bullet, puts the cylinder inside the revolver, spins it around, and places the cold barrel of the gun to their temple and gets ready to take the shot... WutFace
  VAR %chamber $rand(1,6)
  IF (%chamber == 1) {
    .timer.rr.msg01 1 11 MSG %mychan REKT! Well, that didn't last long at all!  %rr.p1 lays lifeless on the ground, and %rr.p2 takes %rr.bet %curname from %rr.p1 $+ !  BrokeBack
    SET %rr.winner %rr.p2
    SET %rr.loser %rr.p1
    .timer.rr.payout 1 13 rrpayout
  }
  ELSE {
    .timer.rr.msg02 1 11 MSG %mychan *CLICK!*  %rr.p1 survives the first round!  %rr.p1 happily passes the gun to %rr.p2 $+ ... FeelsGoodMan
    DEC %chamber
    IF (( %chamber == 1 )) {
      .timer.rr.msg03 1 22 MSG %mychan REKT! Well, that didn't last very long... %rr.p2 lays lifeless on the ground, and %rr.p1 removes %rr.bet %curname from %rr.p2 $+ !  BrokeBack
      SET %rr.winner %rr.p1
      SET %rr.loser %rr.p2
      .timer.rr.payout 1 24 rrpayout
    }
    ELSE {
      .timer.rr.msg04 1 22 MSG %mychan *CLICK!*  %rr.p2 survives round two!  %rr.p2 gladly hands the gun back to %rr.p1 $+ ... FeelsGoodMan
      DEC %chamber
      IF (( %chamber == 1 )) {
        .timer.rr.msg05 1 33 MSG %mychan REKT! Game Over! %rr.p1 blew their brains out, and %rr.p2 takes %rr.bet %curname from the wasted body of %rr.p1 $+ !  BrokeBack
        SET %rr.winner %rr.p2
        SET %rr.loser %rr.p1
        .timer.rr.payout 1 35 rrpayout
      }
      ELSE {
        .timer.rr.msg06 1 33 MSG %mychan *CLICK!*  %rr.p1 lives through round three!  %rr.p1 willingly passes the gun back to %rr.p2 $+ !  PogChamp
        DEC %chamber
        IF (( %chamber == 1 )) {
          .timer.rr.msg07 1 44 MSG %mychan %rr.p2 got REKT!  %rr.p1 removes %rr.bet %curname from the dead body of %rr.p2 $+ !  BrokeBack
          SET %rr.winner %rr.p1
          SET %rr.loser %rr.p2
          .timer.rr.payout 1 46 rrpayout
        }
        ELSE {
          .timer.rr.msg08 1 44 MSG %mychan *CLICK!*  Wow!  %rr.p2 has survived the fourth round!  %rr.p2 breathes a sigh of relief and passes the gun back to %rr.p1 $+ ... PogChamp
          DEC %chamber
          IF (( %chamber == 1 )) {
            .timer.rr.msg09 1 55 MSG %mychan REKT! %rr.p1 could not survive round five... %rr.p2 takes %rr.bet %curname from the lifeless body of %rr.p1 $+ ... BrokeBack
            SET %rr.winner %rr.p2
            SET %rr.loser %rr.p1
            .timer.rr.payout 1 57 rrpayout
          }
          ELSE {
            .timer.rr.msg10 1 55 MSG %mychan *CLICK!*  OMG!  %rr.p1 lives through round five!  With a maniacal smile, %rr.p1 laughs and hands the gun back to %rr.p2 $+ ... :tf:
            DEC %chamber
            IF (( %chamber == 1 )) {
              .timer.rr.msg11 1 66 MSG %mychan REKT!  There was no surviving the final round for %rr.p2 $+ ... %rr.p1 removes %rr.bet %curname from the corpse of %rr.p2 $+ .
              SET %rr.winner %rr.p1
              SET %rr.loser %rr.p2
              .timer.rr.payout 1 68 rrpayout
            }
          }
        }
      }
    }
  }
}


alias rrpayout {

  REMOVEPOINTS %rr.loser %rr.bet
  ADDPOINTS %rr.winner %rr.bet
  IF ($isfile(rrbets.txt)) {
    VAR %x = 1
    WHILE ($read(rrbets.txt, %x) != $null) {
      VAR %nick $wildtok($read(rrbets.txt, %x), *, 1, 32)
      VAR %winlose $wildtok($read(rrbets.txt, %x), *, 2, 32)
      VAR %amount $wildtok($read(rrbets.txt, %x), *, 3, 32)
      IF (%winlose == %rr.winner) {
        VAR %winnings = %amount * 2
        VAR %winnersList %winnersList %nick $chr(40) $+ %winnings $+ $chr(41) -
        ADDPOINTS %nick %winnings
      }
      INC %x
    }
    IF (%winnersList) {
      VAR %winnersList $left(%winnersList, -1) BloodTrail
      .timer.endroul 1 3 MSG %mychan Congratulations to everyone who bet on %rr.winner $+ : %winnersList
    }
    ELSE MSG %mychan Nobody bet on %rr.winner $+ !  Better luck next time!  :tf:
    REMOVE rrbets.txt
  }
  SET -z %RR_CD. $+ %rr.p1 %rr_cd
  UNSET %rr.*
}
