;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; VARIABLES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

/*
HEY!  LOOK HERE!  This is what you need to change in this script...

Change the %bj_minbet and %bj_maxbet to the minimum and maximum
amount of points that must be spent in order to use !blackjack.  The
%bj_cd variable is the per user cooldown time (in seconds) that a user
must wait before being able to use !blackjack again.

You will need to UNLOAD and RE-LOAD this script for any changes to the
variables below to take effect.  This can be done by pressing ALT-R in
mIRC > Select "View" > Select "blackjack.mrc" > Click on "File" > "Unload."
Then, click on "File" and "Load..." and select the blackjack.mrc file again.

Have fun!!!
*/

ON *:LOAD: {
  SET %bj_minbet 1
  SET %bj_maxbet 500
  SET %bj_cd 300
}

ON *:UNLOAD: { UNSET %bj_* }
ON *:CONNECT: { IF ($server == tmi.twitch.tv) UNSET %bj.* }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;; BLACKJACK GAME ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


ON $*:TEXT:/^!blackjack\s(on|off)/iS:#: {

  IF ($nick isop $chan) {
    IF ($2 == on) {
      IF (!%GAMES_BJ_ACTIVE) {
        SET %GAMES_BJ_ACTIVE On
        MSG $chan $twitch_name($nick) $+ , the BlackJack game is now enabled!  Type !blackjack for more info!  Have fun!  PogChamp
      }
      ELSE MSG $chan $twitch_name($nick) $+ , !blackjack is already enabled.  FailFish
    }
    ELSEIF ($2 == off) {
      IF (%GAMES_BJ_ACTIVE) {
        UNSET %GAMES_BJ_ACTIVE
        MSG $chan $twitch_name($nick) $+ , the BlackJack game is now disabled.
      }
      ELSE MSG $chan $twitch_name($nick) $+ , !blackjack is already disabled.  FailFish
    }
  }
}


ON $*:TEXT:/^!blackjack(\s|$)/iS:#: {

  IF (($($+(%,floodBJ.,$nick),2)) || (%bj.name) || (%ActiveGame) || ($isfile(roulbets.txt))) halt
  SET -u3 %floodBJ. $+ $nick On
  IF (!%GAMES_BJ_ACTIVE) {
    IF ((%floodBJ_ACTIVE) || ($($+(%,floodBJ_ACTIVE.,$nick),2))) halt
    SET -u15 %floodBJ_ACTIVE On
    SET -u120 %floodBJ_ACTIVE. $+ $nick On
    MSG $chan $twitch_name($nick) $+ , the BlackJack game is currently disabled.
    halt
  }
  ELSEIF ($2 isnum %bj_minbet - %bj_maxbet) {
    IF ($($+(%,BJ_CD.,$nick),2)) MSG $nick $twitch_name($nick) $+ , please wait for your cooldown to expire in $duration(%BJ_CD. [ $+ [ $nick ] ]) before trying to play BlackJack again.
    ELSEIF ($checkpoints($nick, $2) == false) MSG $chan $twitch_name($nick) $+ , you don't have enough %curname to play.  FailFish
    ELSE $start_blackjack($nick,$2)
  }
  ELSE {
    IF (%floodBJinfo) halt
    SET -u6 %floodBJinfo On
    MSG $chan Try your luck at a game of BlackJack in this channel.  It is an infinite decks game.  %botname always stands on 17 or higher.  Type "!blackjack $chr(91) $+ %bj_minbet $+ - $+ %bj_maxbet $+ $chr(93) $+ " to play. ▌ Example:  !blackjack %bj_maxbet
  }
}

