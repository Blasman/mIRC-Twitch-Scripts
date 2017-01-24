;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BLASBOT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;; TWITCH.TV/BLASMAN13 ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;; SLOTS VERSION 2.0.0.3 ;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

alias slot_version return 2.0.0.3

ON *:LOAD: slot_setup

ON *:UNLOAD: UNSET %slot.*

alias slot_setup {
  IF ($blasbot_version < 1.0.0.0) {
    $dialog(slot_important,slot_important)
    url -m https://github.com/Blasman/mIRC-Twitch-Scripts/wiki/Script-Documentation
    unload -rs slot.50x.v2.mrc
    halt
  }
  IF (!%slot.houseedge) SET %slot.houseedge 0
  IF (!%slot.minbet) SET %slot.minbet 50
  IF (!%slot.maxbet) SET %slot.maxbet 1000
  IF (!%slot.cd) SET %slot.cd 600
  IF (!%slot.emotes) SET %slot.emotes 1x 2x 3x 5x 10x 25x 50x
  slot_houseedge
  slot_emotes
  slot_cost
  slot_cooldown
  IF (!%slot.reel_1_speed) SET %slot.reel_1_speed 1
  IF (!%slot.reel_2_speed) SET %slot.reel_2_speed 3
  IF (!%slot.reel_3a_speed) SET %slot.reel_3a_speed 5
  IF (!%slot.reel_3b_speed) SET %slot.reel_3b_speed 6
  IF (!%slot.reel_3c_speed) SET %slot.reel_3c_speed 7
  IF (!%slot.lose_msg) SET %slot.lose_msg ::: You Lose, user! Better luck next time! BibleThump
  IF (!%slot.pull_msg) SET %slot.pull_msg user pulls the slot machine's lever... PogChamp
  IF (!%slot.whispers) SET %slot.whispers Off
  IF (!%slot.stats) SET %slot.stats On
}

dialog slot_important {
  title "IMPORTANT!"
  size -1 -1 200 60
  option dbu
  text "You are NOT running the latest version of blasbot.mrc from Blasman's GitHub. This script will NOT work for you until you install it! Setup will exit once you click Okay.", 1, 10 10 180 20
  button "Okay", 3, 80 65 40 12, ok
}

menu menubar,channel,status {
  !Slot
  .$style(2) Version $slot_version:$null
  .!Slot is $IIF(%GAMES_SLOT_ACTIVE,ON,OFF) [click to $IIF(%GAMES_SLOT_ACTIVE,disable,enable) $+ ]:slot_switch
  .EMOTES
  ..CLICK HERE TO CONFIGURE:slot_emotes
  ..$submenu($_slot_emote_menu($1))
  .REEL SPEED
  ..FIRST REEL $chr(91) $+ %slot.reel_1_speed seconds $+ $chr(93):slot_reelspeed_1
  ..SECOND REEL $chr(91) $+ %slot.reel_2_speed seconds $+ $chr(93):slot_reelspeed_2
  ..THIRD LOSING REEL if first two reels are NOT identical $chr(91) $+ %slot.reel_3a_speed seconds $+ $chr(93):slot_reelspeed_3a
  ..THIRD LOSING REEL if first two reels ARE identical $chr(91) $+ %slot.reel_3b_speed seconds $+ $chr(93):slot_reelspeed_3b
  ..THIRD WINNING REEL $chr(91) $+ %slot.reel_3c_speed seconds $+ $chr(93):slot_reelspeed_3c
  .MESSAGES
  ..LEVER PULL MESSAGE [click to change]:slot_pullmsg
  ..LOSE MESSAGE [click to change]:slot_losemsg
  .COST $chr(91) $+ %slot.minbet - %slot.maxbet %curname $+ $chr(93):slot_cost
  .COOLDOWN $chr(91) $+ %slot.cd seconds $+ $chr(93):slot_cooldown
  .HOUSE EDGE $chr(91) $+ %slot.houseedge $+ $chr(37) $+ $chr(93):slot_houseedge
  .!myslots is $IIF(%slot.stats == On,ON,OFF) [click to $IIF(%slot.stats == On,disable,enable) $+ ]:slot_stats
  .WHISPER MODE is $IIF(%slot.whispers == On,ON,OFF) [click to $IIF(%slot.whispers == On,disable,enable) $+ ]:slot_whispers
}

