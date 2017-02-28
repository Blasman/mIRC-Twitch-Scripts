;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; VARIABLES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

/*
HEY!  LOOK HERE!  This is what you need to change in this script...

Change the %slotc.minbet and %slotc.maxbet to the minimum and maximum
amount of points that must be spent in order to use the !slot.  The
%slotc.cd variable is the per user cooldown time (in seconds) that a user
must wait before being able to use !slot again.

You can just leave the %slotc.# variables or you can change them to the
emotes that you want to use for the slot machine.  The %slotc.1 emote
is the emote that will appear 50% of the time, and the other five
appear more rarely the higher that the number is.

You will need to UNLOAD and RE-LOAD this script for any changes to the
variables below to take effect.  This can be done by pressing ALT-R in
mIRC > Select "View" > Select "slot.mrc" > Click on "File" > "Unload."
Then, click on "File" and "Load..." and select the slot.mrc file again.

If you want to edit what the bot replies for the slot machines win and
losses, you can likely figure that out by looking closely at the script.

Have fun!!!
*/

ON *:LOAD: {
  SET %slotc.minbet 50
  SET %slotc.maxbet 500
  SET %slotc.cd 1800
  SET %slotc.1 bleedPurple
  SET %slotc.2 duDudu
  SET %slotc.3 riPepperonis
  SET %slotc.4 TwitchRPG
  SET %slotc.5 BudStar
  SET %slotc.6 deIlluminati
}

ON *:UNLOAD: { UNSET %slotc.* }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SLOT MACHINE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON $*:TEXT:/^!slot(s)?\s(on|off)/Si:%mychan: {
  IF ($nick isop $chan) {
    IF ($2 == on) {
      IF (!%GAMES_SLOT_ACTIVE) {
        SET %GAMES_SLOT_ACTIVE On
        MSG $chan $nick $+ , !slot is now enabled!  Have fun!  PogChamp
      }
      ELSE MSG $chan $nick $+ , !slot is already enabled.  FailFish
    }
    ELSEIF ($2 == off) {
      IF (%GAMES_SLOT_ACTIVE) {
        UNSET %GAMES_SLOT_ACTIVE
        MSG $chan $nick $+ , !slot is now disabled.
      }
      ELSE MSG $chan $nick $+ , !slot is already disabled.  FailFish
    }
  }
}

ON $*:TEXT:/^!slot(s)?(\s\d+)?$/Si:%mychan: {
  IF ((%ActiveGame == $nick $+ .slot) || ($wildtok(%queue, $nick $+ .slot.*,0,32))) halt
  ELSEIF (!$2) {
    IF ($($+(%,CD_SLOT_HELP.,$nick),2)) halt
    SET -eu10 %CD_SLOT_HELP. $+ $nick On
    MSG $chan You may bet any amount of %curname from %slotc.minbet to %slotc.maxbet on !slot.  ▌  Example:  !slot %slotc.minbet
  }
  ELSEIF (!%GAMES_SLOT_ACTIVE) {
    IF ((%CD_SLOT_ACTIVE) || ($($+(%,CD_SLOT_ACTIVE.,$nick),2))) halt
    SET -eu10 %CD_SLOT_ACTIVE On
    SET -eu120 %CD_SLOT_ACTIVE. $+ $nick On
    MSG $chan $nick $+ , the !slot game is currently disabled.
  }
  ELSEIF ($timer(.SLOT. $+ $nick)) {
    IF ($($+(%,CD_SLOT_CD.,$nick),2)) halt
    SET -eu180 %CD_SLOT_CD. $+ $nick On
    MSG $nick Be patient, $nick $+ !  You still have $duration($timer(.SLOT. $+ $nick).secs) left in your !slot cooldown.
  }
  ELSEIF ($2 !isnum %slotc.minbet - %slotc.maxbet) {
    IF ($($+(%,CD_SLOT_RANGECHECK.,$nick),2)) halt
    SET -eu10 %CD_SLOT_RANGECHECK. $+ $nick On
    MSG $chan $nick $+ , please enter a valid wager between %slotc.minbet and %slotc.maxbet %curname $+ .  ▌  Example:  !slot %slotc.minbet
  }
  ELSEIF ($GetPoints($nick) < $2) {
    IF ($($+(%,CD_SLOT_CHECKPOINTS.,$nick),2)) halt
    SET -eu10 %CD_SLOT_CHECKPOINTS. $+ $nick On
    MSG $chan $nick $+ , you do not have $2 %curname to play slots.  FailFish
  }
  ELSE {
    REMOVEPOINTS $nick $2
    IF (%ActiveGame) SET %queue %queue $nick $+ .slot. $+ $2
    ELSE play_slot $nick $2
  }
}