alias start_blackjack {

  SET %bj.name $twitch_name($1)
  SET %bj.bet $floor($2)
  SET %ActiveGame
  REMOVEPOINTS %bj.name %bj.bet
  blackjacktimer
  MSG $nick %bj.name $+ , you have just spent %bj.bet %curname on a hand of BlackJack.  Good luck!  BloodTrail
  bjdeal
  IF ((( %bj.ccard1 == A ) && (( %bj.ccard2 == 10 ) || ( %bj.ccard2 == J ) || ( %bj.ccard2 == Q ) || ( %bj.ccard2 == K ))) || (( %bj.ccard2 == A ) && (( %bj.ccard1 == 10 ) || ( %bj.ccard1 == J ) || ( %bj.ccard1 == Q ) || ( %bj.ccard1 == K )))) VAR %bj.dealer yes
  IF (( %bj.hcard1 == A ) || ( %bj.hcard2 == A )) SET %bj.aceh On
  IF ((( %bj.hcard1 == A ) && (( %bj.hcard2 == 10 ) || ( %bj.hcard2 == J ) || ( %bj.hcard2 == Q ) || ( %bj.hcard2 == K ))) || (( %bj.hcard2 == A ) && (( %bj.hcard1 == 10 ) || ( %bj.hcard1 == J ) || ( %bj.hcard1 == Q ) || ( %bj.hcard1 == K )))) VAR %bj.player yes
  IF (%bj.player) && (%bj.dealer) {
    MSG $chan Both %bj.name and %botname have blackjack!  %bj.name gets their %bj.bet %curname back!
    ADDPOINTS %bj.name %bj.bet
    resetblackjack
  }
  IF (%bj.player) {
    VAR %bj.payout $floor($calc(%bj.bet * 2.5))
    ADDPOINTS %bj.name %bj.payout
    MSG $chan Blackjack!  %bj.name wins %bj.payout %curname $+ !  PogChamp
    resetblackjack
  }
  IF (%bj.dealer) {
    MSG $chan %botname has blackjack!  ▌  %bj.name loses their %bj.bet %curname wager!  :tf:
    resetblackjack
  }
  SET %bj.Ohands $+(%bj.name $+ 's hand:  $chr(91) $+ %bj.hcard1 $+ $chr(93) $chr(91) $+ %bj.hcard2 $+ $chr(93), $chr(32), ▌, $chr(32), $chr(32), %botname $+ 's hand:  $chr(91) $+ %bj.ccard1 $+ $chr(93) $chr(91) $+ ? $+ $chr(93), $chr(32), ▌, $chr(32) )
  IF (%bj.addh != 21) {
    IF ($checkpoints(%bj.name,$calc(%bj.bet * 2)) == true) {
      MSG $chan %bj.Ohands %bj.name $+ , do you want to !hit, !stand, or !double?
      SET %bj.double $calc(%bj.bet * 2)
    }
    ELSE MSG $chan %bj.Ohands %bj.name $+ , do you want to !hit or !stand?
  }
}


ON *:TEXT:!double:#: {

  IF (%bj.double) && ($nick == %bj.name) {
    REMOVEPOINTS %bj.name %bj.bet
    SET %bj.bet %bj.double
    hit
    SET %bj.ProcessHands $+(%bj.name hits:  $chr(91) $+ %bj.hcard3 $+ $chr(93)  ▌ Total is %bj.addh , $chr(32), ▌, $chr(32) )
    IF (%bj.addh > 21) {
      SET %bj.ProcessHands $+(%bj.ProcessHands, $chr(32), %bj.name loses!  :tf: )
      MSG $chan %bj.ProcessHands
      resetblackjack
    }
    ELSEIF (!%bj.aceh) && (%bj.addh <= 11) {
      SET %bj.addh $calc(%bj.addh + 10)
      SET %bj.ProcessHands $+(%bj.name hits:  $chr(91) $+ %bj.hcard3 $+ $chr(93)  ▌ Total is %bj.addh , $chr(32), ▌, $chr(32) )
    }
    stand
  }
}


