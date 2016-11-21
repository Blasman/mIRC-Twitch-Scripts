;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;; TWITCH.TV/BLASMAN13 ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;; JACKPOT VERSION 2.101 ;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON *:LOAD: jackpot_setup

ON *:UNLOAD: UNSET %jackpot.*

alias jackpot_setup {
  jp_odds
  jp_emotes
  jp_cost
  jp_cooldown
  jp_newpot
  IF (!%jackpot.reel_1_speed) SET %jackpot.reel_1_speed 1
  IF (!%jackpot.reel_2_speed) SET %jackpot.reel_2_speed 3
  IF (!%jackpot.reel_3a_speed) SET %jackpot.reel_3a_speed 5
  IF (!%jackpot.reel_3b_speed) SET %jackpot.reel_3b_speed 6
  IF (!%jackpot.reel_3c_speed) SET %jackpot.reel_3c_speed 7
  IF (!%jackpot.lose_msg) SET %jackpot.lose_msg ::: You Lose, user! Better luck next time! BibleThump
  IF (!%jackpot.pull_msg) SET %jackpot.pull_msg user pulls the jackpot machine's lever... PogChamp [Current Jackpot: jptotal]
  IF (!%jackpot.whispers) SET %jackpot.whispers Off
  IF (!%jackpot.stats) SET %jackpot.stats On
}

menu menubar,channel,status {
  !JackPot
  .!JackPot is $IIF(%GAMES_JACKPOT_ACTIVE,ON,OFF) [click to $IIF(%GAMES_JACKPOT_ACTIVE,disable,enable) $+ ]:jp_switch
  .EMOTES
  ..CLICK HERE TO CONFIGURE:jp_emotes
  ..$submenu($_jackpot_emote_menu($1))
  .REEL SPEED
  ..FIRST REEL $chr(91) $+ %jackpot.reel_1_speed seconds $+ $chr(93):jp_reelspeed_1
  ..SECOND REEL $chr(91) $+ %jackpot.reel_2_speed seconds $+ $chr(93):jp_reelspeed_2
  ..THIRD LOSING REEL if first two reels are NOT identical $chr(91) $+ %jackpot.reel_3a_speed seconds $+ $chr(93):jp_reelspeed_3a
  ..THIRD LOSING REEL if first two reels ARE identical $chr(91) $+ %jackpot.reel_3b_speed seconds $+ $chr(93):jp_reelspeed_3b
  ..THIRD WINNING REEL $chr(91) $+ %jackpot.reel_3c_speed seconds $+ $chr(93):jp_reelspeed_3c
  .MESSAGES
  ..LEVER PULL MESSAGE [click to change]:jp_pullmsg
  ..LOSE MESSAGE [click to change]:jp_losemsg
  .COST $chr(91) $+ %jackpot.bet %curname $+ $chr(93):jp_cost
  .COOLDOWN $chr(91) $+ %jackpot.cd seconds $+ $chr(93):jp_cooldown
  .FRESH POT $chr(91) $+ %jackpot.newpot %curname $+ $chr(93):jp_newpot
  .ODDS OF WINNING $chr(91) $+ %jackpot.odds $+ $chr(37) $+ $chr(93):jp_odds
  .CURRENT POT $chr(91) $+ $readini(jackpot.ini,@Stats,Jackpot) %curname $+ $chr(93):jp_currentpot
  .!myjackpot is $IIF(%jackpot.stats == On,ON,OFF) [click to $IIF(%jackpot.stats == On,disable,enable) $+ ]:jp_stats
  .WHISPER MODE is $IIF(%jackpot.whispers == On,ON,OFF) [click to $IIF(%jackpot.whispers == On,disable,enable) $+ ]:jp_whispers
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
  $input(Enter the CURRENT $chr(40) $+ NOT the starting $+ $chr(41) pot for !jackpot,eo,Required Input,$readini(jackpot.ini,@Stats,Jackpot))
  IF ((!$!) || ($! !isnum)) { ECHO You need to input a numerical value for the current pot on !jackpot! | GOTO currentpot }
  ELSE WRITEINI jackpot.ini @Stats Jackpot $floor($!)
}

alias -l jp_whispers {
  IF (%jackpot.whispers == Off) SET %jackpot.whispers On
  ELSE SET %jackpot.whispers Off
}

alias -l jp_stats {
  IF (%jackpot.stats == Off) SET %jackpot.stats On
  ELSE SET %jackpot.stats Off
}

alias jp_losemsg {
  $input(Enter the LOSING message $chr(40) $+ if any $+ $chr(41) that will appear on the third reel. Use the word "user" $chr(40) $+ without qutoes $+ $chr(41) where you want the users name to be displayed:,eo,Required Input,%jackpot.lose_msg)
  SET %jackpot.lose_msg $!
}

