;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; VARIABLES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

/*
HEY!  LOOK HERE!  This is what you need to change in this script...

Change the %roul_minbet and %roul_maxbet to the minimum and maximum
amount of points that must be spent in order to use !roulette.
The %roul_minbet is the minimum amount of points that a user must spend
on any betting option.  The %roul_maxbet is the maximum amount of points
that a user can spend on the entire roulette table.

The %roul_cd variable is the amount of time (in seconds) before another
roulette game can be played after a game has just finished.  Set this
to 0 for there to be no cooldown.

The %roul_repeat variable is the amount of time (in seconds) that the
bot will repeat the message that the game is open in the channel if no
on has started a game yet.  Set this to 0 to disable this message.

You will need to UNLOAD and RE-LOAD this script for any changes to the
variables below to take effect.  This can be done by pressing ALT-R in
mIRC > Select "View" > Select "roulette.mrc" > Click on "File" > "Unload."
Then, click on "File" and "Load..." and select the roulette.mrc file again.

Have fun!!!
*/

ON *:LOAD: {
  SET %roul_minbet 200
  SET %roul_maxbet 1000
  SET %roul_cd 60
  SET %roul_repeat 1800
  SET %roul_options red black odd even less more doz1 doz2 doz3 row1 row2 row3 line1 line2 line3 line4 line5 line6 line7 line8 line9 line10 line11 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36
}

ON *:UNLOAD: { UNSET %roul_* | .timer.roul.* off }