ON *:TEXT:!hit*:#:{

  IF ($nick == %bj.name) {
    blackjacktimer
    UNSET %bj.double
    hit
    IF (!%bj.aceh) {
      IF (%bj.addh == 21) {
        SET %bj.ProcessHands $+(%bj.name hits:  $chr(91) $+ %bj.hcard3 $+ $chr(93)  ▌ Total is %bj.addh ▌, $chr(32) )
        SET %bj.ProcessStand $+(%bj.ProcessHands)
        stand
      }
      IF (%bj.addh > 21) {
        SET %bj.ProcessHands $+(%bj.name hits:  $chr(91) $+ %bj.hcard3 $+ $chr(93)  ▌ Total is %bj.addh ▌, $chr(32) )
        MSG $chan %bj.ProcessHands %bj.name loses!  :tf:
        resetblackjack
      }
      IF (%bj.addh < 21) {
        SET %bj.ProcessHands $+(%bj.name hits:  $chr(91) $+ %bj.hcard3 $+ $chr(93)  ▌ Total is %bj.addh ▌, $chr(32) )
      }
    }
    IF (%bj.aceh) {
      IF (%bj.addh == 21) {
        SET %bj.ProcessStand $+(%bj.name hits:  $chr(91) $+ %bj.hcard3 $+ $chr(93)  ▌ Total is %bj.addh ▌, $chr(32) )
        stand
      }
      IF (%bj.addh == 11) {
        SET %bj.addh $calc(%bj.addh + 10)
        SET %bj.ProcessStand $+(%bj.name hits:  $chr(91) $+ %bj.hcard3 $+ $chr(93)  ▌ Total is %bj.addh ▌, $chr(32) )
        stand
      }
      IF (%bj.addh < 11) {
        SET %bj.ProcessHands $+(%bj.name hits:  $chr(91) $+ %bj.hcard3 $+ $chr(93)  ▌ Total is %bj.addh or $calc(%bj.addh + 10) ▌, $chr(32) )
      }
      IF (%bj.addh isnum 12-20) {
        SET %bj.ProcessHands $+(%bj.name hits:  $chr(91) $+ %bj.hcard3 $+ $chr(93)  ▌ Total is %bj.addh ▌, $chr(32) )
      }
      IF (%bj.addh > 21) {
        SET %bj.ProcessHands $+(%bj.name hits:  $chr(91) $+ %bj.hcard3 $+ $chr(93)  ▌ Total is %bj.addh ▌, $chr(32) )
        MSG $chan %bj.ProcessHands %bj.name loses!  :tf:
        resetblackjack
      }
    }
    MSG $chan %bj.ProcessHands %bj.name $+ , !hit or !stand?  (you may type anything after !hit to bypass twitch flood protection)
  }
}


ON *:TEXT:!stand:#: { IF ($nick == %bj.name) stand }


alias bjdeal {
  SET %bj.hcard1 $rand(0,12)
  SET %bj.hcard2 $rand(0,12)
  SET %bj.ccard1 $rand(0,12)
  SET %bj.ccard2 $rand(0,12)
  SET %bj.addh $calc( %bj.hcard1 + %bj.hcard2 )
  SET %bj.addc $calc( %bj.ccard1 + %bj.ccard2 )
  IF ( %bj.hcard1 == 0 ) SET %bj.addh $calc(%bj.addh + 10)
  IF ( %bj.hcard2 == 0 ) SET %bj.addh $calc(%bj.addh + 10)
  IF ( %bj.ccard1 == 0 ) SET %bj.addc $calc(%bj.addc + 10)
  IF ( %bj.ccard2 == 0 ) SET %bj.addc $calc(%bj.addc + 10)
  IF ( %bj.hcard1 == 11 ) SET %bj.addh $calc(%bj.addh - 1)
  IF ( %bj.hcard2 == 11 ) SET %bj.addh $calc(%bj.addh - 1)
  IF ( %bj.ccard1 == 11 ) SET %bj.addc $calc(%bj.addc - 1)
  IF ( %bj.ccard2 == 11 ) SET %bj.addc $calc(%bj.addc - 1)
  IF ( %bj.hcard1 == 12 ) SET %bj.addh $calc(%bj.addh - 2)
  IF ( %bj.hcard2 == 12 ) SET %bj.addh $calc(%bj.addh - 2)
  IF ( %bj.ccard1 == 12 ) SET %bj.addc $calc(%bj.addc - 2)
  IF ( %bj.ccard2 == 12 ) SET %bj.addc $calc(%bj.addc - 2)
  IF ( %bj.hcard1 == 1 ) { SET %bj.hcard1 A | SET %bj.aceh On }
  IF ( %bj.hcard2 == 1 ) { SET %bj.hcard2 A | SET %bj.aceh On }
  IF ( %bj.ccard1 == 1 ) { SET %bj.ccard1 A | SET %bj.acec On }
  IF ( %bj.ccard2 == 1 ) { SET %bj.ccard2 A | SET %bj.acec On }
  IF ( %bj.hcard1 == 0 ) SET %bj.hcard1 J
  IF ( %bj.hcard2 == 0 ) SET %bj.hcard2 J
  IF ( %bj.ccard1 == 0 ) SET %bj.ccard1 J
  IF ( %bj.ccard2 == 0 ) SET %bj.ccard2 J
  IF ( %bj.hcard1 == 11 ) SET %bj.hcard1 Q
  IF ( %bj.hcard2 == 11 ) SET %bj.hcard2 Q
  IF ( %bj.ccard1 == 11 ) SET %bj.ccard1 Q
  IF ( %bj.ccard2 == 11 ) SET %bj.ccard2 Q
  IF ( %bj.hcard1 == 12 ) SET %bj.hcard1 K
  IF ( %bj.hcard2 == 12 ) SET %bj.hcard2 K
  IF ( %bj.ccard1 == 12 ) SET %bj.ccard1 K
  IF ( %bj.ccard2 == 12 ) SET %bj.ccard2 K
  return
}

