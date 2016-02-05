;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;; QUEENULHU'S DUEL GAME ;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON *:LOAD: {
  IF (!%duel_cd) SET %duel_cd 60
  IF (!%duel_minbet) SET %duel_minbet 1
  IF (!%duel_maxbet) SET %duel_maxbet 100
}

ON *:UNLOAD: UNSET %duel*

ON *:CONNECT: IF ($server == tmi.twitch.tv) { UNSET %duel.* | UNSET %DUEL_CD.* }

ON $*:TEXT:/^!duel\s(on|off|cd|minbet|maxbet|help)/iS:%mychan: {
  IF ($nick isop $chan) {
    IF ($2 == on) {
      IF (!%GAMES_DUEL_ACTIVE) {
        SET %GAMES_DUEL_ACTIVE On
        MSG $chan $nick $+ , the Duel game is now enabled! Type "!duel rules" for more info! Have fun!  PogChamp
      }
      ELSE MSG $chan $nick $+ , !duel is already enabled. FailFish Type "!duel rules" for more info!
    }
    ELSEIF ($2 == off) {
      IF (%GAMES_DUEL_ACTIVE) {
        UNSET %GAMES_DUEL_ACTIVE
        MSG $chan $nick $+ , the Duel game is now disabled.
      }
      ELSE MSG $chan $nick $+ , the Duel game is already disabled.  FailFish
    }
    ELSEIF (($2 == cd) && ($regex($3,^\d+$))) {
      SET %duel_cd $3
      MSG $chan The per-user cooldown for !duel has been set to $3 seconds.
    }
    ELSEIF (($2 == minbet) && ($regex($3,^\d+$))) {
      SET %duel_minbet $3
      MSG $chan The minimum bet for !duel has been set to $3 %curname $+ .
    }
    ELSEIF (($2 == maxbet) && ($regex($3,^\d+$))) {
      SET %duel_maxbet $3
      MSG $chan The maximum bet for !duel has been set to $3 %curname $+ .
    }
    ELSEIF ($2 == help) MSG $chan !DUEL COMMANDS FOR MODS: ✧ !duel on: enable the game ✧ !duel off: disable the game ✧ !duel cd [number]: set the per-user cooldown time (in seconds) ✧ !duel minbet [number]: set the minimum bet for !duel ✧ !duel maxbet [number]: set the maximum bet for !duel
  }
}

