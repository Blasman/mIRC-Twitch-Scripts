;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BLASBOT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;; TWITCH.TV/BLASMAN13 ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; JACKPOT VERSION 2.1.0.8 ;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

alias jackpot_version return 2.1.0.8

ON *:LOAD: jackpot_setup

ON *:UNLOAD: UNSET %jackpot.*

alias jackpot_setup {
  IF ($blasbot_version < 1.0.0.5) {
    $dialog(jackpot_important,jackpot_important)
    url -m https://github.com/Blasman/mIRC-Twitch-Scripts/wiki/Script-Documentation
    unload -rs jackpot.v2.mrc
    halt
  }
  IF (!%jackpot.odds) SET %jackpot.odds 1.234
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
  IF (!%jackpot.sound_livecheck) SET %jackpot.sound_livecheck On
  IF (!%jackpot.myjackpot) SET %jackpot.myjackpot On
  IF (!%jackpot.stats) SET %jackpot.stats On
  IF (!%jackpot.record) SET %jackpot.record On
  IF (!%jackpot.addicts) SET %jackpot.addicts On
  IF (!%jackpot.winners) SET %jackpot.winners On
  IF (!%jackpot.netwinners) SET %jackpot.netwinners On
}

dialog jackpot_important {
  title "IMPORTANT!"
  size -1 -1 200 60
  option dbu
  text "You are NOT running the latest version of blasbot.mrc from Blasman's GitHub. This script will NOT work for you until you install it! Setup will exit once you click Okay.", 1, 8 8 180 30
  button "Okay", 3, 80 45 40 12, ok
}

menu menubar,channel,status {
  !JackPot
  .$style(2) Version $jackpot_version:$null
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
  .EXTRA COMMANDS
  ..'!myjackpot' is $IIF(%jackpot.myjackpot == On,ON,OFF) [click to $IIF(%jackpot.myjackpot == On,disable,enable) $+ ]:jp_myjackpot
  ..'!jackpot stats' is $IIF(%jackpot.stats == On,ON,OFF) [click to $IIF(%jackpot.stats == On,disable,enable) $+ ]:jp_stats
  ..'!jackpot record' is $IIF(%jackpot.record == On,ON,OFF) [click to $IIF(%jackpot.record == On,disable,enable) $+ ]:jp_record
  ..'!jackpot addicts' is $IIF(%jackpot.addicts == On,ON,OFF) [click to $IIF(%jackpot.addicts == On,disable,enable) $+ ]:jp_addicts
  ..'!jackpot winners' is $IIF(%jackpot.winners == On,ON,OFF) [click to $IIF(%jackpot.winners == On,disable,enable) $+ ]:jp_winners
  ..'!jackpot netwinners' is $IIF(%jackpot.netwinners == On,ON,OFF) [click to $IIF(%jackpot.netwinners == On,disable,enable) $+ ]:jp_netwinners
  .WINNING SOUND EFFECT
  ..MP3 FILE $chr(91) $+ $IIF(%jackpot.sound,$remove($gettok(%jackpot.sound,$numtok(%jackpot.sound,47),47),$chr(34)),OFF) $+ $chr(93) [click to change]:jp_sound
  ..ONLY PLAY SOUND WHEN STREAM IS LIVE IS $IIF(%jackpot.sound_livecheck == On,ON,OFF) [click to $IIF(%jackpot.sound_livecheck == On,disable,enable) $+ ]:jp_sound_livecheck
  .COST $chr(91) $+ %jackpot.bet %curname $+ $chr(93):jp_cost
  .COOLDOWN $chr(91) $+ %jackpot.cd seconds $+ $chr(93):jp_cooldown
  .FRESH POT $chr(91) $+ %jackpot.newpot %curname $+ $chr(93):jp_newpot
  .ODDS OF WINNING $chr(91) $+ %jackpot.odds $+ $chr(37) $+ $chr(93):jp_odds
  .CURRENT POT $chr(91) $+ $readini(jackpot.ini,@Stats,Jackpot) %curname $+ $chr(93):jp_currentpot
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
  $input(How much %curname will it cost to play !jackpot?,eof,Required Input,%jackpot.bet)
  IF ($! isnum) SET %jackpot.bet $floor($!)
  ELSEIF ($! == $false) return
  ELSE { ECHO You need to input a numerical value for the cost to play !jackpot! | GOTO cost }
}