alias jp_pullmsg {
  $input(Enter the message that will appear when pulling the jackpot lever. Use the word "user" $chr(40) $+ without qutoes $+ $chr(41) where you want the users name to be displayed and the word "jptotal" $chr(40) $+ without qutoes $+ $chr(41) where you want the current jackpot total to be displayed:,eo,Required Input,%jackpot.pull_msg)
  SET %jackpot.pull_msg $!
}

alias jp_reelspeed_1 {
  :reelspeed
  $input(Enter the number of seconds that the first jackpot reel will appear after the lever pull message:,eo,Required Input,%jackpot.reel_1_speed)
  IF (!$regex($!,^\d+$)) { ECHO You need to use a positive whole number. | GOTO reelspeed }
  ELSE SET %jackpot.reel_1_speed $!
}

alias jp_reelspeed_2 {
  :reelspeed
  $input(Enter the number of seconds that the second jackpot reel will appear after the lever pull message:,eo,Required Input,%jackpot.reel_2_speed)
  IF (!$regex($!,^\d+$)) { ECHO You need to use a positive whole number. | GOTO reelspeed }
  ELSE SET %jackpot.reel_2_speed $!
}

alias jp_reelspeed_3a {
  :reelspeed
  $input(Enter the number of seconds that the third losing jackpot reel will appear after the lever pull message when the first two reels are NOT identical:,eo,Required Input,%jackpot.reel_3a_speed)
  IF (!$regex($!,^\d+$)) { ECHO You need to use a positive whole number. | GOTO reelspeed }
  ELSE SET %jackpot.reel_3a_speed $!
}

alias jp_reelspeed_3b {
  :reelspeed
  $input(Enter the number of seconds that the third losing jackpot reel will appear after the lever pull message when the first two reels ARE identical:,eo,Required Input,%jackpot.reel_3b_speed)
  IF (!$regex($!,^\d+$)) { ECHO You need to use a positive whole number. | GOTO reelspeed }
  ELSE SET %jackpot.reel_3b_speed $!
}

alias jp_reelspeed_3c {
  :reelspeed
  $input(Enter the number of seconds that the third WINNING jackpot reel will appear after the lever pull message:,eo,Required Input,%jackpot.reel_3c_speed)
  IF (!$regex($!,^\d+$)) { ECHO You need to use a positive whole number. | GOTO reelspeed }
  ELSE SET %jackpot.reel_3c_speed $!
}

ON $*:TEXT:/^!jackpot\s(on|off|set|bet|cd|newpot|odds|emotes|whispers|setup)/iS:%mychan: {
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
    ELSEIF (($2 == odds) && ($3 isnum)) {
      SET %jackpot.odds $round($3,3)
      MSG $chan The odds of winning !jackpot have been set to %jackpot.odds $+ $chr(37) $+ .
    }
    ELSEIF (($2 == whispers) && ($3)) {
      IF ($3 == on) {
        IF (%jackpot.whispers == OFF) {
          SET %jackpot.whispers ON
          MSG $chan $nick $+ , !jackpot will now be played through whispers.
        }
        ELSE MSG $chan $nick $+ , !jackpot is already being played through whispers. FailFish
      }
      ELSEIF ($3 == off) {
        IF (%jackpot.whispers == ON) {
          SET %jackpot.whispers OFF
          MSG $chan $nick $+ , !jackpot will now be played in the channel chat.
        }
        ELSE MSG $chan $nick $+ , !jackpot is already being played in the channel chat. FailFish
      }
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
    IF (!$readini(jackpot.ini,@Stats,Last_Winner)) MSG $chan Current !jackpot: $readini(jackpot.ini,@Stats,Jackpot) %curname $+ .  Nobody has won a !jackpot yet!
    ELSE MSG $chan Current !jackpot: $readini(jackpot.ini,@Stats,Jackpot) %curname $+ .  ▌  Last Winner was $readini(jackpot.ini,@Stats,Last_Winner) who won $readini(jackpot.ini,@Stats,Last_Jackpot) %curname on $readini(jackpot.ini,@Stats,Last_Winner_Time) $+ .  ▌  Number of Winners: $readini(jackpot.ini,@Stats,Total_Winners)  ▌  Total Payouts: $bytes($readini(jackpot.ini,@Stats,Total_Winnings),b) %curname $+ .
  }
}

