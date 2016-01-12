;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; VARIABLES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

/*
HEY!  LOOK HERE!  This is what you need to change in this script...

Change the %jackc.bet variable to the amount of channel currency that it
costs to use !jackpot.

The %jackc.cd variable is the per user cooldown time (in seconds) that
a user must wait before being able to use !jackpot again.

The %jackc.newpot variable is the amount of channel currency that the
jackpot will reset itself to after someone wins the jackpot.

You can just leave the %jackc.# variables or you can change them to
the emotes that you want to use for the jackpot slot machine.

You will need to UNLOAD and RE-LOAD this script for any changes to the
variables below to take effect.  This can be done by pressing ALT-R in
mIRC > Select "View" > Select "jackpot.classic.mrc" > Click on "File" >
"Unload." Then, click on "File" and "Load..." and select the
jackpot.classic.mrc file again.

If you want to edit what the bot replies for the !jackpot win and
losses, you can likely figure that out by looking closely at the script.

The odds of winning a !jackpot are 1 in 81.

Have fun!!!
*/

ON *:LOAD: {
  SET %jackc.bet 25
  SET %jackc.cd 600
  SET %jackc.newpot 2000
  SET %jackc.1 bleedPurple
  SET %jackc.2 PraiseIt
  SET %jackc.3 deIlluminati
  SET %jackc.4 duDudu
  SET %jackc.5 KAPOW
  SET %jackc.6 OSrob
  SET %jackc.7 riPepperonis
  SET %jackc.8 shazamicon
  SET %jackc.9 ShibeZ
  IF (!%jackc_pot) SET %jackc_pot %jackc.newpot
}

ON *:UNLOAD: { UNSET %jackc.* }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;; JACKPOT CLASSIC ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON $*:TEXT:/^!jackpot\s(on|off|set|reset)/iS:#: {

  IF ($nick isop $chan) {
    IF ($2 == on) {
      IF (!%GAMES_JACKPOTC_ACTIVE) {
        SET %GAMES_JACKPOTC_ACTIVE On
        MSG $chan $twitch_name($nick) $+ , !jackpot is now enabled!  Have fun!  PogChamp
      }
      ELSE MSG $chan $twitch_name($nick) $+ , !jackpot is already enabled.  FailFish
    }
    ELSEIF ($2 == off) {
      IF (%GAMES_JACKPOTC_ACTIVE) {
        UNSET %GAMES_JACKPOTC_ACTIVE
        MSG $chan $twitch_name($nick) $+ , !jackpot is now disabled.
      }
      ELSE MSG $chan $twitch_name($nick) $+ , !jackpot is already disabled.  FailFish
    }
    ELSEIF ($2 == set) && ($3 isnum) {
      SET %jackc_pot $floor($3)
      MSG $chan The !jackpot has been manually set to %jackc_pot %curname $+ !
    }
    ELSEIF ($2 == reset) && (!$3) {
      UNSET %jackc_*
      MSG $chan All !jackpot stats have been deleted by $twitch_name($nick) $+ !
    }
  }
}

ON $*:TEXT:/^!jackpot(\s)?stats$/iS:#: {

  IF (%floodJACKC_STATS) halt
  SET -u10 %floodJACKC_STATS On
  IF (!%jackc_last.winner) MSG $chan Current !jackpot:  %jackc_pot %curname $+ .  Nobody has won a !jackpot yet!
  ELSE MSG $chan Current !jackpot:  %jackc_pot %curname $+ .  ▌  Last Winner was %jackc_last.winner who won %jackc_last.winnings %curname $+ .  ▌  Number of Winners: %jackc_winners  ▌  Total Payouts: %jackc_winnings %curname $+ .
}