alias hit {
  SET %bj.hcard3 $rand(0,12)
  SET %bj.addh $calc( %bj.addh + %bj.hcard3 )
  IF ( %bj.hcard3 == 0 ) SET %bj.addh $calc(%bj.addh + 10)
  IF ( %bj.hcard3 == 11 ) SET %bj.addh $calc(%bj.addh - 1)
  IF ( %bj.hcard3 == 12 ) SET %bj.addh $calc(%bj.addh - 2)
  IF ( %bj.hcard3 == 1 ) { SET %bj.hcard3 A | /set %bj.aceh 0 }
  IF ( %bj.hcard3 == 0 ) SET %bj.hcard3 J
  IF ( %bj.hcard3 == 11 ) SET %bj.hcard3 Q
  IF ( %bj.hcard3 == 12 ) SET %bj.hcard3 K
}

alias stand {
  IF (%bj.aceh) && (%bj.addh <= 11) SET %bj.addh $calc(%bj.addh + 10)
  SET %bj.ProcessStand $+(%bj.ProcessStand, $chr(32), %botname $+ 's hand:  $chr(91) $+ %bj.ccard1 $+ $chr(93)  $chr(91) $+ %bj.ccard2 $+ $chr(93)  ▌ $chr(32))
  GOTO bjfinish
  :hit
  SET %bj.ccard3 $rand(0,12)
  SET %bj.addc $calc( %bj.addc + %bj.ccard3 )
  IF ( %bj.ccard3 == 0 ) SET %bj.addc $calc(%bj.addc + 10)
  IF ( %bj.ccard3 == 11 ) SET %bj.addc $calc(%bj.addc - 1)
  IF ( %bj.ccard3 == 12 ) SET %bj.addc $calc(%bj.addc - 2)
  IF ( %bj.ccard3 == 1 ) { SET %bj.ccard3 A | SET %bj.acec On }
  IF ( %bj.ccard3 == 0 ) SET %bj.ccard3 J
  IF ( %bj.ccard3 == 11 ) SET %bj.ccard3 Q
  IF ( %bj.ccard3 == 12 ) SET %bj.ccard3 K

  SET %bj.ProcessStand $+( $chr(32), %bj.ProcessStand, $chr(32), %botname draws  $chr(91) $+ %bj.ccard3 $+ $chr(93)  ▌, $chr(32) )
  GOTO bjfinish
  :bjfinish

  IF (%bj.addc > 21) {
    IF (%bj.double) MSG $chan %bj.ProcessHands %bj.ProcessStand %botname busts!  ▌  %bj.name wins $calc(%bj.bet * 2) %curname $+ !  PogChamp
    IF (!%bj.double) MSG $chan %bj.ProcessStand %botname busts!  ▌  %bj.name wins $calc(%bj.bet * 2) %curname $+ !  PogChamp
    ADDPOINTS %bj.name $calc(%bj.bet * 2)
    resetblackjack
  }
  IF (!%bj.acec) {
    IF (%bj.addc < 17) GOTO hit
    IF (%bj.addc >= 17) {
      SET %bj.ProcessStand $+(%bj.ProcessStand, $chr(32), %botname Stands on %bj.addc ▌, $chr(32) )
      IF (%bj.addc > %bj.addh) {
        IF (%bj.double) MSG $chan %bj.ProcessHands %bj.ProcessStand %botname wins!  :tf:
        IF (!%bj.double) MSG $chan %bj.ProcessStand %botname wins!  :tf:
        resetblackjack
      }
      IF (%bj.addc == %bj.addh) {
        IF (%bj.double) MSG $chan %bj.ProcessHands %bj.ProcessStand Push  ▌  %bj.name wins their %bj.bet %curname back!
        IF (!%bj.double) MSG $chan %bj.ProcessStand Push  ▌  %bj.name wins back their %bj.bet %curname $+ !
        ADDPOINTS %bj.name %bj.bet
        resetblackjack
      }
      IF (%bj.addc < %bj.addh) {
        IF (%bj.double) MSG $chan %bj.ProcessHands %bj.ProcessStand %bj.name wins $calc(%bj.bet * 2) %curname $+ !  PogChamp
        IF (!%bj.double) MSG $chan %bj.ProcessStand %bj.name wins $calc(%bj.bet * 2) %curname $+ !  PogChamp
        ADDPOINTS %bj.name $calc(%bj.bet * 2)
        resetblackjack
      }
    }
  }
  IF (%bj.acec) {
    IF (%bj.addc isnum 7-11) SET %bj.addc $calc(%bj.addc + 10)
    IF (%bj.addc < 17) GOTO hit
    IF (%bj.addc >= 17) {
      %bj.ProcessStand = $+(%bj.ProcessStand, $chr(32), %botname Stands on %bj.addc ▌, $chr(32) )
      IF (%bj.addc > %bj.addh) {
        IF (%bj.double) MSG $chan %bj.ProcessHands %bj.ProcessStand %botname wins!  :tf:
        IF (!%bj.double) MSG $chan %bj.ProcessStand %botname wins!  :tf:
        resetblackjack
      }
      IF (%bj.addc == %bj.addh) {
        IF (%bj.double) MSG $chan %bj.ProcessHands %bj.ProcessStand Push  ▌  %bj.name wins their %bj.bet back!
        IF (!%bj.double) MSG $chan %bj.ProcessStand Push  ▌  %bj.name wins back their %bj.bet points!
        ADDPOINTS %bj.name %bj.bet
        resetblackjack
      }
      IF (%bj.addc < %bj.addh) {
        IF (%bj.double) MSG $chan %bj.ProcessHands %bj.ProcessStand %bj.name wins $calc(%bj.bet * 2) points!  PogChamp
        IF (!%bj.double) MSG $chan %bj.ProcessStand %bj.name wins $calc(%bj.bet * 2) points!  PogChamp
        ADDPOINTS %bj.name $calc(%bj.bet * 2)
        resetblackjack
      }
    }
  }
}


alias blackjacktimer {
  .timer.blackjack.1 1 15 MSG %mychan %bj.name $+ , HURRY UP!  Finish your game of BlackJack or you will automatically lose!  RageFace
  .timer.blackjack.2 1 25 MSG %mychan %bj.name $+ , you took too long to play BlackJack!  So you GET NOTHING!  YOU LOSE!  Good Day, Sir!  SwiftRage
  .timer.blackjack.3 1 25 resetblackjack
}


alias resetblackjack {
  SET -ze %BJ_CD. $+ $nick %bj_cd
  IF ($timer(.blackjack.3)) .timer.blackjack.* off
  UNSET %bj.*
  UNSET %ActiveGame
  halt
}