ON $*:TEXT:/^!jackpot(\s)?record$/iS:%mychan: {
  IF (!%floodJACKPOT_RECORD) {
    SET -eu10 %floodJACKPOT_RECORD On
    IF (!$readini(jackpot.ini,@Stats,Record_Name)) MSG $chan Nobody has won a !jackpot yet!
    ELSE MSG $chan The largest !jackpot ever won was for $readini(jackpot.ini,@Stats,Record_Amount) %curname by $readini(jackpot.ini,@Stats,Record_Name) on $readini(jackpot.ini,@Stats,Record_Date) $+ . PogChamp
  }
}

ON $*:TEXT:/^!myjackpot(\s@?\w+)?$/iS:%mychan: {
  IF (%jackpot.stats == On) {
    IF ($nick isop $chan) {
      VAR %user $IIF($2,$remove($2,@),$nick)
      IF ($ini(jackpot.ini,%user) != $null) {
        MSG $chan Jackpot Stats for $twitch_name(%user) ▌ Games Played: $readini(jackpot.ini,%user,Games) ▌ Wins: $readini(jackpot.ini,%user,Wins) ▌ Winnings: $readini(jackpot.ini,%user,Winnings) ▌ Losses: $readini(jackpot.ini,%user,Losses) ▌ Net Winnings: $calc($readini(jackpot.ini,%user,Winnings) - $readini(jackpot.ini,%user,Losses))
      }
      ELSE MSG $chan $remove($2,@) has never played a game of !jackpot!
    }
    ELSEIF ((!$($+(%,myjackpot_CD.,$nick),2)) && (!$2)) {
      SET -eu30 %myjackpot_CD. $+ $nick On
      IF ($ini(jackpot.ini,$nick) != $null) {
        MSG $chan Jackpot Stats for $nick ▌ Games Played: $readini(jackpot.ini,$nick,Games) ▌ Wins: $readini(jackpot.ini,$nick,Wins) ▌ Winnings: $readini(jackpot.ini,$nick,Winnings) ▌ Losses: $readini(jackpot.ini,$nick,Losses) ▌ Net Winnings: $calc($readini(jackpot.ini,$nick,Winnings) - $readini(jackpot.ini,$nick,Losses))
      }
      ELSE MSG $chan $nick $+ , you've never played !jackpot!
    }
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
    MSG $nick Be patient, $nick $+ !  You still have $duration($timer(.JACKPOT. $+ $nick).secs) left in your !jackpot cooldown.
  }
  ELSEIF ($checkpoints($nick, %jackpot.bet) == false) {
    IF ($($+(%,pointcheck_CD.,$nick),2)) halt
    SET -eu10 %pointcheck_CD. $+ $nick On
    MSG $chan $nick $+ , you do not have %jackpot.bet %curname to play !jackpot  FailFish
  }
  ELSEIF (!$istok(%queue, $nick $+ .jackpot,32)) {
    REMOVEPOINTS $nick %jackpot.bet
    IF (%ActiveGame) SET %queue %queue $nick $+ .jackpot
    ELSE play_jackpot $nick
  }
}

