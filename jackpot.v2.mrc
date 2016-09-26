;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;; TWITCH.TV/BLASMAN13 ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;; JACKPOT VERSION 2.000 ;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON *:LOAD: jackpot_setup

ON *:UNLOAD: UNSET %jackpot.*

alias jackpot_setup {
  jp_odds
  jp_emotes
  jp_cost
  jp_cooldown
  jp_newpot
}

menu menubar,channel,status {
  !JackPot
  .!JackPot is $IIF(%GAMES_JACKPOT_ACTIVE,ENABLED,DISABLED) [click to $IIF(%GAMES_JACKPOT_ACTIVE,disable,enable) $+ ]:jp_switch
  .EMOTES
  ..CLICK HERE TO CONFIGURE:jp_emotes
  ..$submenu($_jackpot_emote_menu($1))
  .COST $chr(91) $+ %jackpot.bet %curname $+ $chr(93):jp_cost
  .COOLDOWN $chr(91) $+ %jackpot.cd seconds $+ $chr(93):jp_cooldown
  .FRESH POT $chr(91) $+ %jackpot.newpot %curname $+ $chr(93):jp_newpot
  .ODDS OF WINNING $chr(91) $+ %jackpot.odds $+ $chr(37) $+ $chr(93):jp_odds
  .CURRENT POT $chr(91) $+ %jackpot_pot %curname $+ $chr(93):jp_currentpot
}

alias -l _jackpot_emote_menu {
  IF ($1 == begin) { RETURN - }
  IF ($1 == end) { RETURN - }
  IF ($gettok(%jackpot.emotes,$1,32)) { RETURN $style(2) $ifmatch : $ifmatch }
}

alias -l jp_switch {
  IF (!%GAMES_JACKPOT_ACTIVE) {
    SET %GAMES_JACKPOT_ACTIVE On
    MSG %mychan !jackpot is now enabled!  Have fun!  PogChamp
  }
  ELSE {
    UNSET %GAMES_JACKPOT_ACTIVE
    MSG %mychan !jackpot is now disabled.
  }
}

alias -l jp_cost {
  :cost
  $input(How much %curname will it cost to play !jackpot?,eo,Required Input,%jackpot.bet)
  IF ((!$!) || ($! !isnum)) { ECHO You need to input a numerical value for the cost to play !jackpot! | GOTO cost }
  ELSE SET %jackpot.bet $floor($!)
}

alias -l jp_cooldown {
  :cooldown
  $input(What will be the cooldown in seconds per user for !jackpot?,eo,Required Input,%jackpot.cd)
  IF ((!$!) || ($! !isnum)) { ECHO You need to input a numerical value for the per-user cooldown on !jackpot! | GOTO cooldown }
  ELSE SET %jackpot.cd $floor($!)
}

alias -l jp_emotes {
  :emotes
  $input(Input at LEAST two emotes that you would like to use for !jackpot separated by spaces:,eo,Required Input,%jackpot.emotes)
  IF (!$!) { ECHO You need to input at least two emotes for !jackpot! | GOTO emotes }
  ELSE {
    VAR %emotes $!
    IF ($numtok(%emotes,32) < 2) GOTO emotes
    SET %jackpot.emotes %emotes
  }
}

alias -l jp_newpot {
  :startamount
  $input(What will be the staring amount of %curname for !jackpot?,eo,Required Input,%jackpot.newpot)
  IF ((!$!) || ($! !isnum)) { ECHO You need to input a numerical value for the starting amount on !jackpot! | GOTO startamount }
  ELSE {
    SET %jackpot.newpot $floor($!)
    IF (!%jackpot_pot) SET %jackpot_pot $floor($!)
  }
}