ON $*:TEXT:/^!jackpot$/iS:#: {

  IF (!%GAMES_JACKPOTC_ACTIVE) {
    IF ((%floodJACKC_ACTIVE) || ($($+(%,floodJACKC_ACTIVE.,$nick),2))) halt
    SET -u15 %floodJACKC_ACTIVE On
    SET -u120 %floodJACKC_ACTIVE. $+ $nick On
    MSG $chan $twitch_name($nick) $+ , the !jackpot game is currently disabled.
  }
  ELSEIF ($timer(.JACKC. $+ $nick)) {
    IF ($($+(%,floodJACKPOT2.,$nick),2)) halt
    SET -u180 %floodJACKPOT2. $+ $nick On
    MSG $nick Be patient, $twitch_name($nick) $+ !  You still have $duration($timer(.JACKC. $+ $nick).secs) left in your !jackpot cooldown.
  }
  ELSEIF ((%ActiveGame) || ($isfile(roulbets.txt)) || ($rr.p1)) halt
  ELSEIF ($checkpoints($nick, %jackc.bet) == false) MSG $chan $twitch_name($nick) $+ , you do not have %jackc.bet %curname to play !jackpot  FailFish
  ELSE {
    VAR %nick $twitch_name($nick)
    .timer.JACKC. $+ %nick 1 %jackc.cd MSG $nick %nick $+ , your !jackpot cooldown has expired.  Feel free to play again.  BloodTrail
    SET %ActiveGame On
    REMOVEPOINTS $nick %jackc.bet
    INC %jackc_pot %jackc.bet
    MSG $nick %nick $+ , you just spent %jackc.bet %curname on !jackpot.
    MSG $chan %nick pulls the jackpot machine's lever... PogChamp [Current Jackpot: %jackc_pot %curname $+ ]
    VAR %col.1 %jackc. [ $+ [ $rand(1,9) ] ]
    VAR %col.2 %jackc. [ $+ [ $rand(1,9) ] ]
    VAR %col.3 %jackc. [ $+ [ $rand(1,9) ] ]

    ;;;;;; IF THE USER IS A WINNER, RUN THIS ;;;;;;

    IF (%col.1 == %col.2) && (%col.2 == %col.3) {
      SET %jackcwinner %nick
      .timer.jackc1 1 4 DESCRIBE $chan ▌ %col.0 ▌  :::  Good Luck, %nick $+ .  BloodTrail
      .timer.jackc2 1 10 DESCRIBE $chan ▌ %col.0 ▌ %col.1 ▌   :::   OMG, %nick $+ , you might win this!  FeelsGoodMan
      .timer.jackc3 1 23 DESCRIBE $chan ▌ %col.0 ▌ %col.1 ▌ %col.2 ▌   :::  You WON $+ , %nick $+ !!!  PogChamp
      .timer.jackcwinner1 1 24 MSG $chan KAPOW KAPOW KAPOW OMG!!!  JACKPOT!!! %nick just won $readini(jackc.ini,@Stats,Jackpot) %curname $+ !!!  KAPOW KAPOW KAPOW
      .timer.jackcwinner2 1 25 MSG $chan KAPOW KAPOW KAPOW OMG!!!  JACKPOT!!! %nick just won $readini(jackc.ini,@Stats,Jackpot) %curname $+ !!!  KAPOW KAPOW KAPOW
      .timer.jackcwinner3 1 26 MSG $chan KAPOW KAPOW KAPOW OMG!!!  JACKPOT!!! %nick just won $readini(jackc.ini,@Stats,Jackpot) %curname $+ !!!  KAPOW KAPOW KAPOW
      .timer.jackcwinner4 1 26 jackcwinner
    }

    ;;;;;; IF ANY TWO REELS ARE THE SAME, FORCE THEM APPEAR IN THE FIRST TWO REELS ;;;;;;

    ELSEIF (%col.1 == %col.2) || (%col.2 == %col.3) || (%col.1 == %col.3) {
      IF (%col.1 == %col.2) {
        .timer.jackc1 1 4 DESCRIBE $chan ▌ %col.1 ▌  :::  Good Luck, %nick $+ .  BloodTrail
        .timer.jackc2 1 10 DESCRIBE $chan ▌ %col.1 ▌ %col.2 ▌   :::   OMG, %nick $+ , you might win this!  FeelsGoodMan
        .timer.jackc3 1 22 DESCRIBE $chan ▌ %col.1 ▌ %col.2 ▌ %col.3 ▌   :::  You Still Lose $+ , %nick :tf:
        .timer.unset.ActiveGame 1 22 unset %ActiveGame
      }
      ELSEIF (%col.2 == %col.3) {
        .timer.jackc1 1 4 DESCRIBE $chan ▌ %col.2 ▌  :::  Good Luck, %nick $+ .  BloodTrail
        .timer.jackc2 1 10 DESCRIBE $chan ▌ %col.2 ▌ %col.3 ▌   :::   OMG, %nick $+ , you might win this!  FeelsGoodMan
        .timer.jackc3 1 22 DESCRIBE $chan ▌ %col.2 ▌ %col.3 ▌ %col.1 ▌   :::  You Still Lose $+ , %nick :tf:
        .timer.unset.ActiveGame 1 22 unset %ActiveGame
      }
      ELSEIF (%col.1 == %col.3) {
        .timer.jackc1 1 4 DESCRIBE $chan ▌ %col.1 ▌  :::  Good Luck, %nick $+ .  BloodTrail
        .timer.jackc2 1 10 DESCRIBE $chan ▌ %col.1 ▌ %col.3 ▌   :::   OMG, %nick $+ , you might win this!  FeelsGoodMan
        .timer.jackc3 1 22 DESCRIBE $chan ▌ %col.1 ▌ %col.3 ▌ %col.2 ▌   :::  You Still Lose $+ , %nick :tf:
        .timer.unset.ActiveGame 1 22 unset %ActiveGame
      }
    }

    ;;;;;; IF NO REELS ARE THE SAME, RUN THIS ;;;;;;

    ELSEIF (%col.1 != %col.2) && (%col.2 != %col.3) && (%col.1 != %col.3) {
      .timer.jackc1 1 4 DESCRIBE $chan ▌ %col.1 ▌  :::  Good Luck, %nick $+ .  BloodTrail
      .timer.jackc2 1 8 DESCRIBE $chan ▌ %col.1 ▌ %col.2 ▌   :::  Awwwe, too bad... FeelsBadMan
      .timer.jackc3 1 12 DESCRIBE $chan ▌ %col.1 ▌ %col.2 ▌ %col.3 ▌   :::  You Lose $+ , %nick :tf:
      .timer.unset.ActiveGame 1 12 unset %ActiveGame
    }
  }
}

alias jackcwinner {
  INC %jackc_winners
  INC %jackc_winnings %jackc_pot
  SET %jackc_last.winner %jackcwinner
  SET %jackc_last.winnings %jackc_pot
  ADDPOINTS %jackcwinner %jackc_pot
  SET %jackc_pot %jackc.newpot
  UNSET %ActiveGame
  UNSET %jackcwinner
}