alias play_jackpot {
  ; PLAY THE JACKPOT AND GENERATE REELS
  .timer.JACKPOT. $+ $1 1 %jackpot.cd MSG $1 $1 $+ , your !jackpot cooldown has expired.  Feel free to play again.  BloodTrail
  SET %ActiveGame On
  WRITEINI jackpot.ini @Stats Jackpot $calc($readini(jackpot.ini,@Stats,Jackpot) + %jackpot.bet)
  WRITEINI jackpot.ini $1 Games $calc($readini(jackpot.ini,$1,Games) + 1)
  WRITEINI jackpot.ini $1 Losses $calc($readini(jackpot.ini,$1,Losses) + %jackpot.bet)
  IF ($readini(jackpot.ini,$1,Wins) == $null) WRITEINI jackpot.ini $1 Wins 0
  IF ($readini(jackpot.ini,$1,Winnings) == $null) WRITEINI jackpot.ini $1 Winnings 0
  IF (%jackpot.whispers == OFF) {
    MSG $1 $1 $+ , you spent %jackpot.bet %curname on !jackpot.
    MSG %mychan $replace($replace(%jackpot.pull_msg,user,$1),jptotal,$readini(jackpot.ini,@Stats,Jackpot) %curname)
  }
  ELSE MSG $1 $1 $+ , you spent %jackpot.bet %curname on !jackpot. [Current Jackpot: $readini(jackpot.ini,@Stats,Jackpot) %curname $+ ]
  VAR %jackpot.num.emotes = $numtok(%jackpot.emotes,32)
  IF ($rand(1,100000) isnum 1 - $calc(%jackpot.odds * 1000)) {
    VAR %jackpot $readini(jackpot.ini,@Stats,Jackpot)
    VAR %x = $rand(1,%jackpot.num.emotes)
    VAR %reel.1 $gettok(%jackpot.emotes,%x,32)
    VAR %reel.2 $gettok(%jackpot.emotes,%x,32)
    VAR %reel.3 $gettok(%jackpot.emotes,%x,32)
    .timer.jackpot_01 1 %jackpot.reel_1_speed $IIF(%jackpot.whispers == OFF,DESCRIBE %mychan,MSG $1)  ▌ %reel.1 ▌
    .timer.jackpot_02 1 %jackpot.reel_2_speed $IIF(%jackpot.whispers == OFF,DESCRIBE %mychan,MSG $1)  ▌ %reel.1 ▌ %reel.2 ▌
    .timer.jackpot_03 1 %jackpot.reel_3c_speed $IIF(%jackpot.whispers == OFF,DESCRIBE %mychan,MSG $1)  ▌ %reel.1 ▌ %reel.2 ▌ %reel.3 ▌ ::: You Won %jackpot %curname $+ , $1 $+ ! Congratulations! PogChamp
    .timer.jackpotwinner1 1 $calc(%jackpot.reel_3c_speed +1) MSG %mychan KAPOW KAPOW KAPOW OMG!!!  JACKPOT!!! $1 just won %jackpot %curname $+ !!!  KAPOW KAPOW KAPOW
    .timer.jackpotwinner2 1 $calc(%jackpot.reel_3c_speed +2) MSG %mychan KAPOW KAPOW KAPOW OMG!!!  JACKPOT!!! $1 just won %jackpot %curname $+ !!!  KAPOW KAPOW KAPOW
    .timer.jackpotwinner3 1 $calc(%jackpot.reel_3c_speed +3) MSG %mychan KAPOW KAPOW KAPOW OMG!!!  JACKPOT!!! $1 just won %jackpot %curname $+ !!!  KAPOW KAPOW KAPOW
    .timer.jackpotwinner4 1 $calc(%jackpot.reel_3c_speed +3) jackpotwinner $1
  }
  ELSE {
    VAR %x = 1
    WHILE (%x <= 3) {
      ; FIRST REEL, OR THIRD REEL IF FIRST TWO REELS ARE NOT IDENTICAL
      IF ((%x == 1) || ((%x == 3) && (%reel.1 != %reel.2))) {
        IF (%x == 3) VAR %reelspeed = %jackpot.reel_3a_speed
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
        VAR %reelspeed = %jackpot.reel_3b_speed
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
    .timer.jackpot_01 1 %jackpot.reel_1_speed $IIF(%jackpot.whispers == OFF,DESCRIBE %mychan,MSG $1)  ▌ %reel.1 ▌
    .timer.jackpot_02 1 %jackpot.reel_2_speed $IIF(%jackpot.whispers == OFF,DESCRIBE %mychan,MSG $1)  ▌ %reel.1 ▌ %reel.2 ▌
    .timer.jackpot_03 1 %reelspeed $IIF(%jackpot.whispers == OFF,DESCRIBE %mychan,MSG $1)  ▌ %reel.1 ▌ %reel.2 ▌ %reel.3 ▌ $replace(%jackpot.lose_msg,user,$1)
    .timer.jackpot_04 1 %reelspeed end_game
  }
}

alias jackpotwinner {
  ADDPOINTS $1 $readini(jackpot.ini,@Stats,Jackpot)
  IF (($readini(jackpot.ini,@Stats,Jackpot) > $readini(jackpot.ini,@Stats,Record_Amount)) || (!$readini(jackpot.ini,@Stats,Record_Amount))) {
    WRITEINI jackpot.ini @Stats Record_Name $1
    WRITEINI jackpot.ini @Stats Record_Amount $readini(jackpot.ini,@Stats,Jackpot)
    WRITEINI jackpot.ini @Stats Record_Date $asctime(mmm d h:nn TT) EST
  }
  WRITEINI jackpot.ini @Stats Last_Jackpot $readini(jackpot.ini,@Stats,Jackpot)
  WRITEINI jackpot.ini @Stats Last_Winner $1
  WRITEINI jackpot.ini @Stats Last_Winner_Time $asctime(mmm d h:nn TT) EST
  WRITEINI jackpot.ini @Stats Total_Winners $calc($readini(jackpot.ini,@Stats,Total_Winners) + 1)
  WRITEINI jackpot.ini @Stats Total_Winnings $calc($readini(jackpot.ini,@Stats,Total_Winnings) + $readini(jackpot.ini,@Stats,Jackpot))
  WRITEINI jackpot.ini $1 Wins $calc($readini(jackpot.ini,$1,Wins) + 1)
  WRITEINI jackpot.ini $1 Winnings $calc($readini(jackpot.ini,$1,Winnings) + %jackpot)
  WRITEINI jackpot.ini @Stats Jackpot %jackpot.newpot
  end_game
}