alias -l jp_cooldown {
  :cooldown
  $input(What will be the cooldown in seconds per user for !jackpot?,eof,Required Input,%jackpot.cd)
  IF ($! isnum) SET %jackpot.cd $floor($!)
  ELSEIF ($! == $false) return
  ELSE { ECHO You need to input a numerical value for the per-user cooldown on !jackpot! | GOTO cooldown }
}

alias -l jp_emotes {
  :emotes
  $input(Input at LEAST two emotes that you would like to use for !jackpot separated by spaces:,eof,Required Input,%jackpot.emotes)
  IF ($!) {
    VAR %emotes $!
    IF ($numtok(%emotes,32) < 2) GOTO emotes
    SET %jackpot.emotes %emotes
  }
  ELSEIF ($! == $false) return
  ELSE { ECHO You need to input at least two emotes for !jackpot! | GOTO emotes }
}

alias -l jp_newpot {
  :startamount
  $input(What will be the staring amount of %curname for !jackpot?,eof,Required Input,%jackpot.newpot)
  IF ($! isnum) {
    SET %jackpot.newpot $floor($!)
    IF (!$readini(jackpot.ini,@Stats,Jackpot)) WRITEINI jackpot.ini @Stats Jackpot %jackpot.newpot
  }
  ELSEIF ($! == $false) return
  ELSE { ECHO You need to input a numerical value for the starting amount on !jackpot! | GOTO startamount }
}

alias -l jp_odds {
  :odds
  $input(What will be the percentage odds of winning !jackpot? $chr(40) $+ up to three decimal places $+ $chr(41),eof,Required Input,%jackpot.odds)
  IF ($remove($!,$chr(37)) isnum) SET %jackpot.odds $round($!,3)
  ELSEIF ($! == $false) return
  ELSE { ECHO You need to input a numerical value for the odds of winning on !jackpot! | GOTO odds }
}

alias -l jp_currentpot {
  :currentpot
  $input(Enter the CURRENT $chr(40) $+ NOT the starting $+ $chr(41) pot for !jackpot,eof,Required Input,$readini(jackpot.ini,@Stats,Jackpot))
  IF ($! isnum) WRITEINI jackpot.ini @Stats Jackpot $floor($!)
  ELSEIF ($! == $false) return
  ELSE { ECHO You need to input a numerical value for the current pot on !jackpot! | GOTO currentpot }
}

alias -l jp_whispers {
  IF (%jackpot.whispers == Off) SET %jackpot.whispers On
  ELSE SET %jackpot.whispers Off
}

alias -l jp_sound_livecheck {
  IF (%jackpot.sound_livecheck == Off) SET %jackpot.sound_livecheck On
  ELSE SET %jackpot.sound_livecheck Off
}

alias -l jp_myjackpot {
  IF (%jackpot.myjackpot == Off) SET %jackpot.myjackpot On
  ELSE SET %jackpot.myjackpot Off
}

alias -l jp_stats {
  IF (%jackpot.stats == Off) SET %jackpot.stats On
  ELSE SET %jackpot.stats Off
}

alias -l jp_record {
  IF (%jackpot.record == Off) SET %jackpot.record On
  ELSE SET %jackpot.record Off
}

alias -l jp_addicts {
  IF (%jackpot.addicts == Off) SET %jackpot.addicts On
  ELSE SET %jackpot.addicts Off
}

alias -l jp_winners {
  IF (%jackpot.winners == Off) SET %jackpot.winners On
  ELSE SET %jackpot.winners Off
}

alias -l jp_netwinners {
  IF (%jackpot.netwinners == Off) SET %jackpot.netwinners On
  ELSE SET %jackpot.netwinners Off
}

alias jp_losemsg {
  $input(Enter the LOSING message $chr(40) $+ if any $+ $chr(41) that will appear on the third reel. Use the word "user" $chr(40) $+ without qutoes $+ $chr(41) where you want the users name to be displayed:,eof,Required Input,%jackpot.lose_msg)
  IF ($! == $false) return
  ELSE SET %jackpot.lose_msg $!
}