ON $*:TEXT:/^!duel(\s|$)/iS:%mychan: {
  IF (($($+(%,floodDUEL.,$nick),2)) || (%ActiveGame)) halt
  SET -eu3 %floodDUEL. $+ $nick On
  IF (!%GAMES_DUEL_ACTIVE) {
    IF ((%floodDUEL_ACTIVE) || ($($+(%,floodDUEL_ACTIVE.,$nick),2))) halt
    SET -eu15 %floodDUEL_ACTIVE On
    SET -eu120 %floodDUEL_ACTIVE. $+ $nick On
    MSG $chan $nick $+ , the Duel game is currently disabled.
    halt
  }
  ELSEIF ((!%duel.p1) && ($2 isnum %duel_minbet - %duel_maxbet) && ($regex($2,^\d+$))) {
    IF ($($+(%,DUEL_CD.,$nick),2)) MSG $nick $twitch_name($nick) $+ , please wait for your cooldown to expire in $duration(%DUEL_CD. [ $+ [ $nick ] ]) before trying to duel again.
    ELSEIF ($checkpoints($nick, $2) == false) MSG $chan $nick $+ , you don't have enough %curname to play.  FailFish
    ELSEIF (!$3) {
      SET %duel.p1 $nick
      SET %duel.bet $2
      MSG $chan %duel.p1 has issued an open challenge for a duel for %duel.bet %curname $+ ! swordBopR To accept this challenge, type !duel accept
      .timer.duel.wait1 1 90 MSG $chan Sorry, %duel.p1 $+ , but nobody wanted to accept your duel!  FeelsBadMan
      .timer.duel.wait2 1 90 UNSET %duel.*
      .timer.duel.wait3 1 90 SET -z %DUEL_CD. $+ $nick %duel_cd
    }
    ELSEIF ($3) && ($3 != $me) {
      VAR %target $remove($3, @)
      IF (%target ison $chan) {
        IF ($checkpoints(%target, $2) == false) MSG $chan $nick $+ , $twitch_name(%target) doesn't have enough %curname to play.  FailFish
        ELSE {
          SET %duel.p1 $nick
          SET %duel.p2 $twitch_name(%target)
          SET %duel.bet $2
          MSG $chan %duel.p1 has challenged %duel.p2 to a duel for %duel.bet %curname $+ ! swordBopR %duel.p2 has 90 seconds to accept this challenge by typing !duel accept
          .timer.duel.wait1 1 90 MSG $chan Sorry, %duel.p1 $+ , but %duel.p2 didn't want to accept your duel!  FeelsBadMan
          .timer.duel.wait2 1 90 UNSET %duel.*
          .timer.duel.wait3 1 90 SET -z %DUEL_CD. $+ $nick %duel_cd
        }
      }
      ELSE MSG $chan $nick $+ , $3 is not the name of a user here in the channel.  Please check the spelling and make sure that they are actually here.
    }
  }
  ELSEIF ((%duel.p1) && ($nick != %duel.p1) && ($2 == accept)) {
    IF (!%duel.p2) {
      IF ($checkpoints($nick, %duel.bet) == false) MSG $chan $nick $+ , you don't have enough %curname to play.  FailFish
      ELSE SET %duel.p2 $nick
    }
    IF (%duel.p2 == $nick) {
      SET %ActiveGame On
      REMOVEPOINTS %duel.p1 %duel.bet
      REMOVEPOINTS %duel.p2 %duel.bet
      .timer.duel.wait* off
      :roll
      VAR %duel.p1.int $rand(1,20)
      VAR %duel.p2.int $rand(1,20)
      IF (%duel.p1.int == %duel.p2.int) goto roll
      IF (%duel.p1.int > %duel.p2.int) VAR %duel.turn %duel.p1
      ELSE VAR %duel.turn %duel.p2
      MSG $chan %duel.p2 has accepted the duel proposed by %duel.p1 $+ ! swordBopR %duel.p1 rolls a d20 for initiative! $chr(91) $+ %duel.p1.int $+ $chr(93) ✧ %duel.p2 rolls a d20 for initiative! $chr(91) $+ %duel.p2.int $+ $chr(93) ✧ %duel.turn attacks first!
      VAR %duel.p1.hp 20
      VAR %duel.p2.hp 20
      VAR %x = 1
      VAR %y = 0
      WHILE ((%duel.p1.hp > 0) && (%duel.p2.hp > 0)) {
        INC %y 6
        VAR %duel.acc $rand(1,20)
        VAR %duel.dmg $rand(1,6)
        IF (%duel.acc isnum 1) {
          IF (%duel.turn == %duel.p1) VAR %duel.p1.hp = %duel.p1.hp - %duel.dmg
          ELSE VAR %duel.p2.hp = %duel.p2.hp - %duel.dmg
        }
        ELSEIF (%duel.acc isnum 10-19) {
          IF (%duel.turn == %duel.p1) VAR %duel.p2.hp = %duel.p2.hp - %duel.dmg
          ELSE VAR %duel.p1.hp = %duel.p1.hp - %duel.dmg
        }
        ELSEIF (%duel.acc isnum 20) {
          IF (%duel.turn == %duel.p1) VAR %duel.p2.hp $calc(%duel.p2.hp - %duel.dmg - 2)
          ELSE VAR %duel.p1.hp $calc(%duel.p1.hp - %duel.dmg - 2)
        }
        IF (%duel.p1.hp < 0) VAR %duel.p1.hp = 0
        IF (%duel.p2.hp < 0) VAR %duel.p2.hp = 0
        IF (%duel.turn == %duel.p1) {
          IF (%duel.acc isnum 1) .timer.attack. $+ %x 1 %y MSG $chan %duel.p1 swings their blade at %duel.p2 $+ ! swordBopR %duel.p1 rolls the dice! Critical miss! %duel.p1 hits themself! $chr(91) $+ %duel.acc $+ $chr(93) ✧ Damage $chr(91) $+ %duel.dmg $+ $chr(93) ✧ %duel.p1 $+ 's HP $chr(91) $+ %duel.p1.hp $+ /20 $+ $chr(93)
          IF (%duel.acc isnum 2-9) .timer.attack. $+ %x 1 %y MSG $chan %duel.p1 swings their blade at %duel.p2 $+ ! swordBopR %duel.p1 rolls the dice! To miss! $chr(91) $+ %duel.acc $+ $chr(93) ✧ %duel.p2 $+ 's HP $chr(91) $+ %duel.p2.hp $+ /20 $+ $chr(93)
          IF (%duel.acc isnum 10-19) .timer.attack. $+ %x 1 %y MSG $chan %duel.p1 swings their blade at %duel.p2 $+ ! swordBopR %duel.p1 rolls the dice! To hit! $chr(91) $+ %duel.acc $+ $chr(93) ✧ Damage $chr(91) $+ %duel.dmg $+ $chr(93) ✧ %duel.p2 $+ 's HP $chr(91) $+ %duel.p2.hp $+ /20 $+ $chr(93)
          IF (%duel.acc isnum 20) .timer.attack. $+ %x 1 %y MSG $chan %duel.p1 swings their blade at %duel.p2 $+ ! swordBopR %duel.p1 rolls the dice! Critical hit! $chr(91) $+ %duel.acc $+ $chr(93) ✧ Damage $chr(91) $+ %duel.dmg $+ $chr(93) + 2 ✧ %duel.p2 $+ 's HP $chr(91) $+ %duel.p2.hp $+ /20 $+ $chr(93)
        }
        ELSEIF (%duel.turn == %duel.p2) {
          IF (%duel.acc isnum 1) .timer.attack. $+ %x 1 %y MSG $chan %duel.p2 swings their blade at %duel.p1 $+ ! swordBopR %duel.p2 rolls the dice! Critical miss! %duel.p2 hits themself! $chr(91) $+ %duel.acc $+ $chr(93) ✧ Damage $chr(91) $+ %duel.dmg $+ $chr(93) ✧ %duel.p2 $+ 's HP $chr(91) $+ %duel.p2.hp $+ /20 $+ $chr(93)
          IF (%duel.acc isnum 2-9) .timer.attack. $+ %x 1 %y MSG $chan %duel.p2 swings their blade at %duel.p1 $+ ! swordBopR %duel.p2 rolls the dice! To miss! $chr(91) $+ %duel.acc $+ $chr(93) ✧ %duel.p1 $+ 's HP $chr(91) $+ %duel.p1.hp $+ /20 $+ $chr(93)
          IF (%duel.acc isnum 10-19) .timer.attack. $+ %x 1 %y MSG $chan %duel.p2 swings their blade at %duel.p1 $+ ! swordBopR %duel.p2 rolls the dice! To hit! $chr(91) $+ %duel.acc $+ $chr(93) ✧ Damage $chr(91) $+ %duel.dmg $+ $chr(93) ✧ %duel.p1 $+ 's HP $chr(91) $+ %duel.p1.hp $+ /20 $+ $chr(93)
          IF (%duel.acc isnum 20) .timer.attack. $+ %x 1 %y MSG $chan %duel.p2 swings their blade at %duel.p1 $+ ! swordBopR %duel.p2 rolls the dice! Critical hit! $chr(91) $+ %duel.acc $+ $chr(93) ✧ Damage $chr(91) $+ %duel.dmg $+ $chr(93) + 2 ✧ %duel.p1 $+ 's HP $chr(91) $+ %duel.p1.hp $+ /20 $+ $chr(93)
        }
        INC %x
        IF (%duel.turn == %duel.p1) VAR %duel.turn %duel.p2
        ELSE VAR %duel.turn %duel.p1
      }
      INC %y 2
      VAR %duel.winnings $calc(%duel.bet * 2)
      IF (%duel.p1.hp == 0) {
        .timer.duel.finish 1 %y MSG $chan %duel.p1 is DEAD!!! %duel.p2 has won %duel.winnings %curname $+ ! queenGasm
        .timer.duel.addpoints 1 %y ADDPOINTS %duel.p2 %duel.winnings
      }
      ELSEIF (%duel.p2.hp == 0) {
        .timer.duel.finish 1 %y MSG $chan %duel.p2 is DEAD!!! %duel.p1 has won %duel.winnings %curname $+ ! queenGasm
        .timer.duel.addpoints 1 %y ADDPOINTS %duel.p1 %duel.winnings
      }
      .timer.duel.cd 1 %y SET -z %DUEL_CD. $+ %duel.p1 %duel_cd
      .timer.duel.unset1 1 %y UNSET %duel.*
      .timer.duel.unset2 1 %y UNSET %ActiveGame
    }
  }
  ELSEIF (!%duel.p1) {
    IF ($2 isnum) {
      IF (%floodDUELFALSEBET) halt
      SET -eu15 %floodDUELFALSEBET On
      MSG $chan $nick $+ , please make a valid wager between %duel_minbet and %duel_maxbet %curname for a !duel.
    }
    ELSEIF ($regex($2,^\w+$)) {
      IF (%floodDUELWRONG) halt
      SET -eu15 %floodDUELWRONG On
      MSG $chan $nick $+ , the proper format for !duel is: !duel [wager] [optional_username] - Example: !duel %duel_maxbet -or- !duel %duel_maxbet %streamer
    }
    ELSE {
      IF (%floodDUELRULES) halt
      SET -eu15 %floodDUELRULES On
      MSG $chan The !duel game is based on dice. To play, type "!duel $chr(91) $+ %duel_minbet $+ - $+ %duel_maxbet $+ $chr(93) $+ " to play against anyone, -or- type "!duel $chr(91) $+ %duel_minbet $+ - $+ %duel_maxbet $+ $chr(93) username" to challenge a specific person. The winner gets all the %curname that both players bet! Example: !duel %duel_maxbet
      .timer.duel.rules 1 2 MSG $chan Here are the rules! You both start with 20 HP. d20 Dice Rolls result in the following: 1 critical FAIL! Take your own damage! 2 - 9 Fail. 10 - 19 Hits. 20 critical SUCCESS! Add +2 to your damage roll! Dice Rolls for damage are rolled with a d6.
    }
  }
}