alias -l _slot_emote_menu {
  IF ($1 == begin) { RETURN - }
  IF ($1 == end) { RETURN - }
  IF ($gettok(%slot.emotes,$1,32)) { RETURN $style(2) $ifmatch : $ifmatch }
}

alias -l slot_switch {
  IF (!%GAMES_SLOT_ACTIVE) {
    SET %GAMES_SLOT_ACTIVE On
    MSG %mychan !slot is now enabled!  Have fun!  PogChamp
  }
  ELSE {
    UNSET %GAMES_SLOT_ACTIVE
    MSG %mychan !slot is now disabled.
  }
}

alias -l slot_cost {
  :cost
  $input(Input the minimum and maximum %curname it will cost to play slot $chr(40) $+ example: %slot.minbet %slot.maxbet $+ $chr(41):,eo,Required Input,%slot.minbet %slot.maxbet)
  IF (!$!) { ECHO You need to input two numbers for the minimum and maximum bet for !slot }
  ELSE {
    VAR %bets $!
    IF (($numtok(%bets,32) != 2) || ($gettok(%bets,1,32) !isnum) || ($gettok(%bets,2,32) !isnum)) { ECHO You need to input two numbers for the minimum and maximum bet for !slot | GOTO cost }
    ELSE {
      SET %slot.minbet $floor($gettok(%bets,1,32))
      SET %slot.maxbet $floor($gettok(%bets,2,32))
    }
  }
}

alias -l slot_cooldown {
  :cooldown
  $input(What will be the cooldown in seconds per user for !slot?,eo,Required Input,%slot.cd)
  IF ((!$!) || ($! !isnum)) { ECHO You need to input a numerical value for the per-user cooldown on !slot! | GOTO cooldown }
  ELSE SET %slot.cd $floor($!)
}

alias -l slot_emotes {
  :emotes
  $input(Input seven emotes that you would like to use for !slot:,eo,Required Input,%slot.emotes)
  IF (!$!) { ECHO You need to input seven emotes for !slot! | GOTO emotes }
  ELSE {
    VAR %emotes $!
    IF ($numtok(%emotes,32) != 7) GOTO emotes
    SET %slot.emotes %emotes
  }
}

alias -l slot_houseedge {
  :houseedge
  $input(Be careful with this setting! IF THIS CONFUSES YOU $+ $chr(44) JUST LEAVE THIS SET TO 0. Specify the "house edge" for !slot? $chr(40) $+ from -100 to 100 percent $+ $chr(41) $chr(40) $+ example: -100 guarantees the user always wins ▌ 100 guarantees the bot always wins ▌ 0 means the user will win 31.33% of games. Overall $+ $chr(44) they will win 1 %curname for every 1 %curname bet. They will break even. ▌ -45.624 will DOUBLE the overall amount of wins per user. They will win 2 %curname for every 1 %curname bet. ▌ 50 will DOUBLE the overall losses per user. They will win 1 %curname for every 2 %curname bet. $+ $chr(41) Decimal places are okay. See the documentation on the GitHub wiki for more information.,eo,Required Input,%slot.houseedge)
  IF ($remove($!,$chr(37)) !isnum -100 - 100) { ECHO You need to enter a number between -100 and 100! | GOTO houseedge }
  ELSE SET %slot.houseedge $round($!,5)
}

alias -l slot_whispers {
  IF (%slot.whispers == Off) SET %slot.whispers On
  ELSE SET %slot.whispers Off
}

alias -l slot_stats {
  IF (%slot.stats == Off) SET %slot.stats On
  ELSE SET %slot.stats Off
}

alias slot_losemsg {
  $input(Enter the LOSING message $chr(40) $+ if any $+ $chr(41) that will appear on the third reel. Use the word "user" $chr(40) $+ without qutoes $+ $chr(41) where you want the users name to be displayed:,eo,Required Input,%slot.lose_msg)
  SET %slot.lose_msg $!
}

alias slot_pullmsg {
  $input(Enter the message that will appear when pulling the slot lever. Use the word "user" $chr(40) $+ without qutoes $+ $chr(41) where you want the users name to be displayed:,eo,Required Input,%slot.pull_msg)
  SET %slot.pull_msg $!
}

alias slot_reelspeed_1 {
  :reelspeed
  $input(Enter the number of seconds that the first slot reel will appear after the lever pull message:,eo,Required Input,%slot.reel_1_speed)
  IF (!$regex($!,^\d+$)) { ECHO You need to use a positive whole number. | GOTO reelspeed }
  ELSE SET %slot.reel_1_speed $!
}