alias jp_pullmsg {
  $input(Enter the message that will appear when pulling the jackpot lever. Use the word "user" $chr(40) $+ without qutoes $+ $chr(41) where you want the users name to be displayed and the word "jptotal" $chr(40) $+ without qutoes $+ $chr(41) where you want the current jackpot total to be displayed:,eof,Required Input,%jackpot.pull_msg)
  IF ($! == $false) return
  ELSE SET %jackpot.pull_msg $!
}

alias jp_reelspeed_1 {
  :reelspeed
  $input(Enter the number of seconds that the first jackpot reel will appear after the lever pull message:,eof,Required Input,%jackpot.reel_1_speed)
  IF ($regex($!,^\d+$)) SET %jackpot.reel_1_speed $!
  ELSEIF ($! == $false) return
  ELSE { ECHO You need to use a positive whole number. | GOTO reelspeed }
}

alias jp_reelspeed_2 {
  :reelspeed
  $input(Enter the number of seconds that the second jackpot reel will appear after the lever pull message:,eof,Required Input,%jackpot.reel_2_speed)
  IF ($regex($!,^\d+$)) SET %jackpot.reel_2_speed $!
  ELSEIF ($! == $false) return
  ELSE { ECHO You need to use a positive whole number. | GOTO reelspeed }
}

alias jp_reelspeed_3a {
  :reelspeed
  $input(Enter the number of seconds that the third losing jackpot reel will appear after the lever pull message when the first two reels are NOT identical:,eof,Required Input,%jackpot.reel_3a_speed)
  IF ($regex($!,^\d+$)) SET %jackpot.reel_3a_speed $!
  ELSEIF ($! == $false) return
  ELSE { ECHO You need to use a positive whole number. | GOTO reelspeed }
}

alias jp_reelspeed_3b {
  :reelspeed
  $input(Enter the number of seconds that the third losing jackpot reel will appear after the lever pull message when the first two reels ARE identical:,eof,Required Input,%jackpot.reel_3b_speed)
  IF ($regex($!,^\d+$)) SET %jackpot.reel_3b_speed $!
  ELSEIF ($! == $false) return
  ELSE { ECHO You need to use a positive whole number. | GOTO reelspeed }
}

alias jp_reelspeed_3c {
  :reelspeed
  $input(Enter the number of seconds that the third WINNING jackpot reel will appear after the lever pull message:,eof,Required Input,%jackpot.reel_3c_speed)
  IF ($regex($!,^\d+$)) SET %jackpot.reel_3c_speed $!
  ELSEIF ($! == $false) return
  ELSE { ECHO You need to use a positive whole number. | GOTO reelspeed }
}

alias jp_sound {
  :sound
  $input(Enter the path and filename to the MP3 file that you wish to use when a user wins the jackpot:,eof,Required Input,$noqt(%jackpot.sound))
  IF ($right($!,4) == .mp3) {
    IF ($isfile($qt($!))) SET %jackpot.sound $qt($!)
    ELSE { ECHO File not found! Please check that the path and filename are correct! | GOTO sound }
  }
  ELSEIF (!$!) UNSET %jackpot.sound
  ELSEIF ($! == $false) return
  ELSE { ECHO You need to specify an .MP3 file for the jackpot win sound! | GOTO sound }
}