alias -l jp_odds {
  :odds
  $input(What will be the percentage odds of winning !jackpot? $chr(40) $+ up to three decimal places $+ $chr(41),eo,Required Input,%jackpot.odds)
  IF ((!$!) || ($remove($!,$chr(37)) !isnum)) { ECHO You need to input a numerical value for the odds of winning on !jackpot! | GOTO odds }
  ELSE SET %jackpot.odds $round($!,3)
}

alias -l jp_currentpot {
  :currentpot
  $input(Enter the CURRENT $chr(40) $+ NOT the starting $+ $chr(41) pot for !jackpot,eo,Required Input,%jackpot_pot)
  IF ((!$!) || ($! !isnum)) { ECHO You need to input a numerical value for the current pot on !jackpot! | GOTO currentpot }
  ELSE SET %jackpot_pot $floor($!)
}

ON $*:TEXT:/^!jackpot\s(on|off|set|bet|cd|newpot|reset|odds|emotes|setup)/iS:%mychan: {
  IF ($nick isop $chan) {
    IF ($2 == on) {
      IF (!%GAMES_JACKPOT_ACTIVE) {
        SET %GAMES_JACKPOT_ACTIVE On
        MSG $chan $nick $+ , !jackpot is now enabled!  Have fun!  PogChamp
      }
      ELSE MSG $chan $nick $+ , !jackpot is already enabled.  FailFish
    }
    ELSEIF ($2 == off) {
      IF (%GAMES_JACKPOT_ACTIVE) {
        UNSET %GAMES_JACKPOT_ACTIVE
        MSG $chan $nick $+ , !jackpot is now disabled.
      }
      ELSE MSG $chan $nick $+ , !jackpot is already disabled.  FailFish
    }
    ELSEIF ($2 == set) && ($3 isnum) {
      SET %jackpot_pot $floor($3)
      MSG $chan The !jackpot has been manually set to %jackpot_pot %curname $+ !
    }
    ELSEIF ($2 == bet) && ($3 isnum) {
      SET %jackpot.bet $floor($3)
      MSG $chan The amount of %curname to play !jackpot has been changed to %jackpot.bet $+ !
    }
    ELSEIF ($2 == cd) && ($3 isnum) {
      SET %jackpot.cd $floor($3)
      MSG $chan The cooldown time for !jackpot has been changed to %jackpot.cd seconds!
    }
    ELSEIF ($2 == newpot) && ($3 isnum) {
      SET %jackpot.newpot $floor($3)
      MSG $chan The starting !jackpot amount has been set to %jackpot.newpot $+ !
    }
    ELSEIF ($2 == reset) && (!$3) {
      UNSET %jackpot_*
      MSG $chan All !jackpot stats have been deleted by $nick $+ !
    }
    ELSEIF (($2 == odds) && ($3 isnum)) {
      SET %jackpot.odds $round($3,3)
      MSG $chan The odds of winning !jackpot have been set to %jackpot.odds $+ $chr(37) $+ .
    }
    ELSEIF ($2 == emotes) {
      IF ($4) {
        SET %jackpot.emotes $3-
        MSG $chan The $numtok(%jackpot.emotes,32) !jackpot emotes have been set to %jackpot.emotes
      }
      ELSE MSG $chan $nick $+ , you need to specify at least two emotes for the !jackpot.
    }
  }
  ELSEIF (($nick == %streamer) && ($2 == setup)) jackpot_setup
}

ON $*:TEXT:/^!jackpot(\s)?stats$/iS:%mychan: {
  IF (!%floodJACKPOT_STATS) {
    SET -eu10 %floodJACKPOT_STATS On
    IF (!%jackpot_last.winner) MSG $chan Current !jackpot:  %jackpot_pot %curname $+ .  Nobody has won a !jackpot yet!
    ELSE MSG $chan Current !jackpot:  %jackpot_pot %curname $+ .  ▌  Last Winner was %jackpot_last.winner who won %jackpot_last.winnings %curname on %jackpot_last.winner.time $+ .  ▌  Number of Winners: %jackpot_winners  ▌  Total Payouts: $bytes(%jackpot_winnings,b) %curname $+ .
  }
}