ON *:CONNECT: {
  IF ($server == tmi.twitch.tv) {
    UNSET %roul.*
    IF ($isfile(roulbets.txt)) REMOVE roulbets.txt
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;; ROULETTE GAME ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON $*:TEXT:/^!(roulette|rbet)\s(on|off)$/iS:%mychan: {

  IF ($nick isop $chan) {
    IF ($2 == on) {
      IF (!%GAMES_ROUL_ACTIVE) {
        SET %GAMES_ROUL_ACTIVE On
        IF (%roul_repeat > 0) .timer.roul.repeat 0 %roul_repeat roulrepeat
        MSG $chan $nick $+ , the Roulette game is now enabled!  Type !rbet for more info!  Have fun!  PogChamp
      }
      ELSE MSG $chan $nick $+ , !rbet is already enabled.  FailFish
    }
    ELSEIF ($2 == off) {
      IF (%GAMES_ROUL_ACTIVE) {
        UNSET %GAMES_ROUL_ACTIVE
        .timer.roul.* off
        MSG $chan $nick $+ , the Roulette game is now disabled.
      }
      ELSE MSG $chan $nick $+ , Roulette is already disabled.  FailFish
    }
  }
}

ON $*:TEXT:/^!(roulette|rbet)(\s|$)/iS:%mychan: {

  IF ($($+(%,roul.CD_,$nick),2)) halt
  ELSEIF (!%GAMES_ROUL_ACTIVE) {
    IF ((%floodROUL_ACTIVE) || ($($+(%,floodROUL_ACTIVE.,$nick),2))) halt
    SET -u15 %floodROUL_ACTIVE On
    SET -u120 %floodROUL_ACTIVE. $+ $nick On
    MSG $chan $nick $+ , the Roulette game is currently disabled.
  }
  ELSEIF ($timer(.roul.reopen)) {
    IF ((%floodROULreopen) || ($($+(%,floodROULreopen.,$nick),2))) halt
    SET -u15 %floodROULreopen On
    SET -u60 %floodROULreopen. $+ $nick On
    MSG $chan Relax, $nick $+ !  I will announce the next Roulette game in $duration($timer(.roul.reopen).secs) $+ !  SwiftRage
  }
  ELSEIF ((%roul.closed) || (%ActiveGame) || ($timer(.roul.reopen2)) || (%rr.p1)) halt
  ELSEIF (($istok(%roul_options,$2,32)) && ($3 isnum %roul_minbet - %roul_maxbet) && (%roul.bet. [ $+ [ $nick ] ] != 0) && (($calc(%roul.bet. [ $+ [ $nick ] ] - $3) >= 0) || (!%roul.bet. [ $+ [ $nick ] ]))) {
    SET -eu5 %roul.CD_ $+ $nick $true
    VAR %wager $floor($3)
    ;IF (!$isSub) { MSG $chan $nick $+ , Roulette is a subscriber only perk of the channel. Thank you for understanding. | halt }
    IF ($GetPoints < %wager) { MSG $chan $nick $+ , you don't have %wager %curname to wager. FailFish | halt }
    REMOVEPOINTS $nick %wager
    IF ($isfile(roulbets.txt)) {
      VAR %x = 1
      WHILE ($read(roulbets.txt, %x) != $null) {
        VAR %rnick $gettok($read(roulbets.txt, %x), 1, 32)
        VAR %bet $gettok($read(roulbets.txt, %x), 2, 32)
        VAR %amount $gettok($read(roulbets.txt, %x), 3, 32)
        IF (($nick == %rnick) && ($2 == %bet)) {
          WRITE -l $+ %x roulbets.txt $nick $2 $calc(%amount + %wager)
          VAR %roul.rebet $true
        }
        IF (%roul.rebet) break
        INC %x
      }
      IF (!%roul.rebet) WRITE roulbets.txt $nick $2 %wager
    }
    ELSE {
      IF ($timer(.roul.repeat)) timer.roul.repeat off
      WRITE roulbets.txt $nick $2 %wager
      .timerRouletteBegin1 1 120 MSG $chan All bets for the Roulette game are now closed!  The ball is dropped into the wheel, and the wheel begins spinning!
      .timerRouletteBegin2 1 120 SET %roul.closed On
      .timerRouletteBegin3 1 132 roulspin
      MSG $chan $nick has started a game of Roulette!  Everyone has two minutes to get in their bets!  Bet any amount of %curname from %roul_minbet to %roul_maxbet $+ ! ▌ Use:  !rbet [option] [amount] ▌  Example:  !rbet red %roul_minbet ▌ For all betting options, see http://i.imgur.com/j7Fwytt.jpg
    }
    IF (!%roul.bet. [ $+ [ $nick ] ]) SET %roul.bet. [ $+ [ $nick ] ] $calc(%roul_maxbet - %wager)
    ELSE SET %roul.bet. [ $+ [ $nick ] ] $calc(%roul.bet. [ $+ [ $nick ] ] - %wager)
    IF (%roul.bet. [ $+ [ $nick ] ] >= %roul_minbet) $wdelay(MSG $nick $nick $+ $chr(44) you have bet %wager %curname on $2 $+ .  You can spend %roul.bet. [ $+ [ $nick ] ] more %curname at this table.  Good luck!  BloodTrail)
    ELSE $wdelay(MSG $nick $nick $+ $chr(44) you have bet %wager %curname on $2 $+ .  You have bet all that you can for this table!  Good luck!  BloodTrail)
  }
  ELSEIF (($istok(%roul_options,$2,32)) && ($3 isnum) && ($3 !isnum %roul_minbet - %roul_maxbet) && (%roul.bet. [ $+ [ $nick ] ] != 0) && (($calc(%roul.bet. [ $+ [ $nick ] ] - %roul_minbet) >= 0) || (!%roul.bet. [ $+ [ $nick ] ]))) {
    IF ($($+(%,floodROULwager.,$nick),2)) halt
    SET -u15 %floodROULwager. $+ $nick On
    $wdelay(MSG $nick $nick $+ $chr(44) please make a valid wager between %roul_minbet and %roul_maxbet %curname $+ .)
  }
  ELSEIF (($3 isnum %roul_minbet - %roul_maxbet) && (%roul.bet. [ $+ [ $nick ] ] != 0) && (($calc(%roul.bet. [ $+ [ $nick ] ] - $3) >= 0) || (!%roul.bet. [ $+ [ $nick ] ]))) {
    IF ($($+(%,floodROULoption.,$nick),2)) halt
    SET -u15 %floodROULoption. $+ $nick On
    $wdelay(MSG $nick $nick $+ $chr(44) please bet on a valid betting option.  See http://i.imgur.com/j7Fwytt.jpg for options.)
  }
  ELSEIF (($istok(%roul_options,$2,32)) && ($3 isnum %roul_minbet - %roul_maxbet) && ($calc(%roul.bet. [ $+ [ $nick ] ] - $3) < 0)) {
    IF ($($+(%,floodROULmaxwager.,$nick),2)) halt
    SET -u15 %floodROULmaxwager. $+ $nick On
    IF (%roul.bet. [ $+ [ $nick ] ] >= %roul_minbet) $wdelay(MSG $nick $nick $+ $chr(44) you can only bet up to %roul.bet. [ $+ [ $nick ] ] more %curname at this table.)
    ELSE $wdelay(MSG $nick $nick $+ $chr(44) the minimum bet is %roul_minbet %curname on any bet at Roulette $+ $chr(44) the max bet for the entire table is %roul_maxbet %curname $+ .  You cannot bet any more at this table.)
  }
  ELSEIF ((%roul.bet. [ $+ [ $nick ] ]) || (%roul.bet. [ $+ [ $nick ] ] == 0)) halt
  ELSE {
    IF ((%floodROULinfo) || ($($+(%,floodROULinfo.,$nick),2))) halt
    SET -u15 %floodROULinfo On
    SET -u60 %floodROULinfo. $+ $nick On
    MSG $chan $nick $+ , you may bet any amount of %curname from %roul_minbet to %roul_maxbet on Roulette! ▌ Use:  !rbet [option] [amount] ▌  Example:  !rbet red %roul_minbet ▌ For all betting options, see http://i.imgur.com/j7Fwytt.jpg
  }
}

alias roulspin {
  VAR %num = $rand(0,36)
  MSG %mychan The ball lands on %num $+ !
  IF (%num == 0) VAR %winnum = 0
  ELSEIF (%num == 1) VAR %winnum 1 red odd row1 doz1 line1 less
  ELSEIF (%num == 2) VAR %winnum 2 black even row2 doz1 line1 less
  ELSEIF (%num == 3) VAR %winnum 3 red odd row3 doz1 line1 less
  ELSEIF (%num == 4) VAR %winnum 4 black even row1 doz1 line1 line2 less
  ELSEIF (%num == 5) VAR %winnum 5 red odd row2 doz1 line1 line2 less
  ELSEIF (%num == 6) VAR %winnum 6 black even row3 doz1 line1 line2 less
  ELSEIF (%num == 7) VAR %winnum 7 red odd row1 doz1 line2 line3 less
  ELSEIF (%num == 8) VAR %winnum 8 black even row2 doz1 line2 line3 less
  ELSEIF (%num == 9) VAR %winnum 9 red odd row3 doz1 line2 line3 less
  ELSEIF (%num == 10) VAR %winnum 10 black even row1 doz1 line3 line4 less
  ELSEIF (%num == 11) VAR %winnum 11 black odd row2 doz1 line3 line4 less
  ELSEIF (%num == 12) VAR %winnum 12 red even row3 doz1 line3 line4 less
  ELSEIF (%num == 13) VAR %winnum 13 black odd row1 doz2 line4 line5 less
  ELSEIF (%num == 14) VAR %winnum 14 red even row2 doz2 line4 line5 less
  ELSEIF (%num == 15) VAR %winnum 15 black odd row3 doz2 line4 line5 less
  ELSEIF (%num == 16) VAR %winnum 16 red even row1 doz2 line5 line6 less
  ELSEIF (%num == 17) VAR %winnum 17 black odd row2 doz2 line5 line6 less
  ELSEIF (%num == 18) VAR %winnum 18 red even row3 doz2 line5 line6 less
  ELSEIF (%num == 19) VAR %winnum 19 red odd row1 doz2 line6 line7 more
  ELSEIF (%num == 20) VAR %winnum 20 black even row2 doz2 line6 line7 more
  ELSEIF (%num == 21) VAR %winnum 21 red odd row3 doz2 line6 line7 more
  ELSEIF (%num == 22) VAR %winnum 22 black even row1 doz2 line7 line8 more
  ELSEIF (%num == 23) VAR %winnum 23 red odd row2 doz2 line7 line8 more
  ELSEIF (%num == 24) VAR %winnum 24 black even row3 doz2 line7 line8 more
  ELSEIF (%num == 25) VAR %winnum 25 red odd row1 doz3 line8 line9 more
  ELSEIF (%num == 26) VAR %winnum 26 black even row2 doz3 line8 line9 more
  ELSEIF (%num == 27) VAR %winnum 27 red odd row3 doz3 line8 line9 more
  ELSEIF (%num == 28) VAR %winnum 28 black even row1 doz3 line9 line10 more
  ELSEIF (%num == 29) VAR %winnum 29 black odd row2 doz3 line9 line10 more
  ELSEIF (%num == 30) VAR %winnum 30 red even row3 doz3 line9 line10 more
  ELSEIF (%num == 31) VAR %winnum 31 black odd row1 doz3 line10 line11 more
  ELSEIF (%num == 32) VAR %winnum 32 red even row2 doz3 line10 line11 more
  ELSEIF (%num == 33) VAR %winnum 33 black odd row3 doz3 line10 line11 more
  ELSEIF (%num == 34) VAR %winnum 34 red even row1 doz3 line11 more
  ELSEIF (%num == 35) VAR %winnum 35 black odd row2 doz3 line11 more
  ELSEIF (%num == 36) VAR %winnum 36 red even row3 doz3 line11 more
  VAR %x = 1
  WHILE ($read(roulbets.txt, %x) != $null) {
    VAR %nick $gettok($read(roulbets.txt, %x), 1, 32)
    VAR %bet $gettok($read(roulbets.txt, %x), 2, 32)
    VAR %amount $gettok($read(roulbets.txt, %x), 3, 32)
    IF ($istok(%winnum,%bet,32)) {
      IF ((%bet == red) || (%bet == black) || (%bet == odd) || (%bet == even) || (%bet == more) || (%bet == less)) VAR %winnings = %amount * 2
      ELSEIF (($left(%bet,3) == row) || ($left(%bet,3) == doz)) VAR %winnings = %amount * 3
      ELSEIF ($left(%bet,4) == line) VAR %winnings = %amount * 6
      ELSE VAR %winnings = %amount * 35
      VAR %winnersList %winnersList %nick $chr(40) $+ %winnings on %bet $+ $chr(41) -
      ADDPOINTS %nick %winnings
    }
    INC %x
  }
  IF (%winnersList) .timer.endroul 1 3 MSG %mychan CONGRATULATIONS TO THE WINNERS OF THE ROULETTE GAME: $left(%winnersList, -1) BloodTrail
  ELSE .timer.endroul 1 3 MSG %mychan Nobody won at Roulette!  Better luck next time!  :tf:
  .timer.roul.unset2 1 3 UNSET %roul.*
  .timer.roul.unset3 1 3 REMOVE roulbets.txt
  IF (%roul_cd > 0) .timer.roul.reopen 1 $calc(%roul_cd + 3) roulreopen
  IF (%roul_repeat > 0) .timer.roul.repeat 0 $calc(%roul_repeat + 3) roulrepeat
}

alias roulreopen {
  IF (!%ActiveGame) MSG %mychan The Roulette game is open again!  You may bet any amount of %curname from %roul_minbet to %roul_maxbet on Roulette! ▌ Use:  !rbet [option] [amount] ▌  Example:  !rbet red %roul_minbet ▌ For all betting options, see http://i.imgur.com/j7Fwytt.jpg
  ELSE .timer.roul.reopen2 1 1 roulreopen
}

alias roulrepeat {
  IF (!%ActiveGame) MSG %mychan The Roulette game is open!  Place your bets!  You may bet any amount of %curname from %roul_minbet to %roul_maxbet on Roulette! ▌ Use:  !rbet [option] [amount] ▌  Example:  !rbet red %roul_minbet ▌ For all betting options, see http://i.imgur.com/j7Fwytt.jpg
  ELSE .timer.roul.repeat 1 1 roulrepeat
}