alias play_slot {
  SET %ActiveGame $1 $+ .slot
  VAR %slotbet $floor($2)
  .timer.SLOT. $+ $1 1 %slotc.cd MSG $1 $1 $+ , your !slot cooldown has expired.  Feel free to play again.  BloodTrail
  MSG %mychan $1 pulls the slot machine lever...
  VAR %x = 1
  WHILE (%x <= 3) {
    VAR %random $rand(1,100)
    IF (%random isnum 1-50) VAR %col. $+ %x %slotc.1
    ELSEIF (%random isnum 51-65) VAR %col. $+ %x %slotc.2
    ELSEIF (%random isnum 66-79) VAR %col. $+ %x %slotc.3
    ELSEIF (%random isnum 80-88) VAR %col. $+ %x %slotc.4
    ELSEIF (%random isnum 89-95) VAR %col. $+ %x %slotc.5
    ELSEIF (%random isnum 96-100) VAR %col. $+ %x %slotc.6
    INC %x
  }
  IF ((%col.1 == %col.2) && (%col.2 == %col.3)) {
    IF (%col.1 == %slotc.1) VAR %payout = %slotbet * 5
    ELSEIF (%col.1 == %slotc.2) VAR %payout = %slotbet * 10
    ELSEIF (%col.1 == %slotc.3) VAR %payout = %slotbet * 15
    ELSEIF (%col.1 == %slotc.4) VAR %payout = %slotbet * 25
    ELSEIF (%col.1 == %slotc.5) VAR %payout = %slotbet * 50
    ELSEIF (%col.1 == %slotc.6) VAR %payout = %slotbet * 100
    .timer.slotc1 1 4 DESCRIBE %mychan  ▌ %col.1 ▌  :::  Good Luck, $1 $+ .  BloodTrail
    .timer.slotc2 1 9 DESCRIBE %mychan  ▌ %col.1 ▌ %col.2 ▌   :::   OMG, $1 $+ , you might win this!  FeelsGoodMan
    .timer.slotc3 1 18 DESCRIBE %mychan  ▌ %col.1 ▌ %col.2 ▌ %col.3 ▌   :::  You WON %payout %curname $+ , $1 $+ !!!  PogChamp
    .timer.slotpayout 1 18 ADDPOINTS $1 %payout
    .timer.slotstop 1 18 end_game
  }
  ELSEIF ((%col.1 == %col.2) && (%col.2 != %col.3) && (%col.3 == %slotc.1)) {
    VAR %payout = %slotbet
    .timer.slotc1 1 4 DESCRIBE %mychan  ▌ %col.1 ▌  :::  Good Luck, $1 $+ .  BloodTrail
    .timer.slotc2 1 9 DESCRIBE %mychan  ▌ %col.1 ▌ %col.2 ▌   :::   OMG, $1 $+ , you might win this!  FeelsGoodMan
    .timer.slotc3 1 18 DESCRIBE %mychan  ▌ %col.1 ▌ %col.2 ▌ %col.3 ▌   :::  Well, $1 $+ , at least you won %payout %curname $+ !  MingLee
    .timer.slotpayout 1 18 ADDPOINTS $1 %payout
    .timer.slotstop 1 18 end_game
  }
  ELSEIF ((%col.1 == %col.2) && (%col.2 != %col.3) && (%col.3 != %slotc.1)) {
    .timer.slotc1 1 4 DESCRIBE %mychan  ▌ %col.1 ▌  :::  Good Luck, $1 $+ .  BloodTrail
    .timer.slotc2 1 9 DESCRIBE %mychan  ▌ %col.1 ▌ %col.2 ▌   :::   OMG, $1 $+ , you might win this!  FeelsGoodMan
    .timer.slotc3 1 18 DESCRIBE %mychan  ▌ %col.1 ▌ %col.2 ▌ %col.3 ▌   :::  You Lose, $1 $+ !  :tf:
    .timer.slotstop 1 18 end_game
  }
  ELSEIF ((%col.2 == %slotc.1) && (%col.3 == %slotc.1)) {
    VAR %payout = %slotbet * 2
    .timer.slotc1 1 4 DESCRIBE %mychan  ▌ %col.1 ▌  :::  Good Luck, $1 $+ .  BloodTrail
    .timer.slotc2 1 9 DESCRIBE %mychan  ▌ %col.1 ▌ %col.2 ▌   :::   Well, $1 $+ , best of luck getting another %slotc.1  ...
    .timer.slotc3 1 15 DESCRIBE %mychan  ▌ %col.1 ▌ %col.2 ▌ %col.3 ▌   :::  You WON %payout %curname $+ , $1 $+ !!!  PogChamp
    .timer.slotpayout 1 15 ADDPOINTS $1 %payout
    .timer.slotstop 1 15 end_game
  }
  ELSEIF (%col.2 == %slotc.1) && (%col.3 != %slotc.1) {
    .timer.slotc1 1 4 DESCRIBE %mychan  ▌ %col.1 ▌  :::  Good Luck, $1 $+ .  BloodTrail
    .timer.slotc2 1 9 DESCRIBE %mychan  ▌ %col.1 ▌ %col.2 ▌   :::   Well, $1 $+ , best of luck getting another %slotc.1  ...
    .timer.slotc3 1 15 DESCRIBE %mychan  ▌ %col.1 ▌ %col.2 ▌ %col.3 ▌   :::  You Lose, $1 $+ ! :tf:
    .timer.slotstop 1 15 end_game
  }
  ELSEIF (%col.3 == %slotc.1) {
    VAR %payout = %slotbet
    .timer.slotc1 1 4 DESCRIBE %mychan  ▌ %col.1 ▌  :::  Good Luck, $1 $+ .  BloodTrail
    .timer.slotc2 1 9 DESCRIBE %mychan  ▌ %col.1 ▌ %col.2 ▌   :::   Well, $1 $+ , best of luck getting at least a %slotc.1  ...
    .timer.slotc3 1 15 DESCRIBE %mychan  ▌ %col.1 ▌ %col.2 ▌ %col.3 ▌   :::  You WON %payout %curname $+ , $1 $+ !!!  PogChamp
    .timer.slotpayout 1 15 ADDPOINTS $1 %payout
    .timer.slotstop 1 15 end_game
  }
  ELSEIF ((%col.1 != %col.2) && (%col.3 != %slotc.1)) {
    .timer.slotc1 1 4 DESCRIBE %mychan  ▌ %col.1 ▌  :::  Good Luck, $1 $+ .  BloodTrail
    .timer.slotc2 1 9 DESCRIBE %mychan  ▌ %col.1 ▌ %col.2 ▌   :::   Well, $1 $+ , best of luck getting at least a %slotc.1  ...
    .timer.slotc3 1 15 DESCRIBE %mychan  ▌ %col.1 ▌ %col.2 ▌ %col.3 ▌   :::  You Lose, $1 $+ ! :tf:
    .timer.slotstop 1 15 end_game
  }
}