ON $*:TEXT:/^!jackpot\s(on|off|set|bet|cd|newpot|odds|emotes|whispers|setup)/iS:%mychan: {
  IF ($ModCheck) {
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
    ELSEIF (($2 == set) && ($3 isnum)) {
      SET %jackpot_pot $floor($3)
      MSG $chan The !jackpot has been manually set to %jackpot_pot %curname $+ !
    }
    ELSEIF (($2 == bet) && ($3 isnum)) {
      SET %jackpot.bet $floor($3)
      MSG $chan The amount of %curname to play !jackpot has been changed to %jackpot.bet $+ !
    }
    ELSEIF (($2 == cd) && ($3 isnum)) {
      SET %jackpot.cd $floor($3)
      MSG $chan The cooldown time for !jackpot has been changed to %jackpot.cd seconds!
    }
    ELSEIF (($2 == newpot) && ($3 isnum)) {
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
  IF ((%jackpot.stats == On) && (!%CD_JACKPOT_STATS)) {
    SET -eu10 %CD_JACKPOT_STATS On
    IF (!$readini(jackpot.ini,@Stats,Last_Winner)) MSG $chan Current !jackpot: $bytes($readini(jackpot.ini,@Stats,Jackpot),b) %curname $+ . Nobody has won a !jackpot yet!
    ELSE MSG $chan Current !jackpot: $bytes($readini(jackpot.ini,@Stats,Jackpot),b) %curname $+ . ▌ Last Winner was $readini(jackpot.ini,@Stats,Last_Winner) who won $bytes($readini(jackpot.ini,@Stats,Last_Jackpot),b) %curname on $readini(jackpot.ini,@Stats,Last_Winner_Time) $+ . ▌ Total Games Played: $jackpot_totalgames by $jackpot_uniqueplayers different players. ▌ Number of Wins: $bytes($readini(jackpot.ini,@Stats,Total_Winners),b) ▌ Total Payouts: $bytes($readini(jackpot.ini,@Stats,Total_Winnings),b) %curname $+ .
  }
}

alias jackpot_totalgames {
  VAR %x 1, %y 1
  WHILE $ini(jackpot.ini,%x) {
    VAR %y $calc($readini(jackpot.ini,$v1,Games) + %y)
    INC %x
  }
  RETURN $bytes(%y,b)
}

alias jackpot_uniqueplayers {
  VAR %x 1
  WHILE ($ini(jackpot.ini,%x)) INC %x
  RETURN $bytes($calc(%x - 1),b)
}

ON $*:TEXT:/^!jackpot(\s)?record$/iS:%mychan: {
  IF ((%jackpot.record == On) && (!%CD_JACKPOT_RECORD) {
    SET -eu10 %CD_JACKPOT_RECORD On
    IF (!$readini(jackpot.ini,@Stats,Record_Name)) MSG $chan Nobody has won a !jackpot yet!
    ELSE MSG $chan The largest !jackpot ever won was for $bytes($readini(jackpot.ini,@Stats,Record_Amount),b) %curname by $readini(jackpot.ini,@Stats,Record_Name) on $readini(jackpot.ini,@Stats,Record_Date) $+ . PogChamp
  }
}

ON $*:TEXT:/^!myjackpot(\s@?\w+)?$/iS:%mychan: {
  IF (%jackpot.myjackpot == On) {
    IF ($ModCheck) {
      VAR %user $IIF($2,$remove($2,@),$nick)
      IF ($ini(jackpot.ini,%user) != $null) {
        MSG $chan Jackpot Stats for $twitch_name(%user) ▌ Games Played: $bytes($readini(jackpot.ini,%user,Games),b) ▌ Wins: $bytes($readini(jackpot.ini,%user,Wins),b) ▌ Winnings: $bytes($readini(jackpot.ini,%user,Winnings),b) ▌ Losses: $bytes($readini(jackpot.ini,%user,Losses),b) ▌ Net Winnings: $bytes($calc($readini(jackpot.ini,%user,Winnings) - $readini(jackpot.ini,%user,Losses)),b)
      }
      ELSE MSG $chan %user has never played a game of !jackpot!
    }
    ELSEIF ((!$($+(%,myjackpot_CD.,$nick),2)) && (!$2)) {
      SET -eu30 %myjackpot_CD. $+ $nick On
      IF ($ini(jackpot.ini,$nick) != $null) {
        MSG $chan Jackpot Stats for $nick ▌ Games Played: $bytes($readini(jackpot.ini,$nick,Games),b) ▌ Wins: $bytes($readini(jackpot.ini,$nick,Wins),b) ▌ Winnings: $bytes($readini(jackpot.ini,$nick,Winnings),b) ▌ Losses: $bytes($readini(jackpot.ini,$nick,Losses),b) ▌ Net Winnings: $bytes($calc($readini(jackpot.ini,$nick,Winnings) - $readini(jackpot.ini,$nick,Losses)),b)
      }
      ELSE MSG $chan $nick $+ , you've never played !jackpot!
    }
  }
}

ON $*:TEXT:/^!jackpot(\s)?addicts$/iS:%mychan: {
  IF ((%jackpot.addicts == On) && (!%CD_jackpotaddicts)) {
    SET -eu10 %CD_jackpotaddicts On
    window -h @. | var %i 1
    WHILE $ini(jackpot.ini,%i) {
      aline @. $v1 $readini(jackpot.ini,$v1,Games)
      INC %i
    }
    filter -cetuww 2 32 @. @.
    VAR %i 1 | while %i <= 10 {
      tokenize 32 $line(@.,%i)
      VAR %name $chr(35) $+ %i $1 $chr(40) $+ $2 $+ $chr(41) -
      VAR %list $addtok(%list, %name, 32)
      INC %i
    }
    MSG $chan Most !Jackpot Games Played: $left(%list, -1)
    WINDOW -c @.
  }
}

ON $*:TEXT:/^!jackpot(\s)?winners$/iS:%mychan: {
  IF ((%jackpot.winners == On) && (!%CD_jackpotwinners)) {
    SET -eu10 %CD_jackpotwinners On
    window -h @. | var %i 1
    WHILE $ini(jackpot.ini,%i) {
      aline @. $v1 $readini(jackpot.ini,$v1,Winnings)
      INC %i
    }
    filter -cetuww 2 32 @. @.
    VAR %i 1 | while %i <= 10 {
      tokenize 32 $line(@.,%i)
      VAR %name $chr(35) $+ %i $1 $chr(40) $+ $bytes($2,b) $+ $chr(41) -
      VAR %list $addtok(%list, %name, 32)
      INC %i
    }
    MSG $chan !Jackpot's Biggest Winners: $left(%list, -1)
    WINDOW -c @.
  }
}

ON $*:TEXT:/^!jackpot(\s)?netwinners$/iS:%mychan: {
  IF ((%jackpot.netwinners == On) && (!%CD_jackpotnetwinners)) {
    SET -eu10 %CD_jackpotnetwinners On
    window -h @. | var %i 1
    WHILE $ini(jackpot.ini,%i) {
      VAR %nick $v1
      aline @. %nick $calc($readini(jackpot.ini,%nick,Winnings) - $readini(jackpot.ini,%nick,Losses))
      INC %i
    }
    filter -cetuww 2 32 @. @.
    VAR %i 1 | while %i <= 10 {
      tokenize 32 $line(@.,%i)
      VAR %name $chr(35) $+ %i $1 $chr(40) $+ $bytes($2,b) $+ $chr(41) -
      VAR %list $addtok(%list, %name, 32)
      INC %i
    }
    MSG $chan !Jackpot's Biggest NET Winners: $left(%list, -1)
    WINDOW -c @.
  }
}

ON $*:TEXT:/^!jackpot$/iS:%mychan: {
  IF ((%ActiveGame == $nick $+ .jackpot) || ($istok(%queue, $nick $+ .jackpot,32))) halt
  ELSEIF (!%GAMES_JACKPOT_ACTIVE) {
    IF ((%CD_JACKPOT_ACTIVE) || ($($+(%,CD_JACKPOT_ACTIVE.,$nick),2))) halt
    SET -eu10 %CD_JACKPOT_ACTIVE On
    SET -eu120 %CD_JACKPOT_ACTIVE. $+ $nick On
    MSG $chan $nick $+ , the !jackpot game is currently disabled.
  }
  ELSEIF ($timer(.JACKPOT. $+ $nick)) {
    IF ($($+(%,CD_JACKPOT_CD.,$nick),2)) halt
    SET -eu180 %CD_JACKPOT_CD. $+ $nick On
    MSG $nick Be patient, $nick $+ !  You still have $duration($timer(.JACKPOT. $+ $nick).secs) left in your !jackpot cooldown.
  }
  ELSEIF ($checkpoints($nick, %jackpot.bet) == false) {
    IF ($($+(%,CD_JACKPOT_CHECKPOINTS.,$nick),2)) halt
    SET -eu10 %CD_JACKPOT_CHECKPOINTS. $+ $nick On
    MSG $chan $nick $+ , you do not have $bytes(%jackpot.bet,b) %curname to play !jackpot FailFish
  }
  ELSE {
    REMOVEPOINTS $nick %jackpot.bet
    IF (%ActiveGame) SET %queue %queue $nick $+ .jackpot
    ELSE play_jackpot $nick
  }
}

alias play_jackpot {
  ; PLAY THE JACKPOT AND GENERATE REELS
  SET %ActiveGame $1 $+ .jackpot
  .timer.JACKPOT. $+ $1 1 %jackpot.cd MSG $1 $1 $+ , your !jackpot cooldown has expired. Feel free to play again. BloodTrail
  WRITEINI jackpot.ini @Stats Jackpot $calc($readini(jackpot.ini,@Stats,Jackpot) + %jackpot.bet)
  WRITEINI jackpot.ini $1 Games $calc($readini(jackpot.ini,$1,Games) + 1)
  WRITEINI jackpot.ini $1 Losses $calc($readini(jackpot.ini,$1,Losses) + %jackpot.bet)
  IF ($readini(jackpot.ini,$1,Wins) == $null) WRITEINI jackpot.ini $1 Wins 0
  IF ($readini(jackpot.ini,$1,Winnings) == $null) WRITEINI jackpot.ini $1 Winnings 0
  IF (%jackpot.whispers == OFF) {
    MSG $1 $1 $+ , you spent %jackpot.bet %curname on !jackpot.
    MSG %mychan $replace($replace(%jackpot.pull_msg,user,$1),jptotal,$bytes($readini(jackpot.ini,@Stats,Jackpot),b) %curname)
  }
  ELSE MSG $1 $1 $+ , you spent %jackpot.bet %curname on !jackpot. [Current Jackpot: $bytes($readini(jackpot.ini,@Stats,Jackpot),b) %curname $+ ]
  VAR %jackpot.num.emotes = $numtok(%jackpot.emotes,32)
  IF ($rand(1,100000) isnum 1 - $calc(%jackpot.odds * 1000)) {
    VAR %jackpot $bytes($readini(jackpot.ini,@Stats,Jackpot),b)
    VAR %x = $rand(1,%jackpot.num.emotes)
    VAR %reel.1 $gettok(%jackpot.emotes,%x,32)
    VAR %reel.2 $gettok(%jackpot.emotes,%x,32)
    VAR %reel.3 $gettok(%jackpot.emotes,%x,32)
    .timer.jackpot_01 1 %jackpot.reel_1_speed $IIF(%jackpot.whispers == OFF,DESCRIBE %mychan,MSG $1)  ▌ %reel.1 ▌
    .timer.jackpot_02 1 %jackpot.reel_2_speed $IIF(%jackpot.whispers == OFF,DESCRIBE %mychan,MSG $1)  ▌ %reel.1 ▌ %reel.2 ▌
    .timer.jackpot_03 1 %jackpot.reel_3c_speed $IIF(%jackpot.whispers == OFF,DESCRIBE %mychan,MSG $1)  ▌ %reel.1 ▌ %reel.2 ▌ %reel.3 ▌ ::: You Won %jackpot %curname $+ , $1 $+ ! Congratulations! PogChamp
    IF ((%jackpot.sound) && (((%jackpot.sound_livecheck == On) && ($livecheck(%streamer))) || (%jackpot.sound_livecheck == Off))) .timer.jackpot_04 1 %jackpot.reel_3c_speed SPLAY -pq %jackpot.sound
    .timer.jackpotwinner1 1 $calc(%jackpot.reel_3c_speed +1) MSG %mychan KAPOW KAPOW KAPOW OMG!!! JACKPOT!!! $1 just won %jackpot %curname $+ !!!  KAPOW KAPOW KAPOW
    .timer.jackpotwinner2 1 $calc(%jackpot.reel_3c_speed +2) MSG %mychan KAPOW KAPOW KAPOW OMG!!! JACKPOT!!! $1 just won %jackpot %curname $+ !!!  KAPOW KAPOW KAPOW
    .timer.jackpotwinner3 1 $calc(%jackpot.reel_3c_speed +3) MSG %mychan KAPOW KAPOW KAPOW OMG!!! JACKPOT!!! $1 just won %jackpot %curname $+ !!!  KAPOW KAPOW KAPOW
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
  WRITEINI jackpot.ini $1 Winnings $calc($readini(jackpot.ini,$1,Winnings) + $readini(jackpot.ini,@Stats,Jackpot))
  WRITEINI jackpot.ini @Stats Jackpot %jackpot.newpot
  end_game
}
