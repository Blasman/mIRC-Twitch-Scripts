;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; VARIABLES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

/*
HEY!  LOOK HERE!  This is what you need to change in this script...

Change the %dice_minbet and %dice_maxbet to the minimum and maximum
amount of points that must spend in order to play !dice.

The %dice_cd variable is the amount of time (in seconds) before another
dice game can be played after a game has just finished.  Set this
to 0 for there to be no cooldown.

The %dice_repeat variable is the amount of time (in seconds) that the
bot will repeat the message that the game is open in the channel if no
on has started a game yet.  Set this to 0 to disable this message.

You will need to UNLOAD and RE-LOAD this script for any changes to the
variables below to take effect.  This can be done by pressing ALT-R in
mIRC > Select "View" > Select "dice.mrc" > Click on "File" > "Unload."
Then, click on "File" and "Load..." and select the dice.mrc file again.

Have fun!!!
*/

ON *:LOAD: {
  SET %dice_minbet 50
  SET %dice_maxbet 500
  SET %dice_cd 900
  SET %dice_repeat 2700
  SET %dice_options high low middle top bottom 2 3 4 5 6 7 8 9 10 11 12
}

ON *:UNLOAD: { UNSET %dice_* | .timer.dice.* off }

ON *:CONNECT: {
  IF ($server == tmi.twitch.tv) {
    UNSET %dice.*
    IF ($isfile(dicebets.txt)) REMOVE dicebets.txt
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DICE GAME ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON $*:TEXT:/^!dice\s(((on|off|help)$)|minbet|maxbet|cd|repeat)/iS:%mychan: {
  IF ($nick isop $chan) {
    IF ($2 == on) {
      IF (!%GAMES_DICE_ACTIVE) {
        SET %GAMES_DICE_ACTIVE On
        MSG $chan $nick $+ , the Dice game is now enabled!  Type !dice for more info!  Have fun!  PogChamp
      }
      ELSE MSG $chan $nick $+ , !dice is already enabled.  FailFish
    }
    ELSEIF ($2 == off) {
      IF (%GAMES_DICE_ACTIVE) {
        UNSET %GAMES_DICE_ACTIVE
        .timer.dice.* off
        MSG $chan $nick $+ , the Dice game is now disabled.
      }
      ELSE MSG $chan $nick $+ , Dice is already disabled.  FailFish
    }
    ELSEIF (($2 == minbet) && ($regex($3,^\d+$))) {
      SET %dice_minbet $3
      MSG $chan $nick $+ , the minimum bet for !dice has been set to %dice_minbet %curname $+ .
    }
    ELSEIF (($2 == maxbet) && ($regex($3,^\d+$))) {
      SET %dice_maxbet $3
      MSG $chan $nick $+ , the maximum bet for !dice has been set to %dice_maxbet %curname $+ .
    }
    ELSEIF (($2 == cd) && ($regex($3,^\d+$))) {
      SET %dice_cd $3
      MSG $chan $nick $+ , the cooldown for the !dice game has been set to %dice_cd seconds.
    }
    ELSEIF (($2 == repeat) && ($regex($3,^\d+$))) {
      SET %dice_repeat $3
      MSG $chan $nick $+ , the !dice announce message will be posted into chat every %dice_repeat seconds.
    }
    ELSEIF ($2 == help) MSG $chan !dice mod commands ▌ !dice [on/off] ▌ !dice minbet $chr(35) ▌ !dice maxbet $chr(35) ▌ !dice cd $chr(35) ▌ !dice repeat $chr(35)
  }
}

ON $*:TEXT:/^!dice(\s|$)/iS:%mychan: {
  IF (!%GAMES_DICE_ACTIVE) {
    IF ((%floodDICE_ACTIVE) || ($($+(%,floodDICE_ACTIVE.,$nick),2))) halt
    SET -u15 %floodDICE_ACTIVE On
    SET -u120 %floodDICE_ACTIVE. $+ $nick On
    MSG $chan $nick $+ , the Dice game is currently disabled.
  }
  ELSEIF ($timer(.dice.reopen)) {
    IF ((%floodDICEreopen) || ($($+(%,floodDICEreopen.,$nick),2))) halt
    SET -u15 %floodDICEreopen On
    SET -u60 %floodDICEreopen. $+ $nick On
    MSG $chan Relax, $nick $+ !  I will announce the next Dice game in $duration($timer(.dice.reopen).secs) $+ !  SwiftRage
  }
  ELSEIF ((%dice.closed) || (%dice.bet. [ $+ [ $nick ] ]) || (%ActiveGame) || ($timer(.dice.reopen2)) || (%rr.p1)) halt
  ELSEIF (($istok(%dice_options,$2,32)) && ($3 isnum %dice_minbet - %dice_maxbet)) {
    VAR %wager $floor($3)
    IF ($GetPoints($nick) < %wager) MSG $chan $nick $+ , you don't have %wager %curname to wager.  FailFish
    ELSE {
      REMOVEPOINTS $nick %wager
      SET %dice.bet. [ $+ [ $nick ] ] On
      IF ($isfile(dicebets.txt)) {
        WRITE dicebets.txt $nick $2 %wager
        $wdelay(MSG $nick $nick $+ $chr(44) you have bet %wager %curname on $2 $+ .)
      }
      ELSE {
        IF ($timer(.dice.repeat)) timer.dice.repeat off
        WRITE dicebets.txt $nick $2 %wager
        .timerDiceBegin1 1 120 DESCRIBE $chan is now rolling the dice to see who is going to win the game of dice!
        .timerDiceBegin2 1 120 SET %dice.closed On
        .timerDiceBegin3 1 130 diceroll
        MSG $chan $nick has started a game of Dice!  Everyone has two minutes to get in their bets!  Bet any amount of %curname from %dice_minbet to %dice_maxbet $+ ! ▌ Use:  !dice [option] [amount] ▌  Example:  !dice high %dice_minbet ▌ For all betting options, see http://i.imgur.com/bY1Q42Z.png
      }
    }
  }
  ELSEIF (($istok(%dice_options,$2,32)) && ($3 isnum) && ($3 !isnum %dice_minbet - %dice_maxbet)) {
    IF ($($+(%,floodDICEwager.,$nick),2)) halt
    SET -u15 %floodDICEwager. $+ $nick On
    $wdelay(MSG $nick $nick $+ $chr(44) please make a valid wager between %dice_minbet and %dice_maxbet %curname $+ .)
  }
  ELSEIF ($3 isnum %dice_minbet - %dice_maxbet) {
    IF ($($+(%,floodDICEoption.,$nick),2)) halt
    SET -u15 %floodDICEoption. $+ $nick On
    $wdelay(MSG $nick $nick $+ $chr(44) please bet on a valid betting option.  See http://i.imgur.com/bY1Q42Z.png for options.)
  }
  ELSE {
    IF ((%floodDICEinfo) || ($($+(%,floodDICEinfo.,$nick),2))) halt
    SET -u15 %floodDICEinfo On
    SET -u60 %floodDICEinfo. $+ $nick On
    MSG $chan $nick $+ , you may bet any amount of %curname from %dice_minbet to %dice_maxbet on Dice! ▌ Use:  !dice [option] [amount] ▌  Example:  !dice high %dice_minbet ▌ For all betting options, see http://i.imgur.com/bY1Q42Z.png
  }
}

alias diceroll {
  VAR %dice.1 = $rand(1,6)
  VAR %dice.2 = $rand(1,6)
  VAR %dice.total = %dice.1 + %dice.2
  IF (%dice.total == 2) VAR %bets 2 low bottom
  ELSEIF (%dice.total == 3) VAR %bets 3 low bottom
  ELSEIF (%dice.total == 4) VAR %bets 4 low bottom
  ELSEIF (%dice.total == 5) VAR %bets 5 low bottom
  ELSEIF (%dice.total == 6) VAR %bets 6 low middle
  ELSEIF (%dice.total == 7) VAR %bets 7 middle
  ELSEIF (%dice.total == 8) VAR %bets 8 high middle
  ELSEIF (%dice.total == 9) VAR %bets 9 high top
  ELSEIF (%dice.total == 10) VAR %bets 10 high top
  ELSEIF (%dice.total == 11) VAR %bets 11 high top
  ELSEIF (%dice.total == 12) VAR %bets 12 high top
  DESCRIBE %mychan rolls a $chr(91) $+ %dice.1 $+ $chr(93) and a $chr(91) $+ %dice.2 $+ $chr(93) for a total of $chr(91) $+ %dice.total $+ $chr(93) ...
  VAR %x = 1
  WHILE ($read(dicebets.txt, %x) != $null) {
    VAR %nick $gettok($read(dicebets.txt, %x), 1, 32)
    VAR %bet $gettok($read(dicebets.txt, %x), 2, 32)
    VAR %amount $gettok($read(dicebets.txt, %x), 3, 32)
    IF ($istok(%bets,%bet,32)) {
      IF ((%bet == high) || (%bet == low)) VAR %winnings $floor($calc(%amount * 2.4))
      ELSEIF ((%bet == top) || (%bet == bottom)) VAR %winnings $floor($calc(%amount * 3.6))
      ELSEIF (%bet == middle) VAR %winnings $floor($calc(%amount * 2.25))
      ELSEIF ((%bet == 2) || (%bet == 12)) VAR %winnings $calc(%amount * 36)
      ELSEIF ((%bet == 3) || (%bet == 11)) VAR %winnings $calc(%amount * 18)
      ELSEIF ((%bet == 4) || (%bet == 10)) VAR %winnings $calc(%amount * 12)
      ELSEIF ((%bet == 5) || (%bet == 9)) VAR %winnings $calc(%amount * 9)
      ELSEIF ((%bet == 6) || (%bet == 8)) VAR %winnings $floor($calc(%amount * 7.2))
      ELSEIF (%bet == 7) VAR %winnings $calc(%amount * 6)
      VAR %winnersList %winnersList %nick $chr(40) $+ %winnings on %bet $+ $chr(41) -
      ADDPOINTS %nick %winnings
    }
    INC %x
  }
  IF (%winnersList) .timer.dice.outcome 1 3 MSG %mychan CONGRATULATIONS TO THE WINNERS OF THE DICE GAME: $left(%winnersList, -1) BloodTrail
  ELSE .timer.dice.outcome 1 3 MSG %mychan Nobody won at dice!  Better luck next time!  :tf:
  .timer.dice.unset2 1 3 UNSET %dice.*
  .timer.dice.unset3 1 3 REMOVE dicebets.txt
  IF (%dice_cd > 0) .timer.dice.reopen 1 $calc(%dice_cd + 3) dicereopen
  IF (%dice_repeat > 0) .timer.dice.repeat 0 $calc(%dice_repeat + 3) dicerepeat
}

alias dicereopen {
  IF (!%ActiveGame) MSG %mychan The Dice game is open again!  You may bet any amount of %curname from %dice_minbet to %dice_maxbet on Dice! ▌ Use:  !dice [option] [amount] ▌  Example:  !dice high %dice_minbet ▌ For all betting options, see http://i.imgur.com/bY1Q42Z.png
  ELSE .timer.dice.reopen2 1 1 dicereopen
}

alias dicerepeat {
  IF (!%ActiveGame) MSG %mychan The Dice game is open!  Place your bets!  You may bet any amount of %curname from %dice_minbet to %dice_maxbet on Dice! ▌ Use:  !dice [option] [amount] ▌  Example:  !dice high %dice_minbet ▌ For all betting options, see http://i.imgur.com/bY1Q42Z.png
  ELSE .timer.dice.repeat 1 1 dicerepeat
}
