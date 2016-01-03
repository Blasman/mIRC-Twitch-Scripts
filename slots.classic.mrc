;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; VARIABLES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

/*
HEY!  LOOK HERE!  This is what you need to change in this script...

Change the %slotc.minbet and %slotc.maxbet to the minimum and maximum 
amount of points that must be spent in order to use the !slot.  The 
%slotc.cd variable is the per user cooldown time (in seconds) that a user 
must wait before being able to use !slot again.

You can just leave the %slotc.emote variables or you can change them to
the emotes that you want to use for the slot machine.  The %slotc.emote.1
emote is the emote that will appear 50% of the time, and the other five
appear more rarely the higher that the number is.
See http://i.imgur.com/ch5vQZ2.png

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
  SET %slotc.emote.1 bleedPurple
  SET %slotc.emote.2 duDudu
  SET %slotc.emote.3 riPepperonis
  SET %slotc.emote.4 ShibeZ
  SET %slotc.emote.5 OSrob
  SET %slotc.emote.6 deIlluminati
}

ON *:UNLOAD: { UNSET %slotc.* }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SLOT MACHINE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON $*:TEXT:/^!slot(s)?\s(on|off)/Si:#: {

  IF ($nick isop $chan) {
    IF ($2 == on) {
      IF (!%GAMES_SLOT_ACTIVE) {
        SET %GAMES_SLOT_ACTIVE On
        MSG $chan $twitch_name($nick) $+ , !slot is now enabled!  Have fun!  PogChamp
      }
      ELSE MSG $chan $twitch_name($nick) $+ , !slot is already enabled.  FailFish
    }
    ELSEIF ($2 == off) {
      IF (%GAMES_SLOT_ACTIVE) {
        UNSET %GAMES_SLOT_ACTIVE
        MSG $chan $twitch_name($nick) $+ , !slot is now disabled.
      }
      ELSE MSG $chan $twitch_name($nick) $+ , !slot is already disabled.  FailFish
    }
  }
}

ON $*:TEXT:/^!slot(s)?/Si:#: {

  IF (!$2) || ($2 == help) {
    IF ($($+(%,floodSLOTSPAM1.,$nick),2)) halt
    SET -u6 %floodSLOTSPAM1. $+ $nick On
    MSG $chan You may bet any amount of %curname from %slotc.minbet to %slotc.maxbet on !slot.  ▌  Example:  !slot %slotc.minbet  ▌  See this link to see the payouts for each combination of symbols.  http://i.imgur.com/ch5vQZ2.png
  }
  ELSEIF (!%GAMES_SLOT_ACTIVE) {
    IF ((%floodSLOT_ACTIVE) || ($($+(%,floodSLOT_ACTIVE.,$nick),2))) halt
    SET -u15 %floodSLOT_ACTIVE On
    SET -u120 %floodSLOT_ACTIVE. $+ $nick On
    MSG $chan $twitch_name($nick) $+ , the !slot game is currently disabled.
  }
  ELSEIF ($timer(.SLOT. $+ $nick)) {
    IF ($($+(%,floodSLOTCD.,$nick),2)) halt
    SET -u180 %floodSLOTCD. $+ $nick On
    MSG $nick Be patient, $twitch_name($nick) $+ !  You still have $duration($timer(.SLOT. $+ $nick).secs) left in your !slot cooldown.
  }
  ELSEIF ($2 isnum) {
    IF (%SlotGameRunning) halt
    ELSEIF ($2 !isnum %slotc.minbet - %slotc.maxbet) {
      IF ($($+(%,floodSLOTSPAM1.,$nick),2)) halt
      SET -u6 %floodSLOTSPAM1. $+ $nick On
      MSG $chan $twitch_name($nick) $+ , please enter a valid wager between %slotc.minbet and %slotc.maxbet %curname $+ .  ▌  Example:  !slot %slotc.minbet  ▌  See this link to see the payouts for each combination of symbols.  http://i.imgur.com/ch5vQZ2.png
    }
    ELSE {
      VAR %slotbet = $floor($2)
      IF ($checkpoints($nick, %slotbet) == false) {
        IF ($($+(%,floodSLOTSPAM2.,$nick),2)) halt
        SET -u6 %floodSLOTSPAM2. $+ $nick On
        MSG $chan $twitch_name($nick) $+ , you do not have %slotbet %curname to play slots.  FailFish
        halt
      }
      ELSE removepoints $nick %slotbet
      VAR %nick $twitch_name($nick)
      SET %SlotGameRunning On
      .timer.SLOT. $+ $nick 1 %slotc.cd MSG $nick %nick $+ , your !slot cooldown has expired.  Feel free to play again.  BloodTrail
      MSG $chan %nick pulls the slot machine lever...
      VAR %x = 1
      WHILE (%x <= 3) {
        VAR %random $rand(1,100)

        IF (%random isnum 1-50) VAR %slot. $+ %x %slotc.emote.1
        ELSEIF (%random isnum 51-65) VAR %slot. $+ %x %slotc.emote.2
        ELSEIF (%random isnum 66-79) VAR %slot. $+ %x %slotc.emote.3
        ELSEIF (%random isnum 80-88) VAR %slot. $+ %x %slotc.emote.4
        ELSEIF (%random isnum 89-95) VAR %slot. $+ %x %slotc.emote.5
        ELSEIF (%random isnum 96-100) VAR %slot. $+ %x %slotc.emote.6
        INC %x
      }

      IF ((%slot.1 == %slot.2) && (%slot.2 == %slot.3)) {
        IF (%slot.1 == %slotc.emote.1) VAR %payout = %slotbet * 5
        ELSEIF (%slot.1 == %slotc.emote.2) VAR %payout = %slotbet * 10
        ELSEIF (%slot.1 == %slotc.emote.3) VAR %payout = %slotbet * 15
        ELSEIF (%slot.1 == %slotc.emote.4) VAR %payout = %slotbet * 25
        ELSEIF (%slot.1 == %slotc.emote.5) VAR %payout = %slotbet * 50
        ELSEIF (%slot.1 == %slotc.emote.6) VAR %payout = %slotbet * 100
        .timer.slotc1 1 4 DESCRIBE $chan  ▌ %slot.1 ▌  :::  Good Luck, %nick $+ .  BloodTrail
        .timer.slotc2 1 9 DESCRIBE $chan  ▌ %slot.1 ▌ %slot.2 ▌   :::   OMG, %nick $+ , you might win this!  FeelsGoodMan
        .timer.slotc3 1 18 DESCRIBE $chan  ▌ %slot.1 ▌ %slot.2 ▌ %slot.3 ▌   :::  You WON %payout %curname $+ , %nick $+ !!!  PogChamp
        .timer.slotpayout 1 18 ADDPOINTS $nick %payout | .timer.slotstop 1 18 UNSET %SlotGameRunning
      }

      ELSEIF ((%slot.1 == %slot.2) && (%slot.2 != %slot.3) && (%slot.3 == %slotc.emote.1)) {
        VAR %payout = %slotbet
        .timer.slotc1 1 4 DESCRIBE $chan  ▌ %slot.1 ▌  :::  Good Luck, %nick $+ .  BloodTrail
        .timer.slotc2 1 9 DESCRIBE $chan  ▌ %slot.1 ▌ %slot.2 ▌   :::   OMG, %nick $+ , you might win this!  FeelsGoodMan
        .timer.slotc3 1 18 DESCRIBE $chan  ▌ %slot.1 ▌ %slot.2 ▌ %slot.3 ▌   :::  Well, %nick $+ , at least you won %payout %curname $+ !  MingLee
        .timer.slotpayout 1 18 ADDPOINTS $nick %payout | .timer.slotstop 1 18 UNSET %SlotGameRunning
      }

      ELSEIF ((%slot.1 == %slot.2) && (%slot.2 != %slot.3) && (%slot.3 != %slotc.emote.1)) {
        .timer.slotc1 1 4 DESCRIBE $chan  ▌ %slot.1 ▌  :::  Good Luck, %nick $+ .  BloodTrail
        .timer.slotc2 1 9 DESCRIBE $chan  ▌ %slot.1 ▌ %slot.2 ▌   :::   OMG, %nick $+ , you might win this!  FeelsGoodMan
        .timer.slotc3 1 18 DESCRIBE $chan  ▌ %slot.1 ▌ %slot.2 ▌ %slot.3 ▌   :::  You Lose, %nick $+ !  :tf:
        .timer.slotstop 1 18 UNSET %SlotGameRunning
      }

      ELSEIF ((%slot.2 == %slotc.emote.1) && (%slot.3 == %slotc.emote.1)) {
        VAR %payout = %slotbet * 2
        .timer.slotc1 1 4 DESCRIBE $chan  ▌ %slot.1 ▌  :::  Good Luck, %nick $+ .  BloodTrail
        .timer.slotc2 1 9 DESCRIBE $chan  ▌ %slot.1 ▌ %slot.2 ▌   :::   Well, %nick $+ , best of luck getting another %slotc.emote.1  ...
        .timer.slotc3 1 15 DESCRIBE $chan  ▌ %slot.1 ▌ %slot.2 ▌ %slot.3 ▌   :::  You WON %payout %curname $+ , %nick $+ !!!  PogChamp
        .timer.slotpayout 1 15 ADDPOINTS $nick %payout | .timer.slotstop 1 15 UNSET %SlotGameRunning
      }

      ELSEIF (%slot.2 == %slotc.emote.1) && (%slot.3 != %slotc.emote.1) {
        .timer.slotc1 1 4 DESCRIBE $chan  ▌ %slot.1 ▌  :::  Good Luck, %nick $+ .  BloodTrail
        .timer.slotc2 1 9 DESCRIBE $chan  ▌ %slot.1 ▌ %slot.2 ▌   :::   Well, %nick $+ , best of luck getting another %slotc.emote.1  ...
        .timer.slotc3 1 15 DESCRIBE $chan  ▌ %slot.1 ▌ %slot.2 ▌ %slot.3 ▌   :::  You Lose, %nick $+ ! :tf:
        .timer.slotstop 1 15 UNSET %SlotGameRunning
      }

      ELSEIF (%slot.3 == %slotc.emote.1) {
        VAR %payout = %slotbet
        .timer.slotc1 1 4 DESCRIBE $chan  ▌ %slot.1 ▌  :::  Good Luck, %nick $+ .  BloodTrail
        .timer.slotc2 1 9 DESCRIBE $chan  ▌ %slot.1 ▌ %slot.2 ▌   :::   Well, %nick $+ , best of luck getting at least a %slotc.emote.1  ...
        .timer.slotc3 1 15 DESCRIBE $chan  ▌ %slot.1 ▌ %slot.2 ▌ %slot.3 ▌   :::  You WON %payout %curname $+ , %nick $+ !!!  PogChamp
        .timer.slotpayout 1 15 ADDPOINTS $nick %payout | .timer.slotstop 1 15 UNSET %SlotGameRunning
      }

      ELSEIF ((%slot.1 != %slot.2) && (%slot.3 != %slotc.emote.1)) {
        .timer.slotc1 1 4 DESCRIBE $chan  ▌ %slot.1 ▌  :::  Good Luck, %nick $+ .  BloodTrail
        .timer.slotc2 1 9 DESCRIBE $chan  ▌ %slot.1 ▌ %slot.2 ▌   :::   Well, %nick $+ , best of luck getting at least a %slotc.emote.1  ...
        .timer.slotc3 1 15 DESCRIBE $chan  ▌ %slot.1 ▌ %slot.2 ▌ %slot.3 ▌   :::  You Lose, %nick $+ ! :tf:
        .timer.slotstop 1 15 UNSET %SlotGameRunning
      }
    }
  }
}