ON $*:TEXT:/^!jackpot(\s)?record$/iS:%mychan: {
  IF (!%floodJACKPOT_RECORD) {
    SET -eu10 %floodJACKPOT_RECORD On
    IF (!%jackpot_record_name) MSG $chan Nobody has won a !jackpot yet!
    ELSE MSG $chan The largest !jackpot ever won was for %jackpot_record_amount %curname by %jackpot_record_name on %jackpot_record_date $+ . PogChamp
  }
}

ON $*:TEXT:/^!jackpot$/iS:%mychan: {
  IF (!%GAMES_JACKPOT_ACTIVE) {
    IF ((%floodJACK_ACTIVE) || ($($+(%,floodJACKC_ACTIVE.,$nick),2))) halt
    SET -eu15 %floodJACK_ACTIVE On
    SET -eu120 %floodJACK_ACTIVE. $+ $nick On
    MSG $chan $nick $+ , the !jackpot game is currently disabled.
  }
  ELSEIF ($timer(.JACKPOT. $+ $nick)) {
    IF ($($+(%,floodJACKPOT2.,$nick),2)) halt
    SET -eu180 %floodJACKPOT2. $+ $nick On
    MSG $nick Be patient, $twitch_name($nick) $+ !  You still have $duration($timer(.JACKPOT. $+ $nick).secs) left in your !jackpot cooldown.
  }
  ELSEIF ((%ActiveGame) || ($isfile(roulbets.txt)) || (%rr.p1)) halt
  ELSEIF ($checkpoints($nick, %jackpot.bet) == false) MSG $chan $nick $+ , you do not have %jackpot.bet %curname to play !jackpot  FailFish
  ELSE {
    ; PLAY THE JACKPOT AND GENERATE REELS
    VAR %nick $nick
    .timer.JACKPOT. $+ %nick 1 %jackpot.cd MSG $nick %nick $+ , your !jackpot cooldown has expired.  Feel free to play again.  BloodTrail
    SET %ActiveGame On
    REMOVEPOINTS $nick %jackpot.bet
    INC %jackpot_pot %jackpot.bet
    MSG $nick %nick $+ , you just spent %jackpot.bet %curname on !jackpot.
    MSG $chan %nick pulls the jackpot machine's lever... PogChamp [Current Jackpot: %jackpot_pot %curname $+ ]
    VAR %a = $calc(%jackpot.odds * 1000)
    VAR %b = $rand(1,100000)
    VAR %jackpot.num.emotes = $numtok(%jackpot.emotes,32)
    IF (%b isnum 1 - %a) {
      VAR %x = $rand(1,%jackpot.num.emotes)
      VAR %reel.1 $gettok(%jackpot.emotes,%x,32)
      VAR %reel.2 $gettok(%jackpot.emotes,%x,32)
      VAR %reel.3 $gettok(%jackpot.emotes,%x,32)
      .timer.jackpot_01 1 1 DESCRIBE $chan  ▌ %reel.1 ▌
      .timer.jackpot_02 1 2 DESCRIBE $chan  ▌ %reel.1 ▌ %reel.2 ▌
      .timer.jackpot_03 1 5 DESCRIBE $chan  ▌ %reel.1 ▌ %reel.2 ▌ %reel.3 ▌   :::  You Won %jackpot_pot %curname $+ , $nick $+ ! Congratulations! PogChamp
      .timer.jackpotwinner1 1 6 MSG $chan KAPOW KAPOW KAPOW OMG!!!  JACKPOT!!! $nick just won %jackpot_pot %curname $+ !!!  KAPOW KAPOW KAPOW
      .timer.jackpotwinner2 1 7 MSG $chan KAPOW KAPOW KAPOW OMG!!!  JACKPOT!!! $nick just won %jackpot_pot %curname $+ !!!  KAPOW KAPOW KAPOW
      .timer.jackpotwinner3 1 8 MSG $chan KAPOW KAPOW KAPOW OMG!!!  JACKPOT!!! $nick just won %jackpot_pot %curname $+ !!!  KAPOW KAPOW KAPOW
      .timer.jackpotwinner4 1 8 jackpotwinner $nick
    }
    ELSE {
      VAR %x = 1
      WHILE (%x <= 3) {
        ; FIRST REEL, OR THIRD REEL IF FIRST TWO REELS ARE NOT IDENTICAL
        IF ((%x == 1) || ((%x == 3) && (%reel.1 != %reel.2))) {
          IF (%x == 3) %reelspeed = 3
          VAR %first.reel.num $rand(1,$numtok(%jackpot.emotes,32))
          VAR %reel. [ $+ [ %x ] ] $gettok(%jackpot.emotes,%first.reel.num,32)
          INC %x
        }
        ; SECOND REEL, INCREASE ODDS OF REPEATING THE FIRST REEL
        ELSEIF (%x == 2) {
          VAR %new.num.emotes = $round($calc(%jackpot.num.emotes * 1.44),0)
          VAR %d = $rand(1,%new.num.emotes)
          IF (%d isnum 1 - $round($calc(%jackpot.num.emotes * 1.44 - %jackpot.num.emotes + 1),0)) VAR %reel.2 %reel.1
          ELSE {
            :secondreel
            VAR %e = $calc(%new.num.emotes - %jackpot.num.emotes + 1)
            VAR %f = 1
            WHILE (%e <= %new.num.emotes) {
              IF (%e == %d) {
                IF (%f == %first.reel.num) {
                  VAR %d = $rand($calc(%new.num.emotes - %jackpot.num.emotes + 1),%new.num.emotes)
                  GOTO secondreel
                }
                ELSE {
                  VAR %reel.2 $gettok(%jackpot.emotes,%f,32)
                  BREAK
                }
              }
              INC %e
              INC %f
            }
          }
          INC %x
        }
        ; THIRD LOSING REEL IF FIRST TWO REELS ARE THE SAME
        ELSE {
          VAR %reelspeed = 4
          :finalreel
          VAR %h = $rand(1,%jackpot.num.emotes)
          VAR %i = 1
          WHILE (%i <= %jackpot.num.emotes) {
            IF (%h == %i) {
              IF (%i == %first.reel.num) GOTO finalreel
              ELSE {
                VAR %reel.3 $gettok(%jackpot.emotes,%i,32)
                BREAK
              }
            }
            INC %i
          }
          INC %x
        }
      }
      .timer.jackpot_01 1 1 DESCRIBE $chan  ▌ %reel.1 ▌
      .timer.jackpot_02 1 2 DESCRIBE $chan  ▌ %reel.1 ▌ %reel.2 ▌
      .timer.jackpot_03 1 %reelspeed DESCRIBE $chan  ▌ %reel.1 ▌ %reel.2 ▌ %reel.3 ▌   :::  You Lose, $nick $+ ! Better luck next time! BibleThump
      .timer.jackpot_04 1 %reelspeed UNSET %ActiveGame
    }
  }
}

alias jackpotwinner {
  IF ((%jackpot_pot > %jackpot_winnings_record) || (!%jackpot_winnings_record)) {
    SET %jackpot_record_name $1
    SET %jackpot_record_amount %jackpot_pot
    SET %jackpot_record_date $asctime(mmm d h:nn TT) EST
  }
  INC %jackpot_winners
  INC %jackpot_winnings %jackpot_pot
  SET %jackpot_last.winner $1
  SET %jackpot_last.winner.time $asctime(mmm d h:nn TT) EST
  SET %jackpot_last.winnings %jackpot_pot
  ADDPOINTS $1 %jackpot_pot
  SET %jackpot_pot %jackpot.newpot
  UNSET %ActiveGame
}