alias slot_reelspeed_2 {
  :reelspeed
  $input(Enter the number of seconds that the second slot reel will appear after the lever pull message:,eo,Required Input,%slot.reel_2_speed)
  IF (!$regex($!,^\d+$)) { ECHO You need to use a positive whole number. | GOTO reelspeed }
  ELSE SET %slot.reel_2_speed $!
}

alias slot_reelspeed_3a {
  :reelspeed
  $input(Enter the number of seconds that the third losing slot reel will appear after the lever pull message when the first two reels are NOT identical:,eo,Required Input,%slot.reel_3a_speed)
  IF (!$regex($!,^\d+$)) { ECHO You need to use a positive whole number. | GOTO reelspeed }
  ELSE SET %slot.reel_3a_speed $!
}

alias slot_reelspeed_3b {
  :reelspeed
  $input(Enter the number of seconds that the third losing slot reel will appear after the lever pull message when the first two reels ARE identical:,eo,Required Input,%slot.reel_3b_speed)
  IF (!$regex($!,^\d+$)) { ECHO You need to use a positive whole number. | GOTO reelspeed }
  ELSE SET %slot.reel_3b_speed $!
}

alias slot_reelspeed_3c {
  :reelspeed
  $input(Enter the number of seconds that the third WINNING slot reel will appear after the lever pull message:,eo,Required Input,%slot.reel_3c_speed)
  IF (!$regex($!,^\d+$)) { ECHO You need to use a positive whole number. | GOTO reelspeed }
  ELSE SET %slot.reel_3c_speed $!
}

ON $*:TEXT:/^!slot(s)?\s(on|off|minbet|maxbet|cd|houseedge|emotes|whispers|setup)/iS:%mychan: {
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
    ELSEIF (($2 == minbet) && ($3 isnum)) {
      SET %slot.minbet $floor($3)
      MSG $chan The minimum amount of %curname to play !slot has been changed to %slot.minbet $+ !
    }
    ELSEIF (($2 == maxbet) && ($3 isnum)) {
      SET %slot.maxbet $floor($3)
      MSG $chan The maximum amount of %curname to play !slot has been changed to %slot.maxbet $+ !
    }
    ELSEIF (($2 == cd) && ($3 isnum)) {
      SET %slot.cd $floor($3)
      MSG $chan The cooldown time for !slot has been changed to %slot.cd seconds!
    }
    ELSEIF (($2 == houseedge) && ($3 isnum)) {
      SET %slot.houseedge $round($3,3)
      MSG $chan The houseedge for !slot has been set to %slot.houseedge $+ $chr(37) $+ .
    }
    ELSEIF (($2 == whispers) && ($3)) {
      IF ($3 == on) {
        IF (%slot.whispers == OFF) {
          SET %slot.whispers ON
          MSG $chan $nick $+ , !slot will now be played through whispers.
        }
        ELSE MSG $chan $nick $+ , !slot is already being played through whispers. FailFish
      }
      ELSEIF ($3 == off) {
        IF (%slot.whispers == ON) {
          SET %slot.whispers OFF
          MSG $chan $nick $+ , !slot will now be played in the channel chat.
        }
        ELSE MSG $chan $nick $+ , !slot is already being played in the channel chat. FailFish
      }
    }
    ELSEIF ($2 == emotes) {
      IF ($9) {
        SET %slot.emotes $3-
        MSG $chan The !slot emotes have been set to %slot.emotes
      }
      ELSE MSG $chan $nick $+ , you need to specify seven emotes for the !slot.
    }
  }
  ELSEIF (($nick == %streamer) && ($2 == setup)) slot_setup
}

ON $*:TEXT:/^!myslot(s)?(\s@?\w+)?$/iS:%mychan: {
  IF (%slot.stats == On) {
    IF ($nick isop $chan) {
      VAR %user $IIF($2,$remove($2,@),$nick)
      IF ($ini(slot.ini,%user) != $null) {
        MSG $chan Slot Stats for $twitch_name(%user) ▌ Games Played: $readini(slot.ini,%user,Games) ▌ Games Won: $readini(slot.ini,%user,Wins) ▌ Winnings: $readini(slot.ini,%user,Winnings) ▌ Losses: $readini(slot.ini,%user,Losses) ▌ Net Winnings: $calc($readini(slot.ini,%user,Winnings) - $readini(slot.ini,%user,Losses))
      }
      ELSE MSG $chan %user has never played a game of !slot!
    }
    ELSEIF ((!$($+(%,myslot_CD.,$nick),2)) && (!$2)) {
      SET -eu30 %myslot_CD. $+ $nick On
      IF ($ini(slot.ini,$nick) != $null) {
        MSG $chan slot Stats for $nick ▌ Games Played: $readini(slot.ini,$nick,Games) ▌ Games Won: $readini(slot.ini,$nick,Wins) ▌ Winnings: $readini(slot.ini,$nick,Winnings) ▌ Losses: $readini(slot.ini,$nick,Losses) ▌ Net Winnings: $calc($readini(slot.ini,$nick,Winnings) - $readini(slot.ini,$nick,Losses))
      }
      ELSE MSG $chan $nick $+ , you've never played !slot!
    }
  }
}

ON $*:TEXT:/^!slot(s)?(\s\d+)?$/Si:%mychan: {
  IF ((%ActiveGame == $nick $+ .slot) || ($wildtok(%queue,$nick $+ .slot.*,0,32))) halt
  ELSEIF (!$2) {
    IF (%CD_SLOT_HELP) halt
    SET -eu10 %CD_SLOT_HELP On
    MSG $chan You may bet any amount of %curname from %slot.minbet to %slot.maxbet on !slot. Example: !slot %slot.maxbet
  }
  ELSEIF (!%GAMES_SLOT_ACTIVE) {
    IF ((%CD_SLOT_ACTIVE) || ($($+(%,CD_SLOT_ACTIVE.,$nick),2))) halt
    SET -eu15 %CD_SLOT_ACTIVE On
    SET -eu120 %CD_SLOT_ACTIVE. $+ $nick On
    MSG $chan $nick $+ , the !slot game is currently disabled.  This usually happens when the stream is live.
  }
  ELSEIF ($($+(%,CD_SLOT_CD.,$nick),2)) || ($timer(.SLOT. $+ $nick)) {
    IF ($($+(%,CD_SLOT_CD.,$nick),2)) halt
    SET -eu120 %CD_SLOT_CD. $+ $nick On
    MSG $nick Be patient $+ , $nick $+ !  You still have $duration($timer(.SLOT. $+ $nick).secs) left in your !slot cooldown.
  }
  ELSEIF ($2 !isnum %slot.minbet - %slot.maxbet) {
    IF ($($+(%,CD_SLOT_RANGECHECK.,$nick),2)) halt
    SET -eu10 %CD_SLOT_RANGECHECK. $+ $nick On
    MSG $chan $nick $+ , please enter a valid wager between %slot.minbet and %slot.maxbet %curname $+ .
  }
  ELSEIF ($checkpoints($nick, $2) == false) {
    IF ($($+(%,CD_SLOT_CHECKPOINTS.,$nick),2)) halt
    SET -eu10 %CD_SLOT_CHECKPOINTS. $+ $nick On
    MSG $chan $nick $+ , you do not have $2 %curname to play slots.  FailFish
  }
  ELSE {
    REMOVEPOINTS $nick $2
    IF (%ActiveGame) SET %queue %queue $nick $+ .slot $+ . $+ $2
    ELSE play_slot $nick $2
  }
}

alias play_slot {
  SET %ActiveGame $1 $+ .slot
  VAR %slotbet $floor($2)
  .timer.SLOT. $+ $1 1 %slot.cd MSG $1 $1 $+ , your !slot cooldown has expired.  Feel free to play again.  BloodTrail
  WRITEINI slot.ini $1 Games $calc($readini(slot.ini,$1,Games) + 1)
  WRITEINI slot.ini $1 Losses $calc($readini(slot.ini,$1,Losses) + %slotbet)
  IF ($readini(slot.ini,$1,Wins) == $null) WRITEINI slot.ini $1 Wins 0
  IF ($readini(slot.ini,$1,Winnings) == $null) WRITEINI slot.ini $1 Winnings 0
  MSG $IIF(%slot.whispers == OFF,%mychan,$1) $replace(%slot.pull_msg,user,$1)
  IF (%slot.houseedge == 0) VAR %houseedge = 0
  ELSEIF (%slot.houseedge < 0) VAR %houseedge = %slot.houseedge * -68.67
  ELSEIF (%slot.houseedge > 0) VAR %houseedge = %slot.houseedge * -31.33
  VAR %a = $round($calc(%houseedge + 3133),0)
  VAR %b = $rand(1,10000)
  IF (%b isnum 1 - %a) {
    VAR %b = $rand(1,31333)
    IF (%b isnum 1-14286) { VAR %slot.1 $gettok(%slot.emotes,1,32) | VAR %slot.2 $gettok(%slot.emotes,1,32) | VAR %slot.3 $gettok(%slot.emotes,1,32) }
    IF (%b isnum 14287-21429) { VAR %slot.1 $gettok(%slot.emotes,2,32) | VAR %slot.2 $gettok(%slot.emotes,2,32) | VAR %slot.3 $gettok(%slot.emotes,2,32) }
    IF (%b isnum 21430-26191) { VAR %slot.1 $gettok(%slot.emotes,3,32) | VAR %slot.2 $gettok(%slot.emotes,3,32) | VAR %slot.3 $gettok(%slot.emotes,3,32) }
    IF (%b isnum 26192-29048) { VAR %slot.1 $gettok(%slot.emotes,4,32) | VAR %slot.2 $gettok(%slot.emotes,4,32) | VAR %slot.3 $gettok(%slot.emotes,4,32) }
    IF (%b isnum 29049-30477) { VAR %slot.1 $gettok(%slot.emotes,5,32) | VAR %slot.2 $gettok(%slot.emotes,5,32) | VAR %slot.3 $gettok(%slot.emotes,5,32) }
    IF (%b isnum 30478-31048) { VAR %slot.1 $gettok(%slot.emotes,6,32) | VAR %slot.2 $gettok(%slot.emotes,6,32) | VAR %slot.3 $gettok(%slot.emotes,6,32) }
    IF (%b isnum 31049-31333) { VAR %slot.1 $gettok(%slot.emotes,7,32) | VAR %slot.2 $gettok(%slot.emotes,7,32) | VAR %slot.3 $gettok(%slot.emotes,7,32) }
  }
  ELSE {
    VAR %x = 1
    WHILE (%x <= 3) {
      IF ((%x == 1) || ((%x == 3) && (%slot.1 != %slot.2))) {
        VAR %y = $rand(1,7)
        IF (%y == 1) VAR %slot. $+ %x $gettok(%slot.emotes,1,32)
        ELSEIF (%y == 2) VAR %slot. $+ %x $gettok(%slot.emotes,2,32)
        ELSEIF (%y == 3) VAR %slot. $+ %x $gettok(%slot.emotes,3,32)
        ELSEIF (%y == 4) VAR %slot. $+ %x $gettok(%slot.emotes,4,32)
        ELSEIF (%y == 5) VAR %slot. $+ %x $gettok(%slot.emotes,5,32)
        ELSEIF (%y == 6) VAR %slot. $+ %x $gettok(%slot.emotes,6,32)
        ELSEIF (%y == 7) VAR %slot. $+ %x $gettok(%slot.emotes,7,32)
        INC %x
      }
      ELSEIF (%x == 2) {
        VAR %y = $rand(1,11)
        IF (%slot.1 == $gettok(%slot.emotes,1,32)) {
          IF (%y isnum 1-5) VAR %slot. $+ %x $gettok(%slot.emotes,1,32)
          ELSEIF (%y == 6) VAR %slot. $+ %x $gettok(%slot.emotes,2,32)
          ELSEIF (%y == 7) VAR %slot. $+ %x $gettok(%slot.emotes,3,32)
          ELSEIF (%y == 8) VAR %slot. $+ %x $gettok(%slot.emotes,4,32)
          ELSEIF (%y == 9) VAR %slot. $+ %x $gettok(%slot.emotes,5,32)
          ELSEIF (%y == 10) VAR %slot. $+ %x $gettok(%slot.emotes,6,32)
          ELSEIF (%y == 11) VAR %slot. $+ %x $gettok(%slot.emotes,7,32)
        }
        ELSEIF (%slot.1 == $gettok(%slot.emotes,2,32)) {
          IF (%y == 1) VAR %slot. $+ %x $gettok(%slot.emotes,1,32)
          ELSEIF (%y isnum 2-6) VAR %slot. $+ %x $gettok(%slot.emotes,2,32)
          ELSEIF (%y == 7) VAR %slot. $+ %x $gettok(%slot.emotes,3,32)
          ELSEIF (%y == 8) VAR %slot. $+ %x $gettok(%slot.emotes,4,32)
          ELSEIF (%y == 9) VAR %slot. $+ %x $gettok(%slot.emotes,5,32)
          ELSEIF (%y == 10) VAR %slot. $+ %x $gettok(%slot.emotes,6,32)
          ELSEIF (%y == 11) VAR %slot. $+ %x $gettok(%slot.emotes,7,32)
        }
        ELSEIF (%slot.1 == $gettok(%slot.emotes,3,32)) {
          IF (%y == 1) VAR %slot. $+ %x $gettok(%slot.emotes,1,32)
          ELSEIF (%y == 2) VAR %slot. $+ %x $gettok(%slot.emotes,2,32)
          ELSEIF (%y isnum 3-7) VAR %slot. $+ %x $gettok(%slot.emotes,3,32)
          ELSEIF (%y == 8) VAR %slot. $+ %x $gettok(%slot.emotes,4,32)
          ELSEIF (%y == 9) VAR %slot. $+ %x $gettok(%slot.emotes,5,32)
          ELSEIF (%y == 10) VAR %slot. $+ %x $gettok(%slot.emotes,6,32)
          ELSEIF (%y == 11) VAR %slot. $+ %x $gettok(%slot.emotes,7,32)
        }
        ELSEIF (%slot.1 == $gettok(%slot.emotes,4,32)) {
          IF (%y == 1) VAR %slot. $+ %x $gettok(%slot.emotes,1,32)
          ELSEIF (%y == 2) VAR %slot. $+ %x $gettok(%slot.emotes,2,32)
          ELSEIF (%y == 3) VAR %slot. $+ %x $gettok(%slot.emotes,3,32)
          ELSEIF (%y isnum 4-8) VAR %slot. $+ %x $gettok(%slot.emotes,4,32)
          ELSEIF (%y == 9) VAR %slot. $+ %x $gettok(%slot.emotes,5,32)
          ELSEIF (%y == 10) VAR %slot. $+ %x $gettok(%slot.emotes,6,32)
          ELSEIF (%y == 11) VAR %slot. $+ %x $gettok(%slot.emotes,7,32)
        }
        ELSEIF (%slot.1 == $gettok(%slot.emotes,5,32)) {
          IF (%y == 1) VAR %slot. $+ %x $gettok(%slot.emotes,1,32)
          ELSEIF (%y == 2) VAR %slot. $+ %x $gettok(%slot.emotes,2,32)
          ELSEIF (%y == 3) VAR %slot. $+ %x $gettok(%slot.emotes,3,32)
          ELSEIF (%y == 4) VAR %slot. $+ %x $gettok(%slot.emotes,4,32)
          ELSEIF (%y isnum 5-9) VAR %slot. $+ %x $gettok(%slot.emotes,5,32)
          ELSEIF (%y == 10) VAR %slot. $+ %x $gettok(%slot.emotes,6,32)
          ELSEIF (%y == 11) VAR %slot. $+ %x $gettok(%slot.emotes,7,32)
        }
        ELSEIF (%slot.1 == $gettok(%slot.emotes,6,32)) {
          IF (%y == 1) VAR %slot. $+ %x $gettok(%slot.emotes,1,32)
          ELSEIF (%y == 2) VAR %slot. $+ %x $gettok(%slot.emotes,2,32)
          ELSEIF (%y == 3) VAR %slot. $+ %x $gettok(%slot.emotes,3,32)
          ELSEIF (%y == 4) VAR %slot. $+ %x $gettok(%slot.emotes,4,32)
          ELSEIF (%y == 5) VAR %slot. $+ %x $gettok(%slot.emotes,5,32)
          ELSEIF (%y isnum 6-10) VAR %slot. $+ %x $gettok(%slot.emotes,6,32)
          ELSEIF (%y == 11) VAR %slot. $+ %x $gettok(%slot.emotes,7,32)
        }
        ELSEIF (%slot.1 == $gettok(%slot.emotes,7,32)) {
          IF (%y == 1) VAR %slot. $+ %x $gettok(%slot.emotes,1,32)
          ELSEIF (%y == 2) VAR %slot. $+ %x $gettok(%slot.emotes,2,32)
          ELSEIF (%y == 3) VAR %slot. $+ %x $gettok(%slot.emotes,3,32)
          ELSEIF (%y == 4) VAR %slot. $+ %x $gettok(%slot.emotes,4,32)
          ELSEIF (%y == 5) VAR %slot. $+ %x $gettok(%slot.emotes,5,32)
          ELSEIF (%y == 6) VAR %slot. $+ %x $gettok(%slot.emotes,6,32)
          ELSEIF (%y isnum 7-11) VAR %slot. $+ %x $gettok(%slot.emotes,7,32)
        }
        INC %x
      }
      ELSE {
        VAR %y = $rand(1,6)
        IF (%slot.1 == $gettok(%slot.emotes,1,32)) {
          IF (%y == 1) VAR %slot.3 $gettok(%slot.emotes,2,32)
          ELSEIF (%y == 2) VAR %slot.3 $gettok(%slot.emotes,3,32)
          ELSEIF (%y == 3) VAR %slot.3 $gettok(%slot.emotes,4,32)
          ELSEIF (%y == 4) VAR %slot.3 $gettok(%slot.emotes,5,32)
          ELSEIF (%y == 5) VAR %slot.3 $gettok(%slot.emotes,6,32)
          ELSEIF (%y == 6) VAR %slot.3 $gettok(%slot.emotes,7,32)
        }
        ELSEIF (%slot.1 == $gettok(%slot.emotes,2,32)) {
          IF (%y == 1) VAR %slot.3 $gettok(%slot.emotes,1,32)
          ELSEIF (%y == 2) VAR %slot.3 $gettok(%slot.emotes,3,32)
          ELSEIF (%y == 3) VAR %slot.3 $gettok(%slot.emotes,4,32)
          ELSEIF (%y == 4) VAR %slot.3 $gettok(%slot.emotes,5,32)
          ELSEIF (%y == 5) VAR %slot.3 $gettok(%slot.emotes,6,32)
          ELSEIF (%y == 6) VAR %slot.3 $gettok(%slot.emotes,7,32)
        }
        ELSEIF (%slot.1 == $gettok(%slot.emotes,3,32)) {
          IF (%y == 1) VAR %slot.3 $gettok(%slot.emotes,1,32)
          ELSEIF (%y == 2) VAR %slot.3 $gettok(%slot.emotes,2,32)
          ELSEIF (%y == 3) VAR %slot.3 $gettok(%slot.emotes,4,32)
          ELSEIF (%y == 4) VAR %slot.3 $gettok(%slot.emotes,5,32)
          ELSEIF (%y == 5) VAR %slot.3 $gettok(%slot.emotes,6,32)
          ELSEIF (%y == 6) VAR %slot.3 $gettok(%slot.emotes,7,32)
        }
        ELSEIF (%slot.1 == $gettok(%slot.emotes,4,32)) {
          IF (%y == 1) VAR %slot.3 $gettok(%slot.emotes,1,32)
          ELSEIF (%y == 2) VAR %slot.3 $gettok(%slot.emotes,2,32)
          ELSEIF (%y == 3) VAR %slot.3 $gettok(%slot.emotes,3,32)
          ELSEIF (%y == 4) VAR %slot.3 $gettok(%slot.emotes,5,32)
          ELSEIF (%y == 5) VAR %slot.3 $gettok(%slot.emotes,6,32)
          ELSEIF (%y == 6) VAR %slot.3 $gettok(%slot.emotes,7,32)
        }
        ELSEIF (%slot.1 == $gettok(%slot.emotes,5,32)) {
          IF (%y == 1) VAR %slot.3 $gettok(%slot.emotes,1,32)
          ELSEIF (%y == 2) VAR %slot.3 $gettok(%slot.emotes,2,32)
          ELSEIF (%y == 3) VAR %slot.3 $gettok(%slot.emotes,3,32)
          ELSEIF (%y == 4) VAR %slot.3 $gettok(%slot.emotes,4,32)
          ELSEIF (%y == 5) VAR %slot.3 $gettok(%slot.emotes,6,32)
          ELSEIF (%y == 6) VAR %slot.3 $gettok(%slot.emotes,7,32)
        }
        ELSEIF (%slot.1 == $gettok(%slot.emotes,6,32)) {
          IF (%y == 1) VAR %slot.3 $gettok(%slot.emotes,1,32)
          ELSEIF (%y == 2) VAR %slot.3 $gettok(%slot.emotes,2,32)
          ELSEIF (%y == 3) VAR %slot.3 $gettok(%slot.emotes,3,32)
          ELSEIF (%y == 4) VAR %slot.3 $gettok(%slot.emotes,4,32)
          ELSEIF (%y == 5) VAR %slot.3 $gettok(%slot.emotes,5,32)
          ELSEIF (%y == 6) VAR %slot.3 $gettok(%slot.emotes,7,32)
        }
        ELSEIF (%slot.1 == $gettok(%slot.emotes,7,32)) {
          IF (%y == 1) VAR %slot.3 $gettok(%slot.emotes,1,32)
          ELSEIF (%y == 2) VAR %slot.3 $gettok(%slot.emotes,2,32)
          ELSEIF (%y == 3) VAR %slot.3 $gettok(%slot.emotes,3,32)
          ELSEIF (%y == 4) VAR %slot.3 $gettok(%slot.emotes,4,32)
          ELSEIF (%y == 5) VAR %slot.3 $gettok(%slot.emotes,5,32)
          ELSEIF (%y == 6) VAR %slot.3 $gettok(%slot.emotes,6,32)
        }
        INC %x
      }
    }
  }
  IF ((%slot.1 == %slot.2) && (%slot.2 == %slot.3)) {
    IF (%slot.1 == $gettok(%slot.emotes,1,32)) VAR %payout = %slotbet
    IF (%slot.1 == $gettok(%slot.emotes,2,32)) VAR %payout = %slotbet * 2
    IF (%slot.1 == $gettok(%slot.emotes,3,32)) VAR %payout = %slotbet * 3
    IF (%slot.1 == $gettok(%slot.emotes,4,32)) VAR %payout = %slotbet * 5
    IF (%slot.1 == $gettok(%slot.emotes,5,32)) VAR %payout = %slotbet * 10
    IF (%slot.1 == $gettok(%slot.emotes,6,32)) VAR %payout = %slotbet * 25
    IF (%slot.1 == $gettok(%slot.emotes,7,32)) VAR %payout = %slotbet * 50
    .timer.slotsym1 1 %slot.reel_1_speed $IIF(%slot.whispers == OFF,DESCRIBE %mychan,MSG $1)  ▌ %slot.1 ▌
    .timer.slotsym2 1 %slot.reel_2_speed $IIF(%slot.whispers == OFF,DESCRIBE %mychan,MSG $1)  ▌ %slot.1 ▌ %slot.2 ▌
    .timer.slotsym3 1 %slot.reel_3c_speed $IIF(%slot.whispers == OFF,DESCRIBE %mychan,MSG $1)  ▌ %slot.1 ▌ %slot.2 ▌ %slot.3 ▌ ::: You WON %payout %curname $+ , $1 $+ !!!  PogChamp
    IF (%slot.whispers == ON) .timer.slotwinner 1 %slot.reel_3c_speed MSG %mychan $1 just WON %payout %curname playing !slot! PogChamp
    .timer.slotpayout 1 %slot.reel_3c_speed slotwinner $1 %payout
  }
  ELSEIF (%slot.1 == %slot.2) {
    .timer.slotsym1 1 %slot.reel_1_speed $IIF(%slot.whispers == OFF,DESCRIBE %mychan,MSG $1)  ▌ %slot.1 ▌
    .timer.slotsym2 1 %slot.reel_2_speed $IIF(%slot.whispers == OFF,DESCRIBE %mychan,MSG $1)  ▌ %slot.1 ▌ %slot.2 ▌
    .timer.slotsym3 1 %slot.reel_3b_speed $IIF(%slot.whispers == OFF,DESCRIBE %mychan,MSG $1)  ▌ %slot.1 ▌ %slot.2 ▌ %slot.3 ▌ $replace(%slot.lose_msg,user,$1)
    .timer.slotstop 1 %slot.reel_3b_speed end_game
  }
  ELSE {
    .timer.slotsym1 1 %slot.reel_1_speed $IIF(%slot.whispers == OFF,DESCRIBE %mychan,MSG $1)  ▌ %slot.1 ▌
    .timer.slotsym2 1 %slot.reel_2_speed $IIF(%slot.whispers == OFF,DESCRIBE %mychan,MSG $1)  ▌ %slot.1 ▌ %slot.2 ▌
    .timer.slotsym3 1 %slot.reel_3a_speed $IIF(%slot.whispers == OFF,DESCRIBE %mychan,MSG $1)  ▌ %slot.1 ▌ %slot.2 ▌ %slot.3 ▌ $replace(%slot.lose_msg,user,$1)
    .timer.slotstop 1 %slot.reel_3a_speed end_game
  }
}

alias slotwinner {
  ADDPOINTS $1 $2
  WRITEINI slot.ini $1 Wins $calc($readini(slot.ini,$1,Wins) + 1)
  WRITEINI slot.ini $1 Winnings $calc($readini(slot.ini,$1,Winnings) + $2)
  end_game
}
