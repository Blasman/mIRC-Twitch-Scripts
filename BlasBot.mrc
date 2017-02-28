;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BLASBOT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;; CREATED BY BLASMAN13 ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;; TWITCH.TV/BLASMAN13 ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;; CORE MIRC SCRIPT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;; VERSION 1.0.0.6 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

/*
This is the main script that sets commonly used variables and contains
commonly used aliases for many of the other scripts found on my GitHub
at https://github.com/Blasman/mIRC-Twitch-Scripts

When first loading this script, you will have to enter some info in input
boxes that will appear.  If you change any of this info or enter it
incorrectly, you will need to re-run the setup.  You can re-run the setup
by re-loading the script, or by typing /blasbot_setup in mIRC.
*/

alias blasbot_version return 1.0.0.6

menu menubar,channel,status {
  BlasBot
  .$style(2) Version $blasbot_version:$null
  .$style(2) Created by Blasman13:$null
  .Visit Twitch.TV/Blasman13:URL -n https://twitch.tv/Blasman13
  .Visit GitHub:URL -n https://github.com/Blasman/mIRC-Twitch-Scripts
  $chr(36) $+ $chr(36) $+ $chr(36) CLICK HERE TO DONATE $chr(36) $+ $chr(36) $+ $chr(36):URL -n https://twitch.streamlabs.com/blasman13
}

ON *:LOAD: blasbot_setup

ON *:UNLOAD: {
  UNSET %CurrencyDB_path
  UNSET %EditorsDB_path
  UNSET %ExternalSubDB_path
  UNSET %GameWispSubDB_path
  UNSET %TwitchSubDB_path
  UNSET %RegularsDB_path
  UNSET %AnkhBot_CurrencyDB
  UNSET %AnkhBot_EditorsDB
  UNSET %AnkhBot_ExternalSubDB
  UNSET %AnkhBot_GameWispSubDB
  UNSET %AnkhBot_TwitchSubDB
  UNSET %AnkhBot_RegularsDB
  UNSET %streamer
  UNSET %curname
  UNSET %mychan
  UNSET %TwitchID
  UNSET %botname
}

ON *:START: {
  SET %AnkhBot_CurrencyDB $sqlite_open(%CurrencyDB_path)
  SET %AnkhBot_EditorsDB $sqlite_open(%EditorsDB_path)
  SET %AnkhBot_ExternalSubDB $sqlite_open(%ExternalSubDB_path)
  SET %AnkhBot_GameWispSubDB $sqlite_open(%GameWispSubDB_path)
  SET %AnkhBot_TwitchSubDB $sqlite_open(%TwitchSubDB_path)
  SET %AnkhBot_RegularsDB $sqlite_open(%RegularsDB_path)
  IF (!$hget(bot)) HMAKE bot
  IF (!$hget(displaynames)) {
    IF ($script(hosts.mrc)) {
      HMAKE displaynames
      IF ($file(displaynames.htb)) HLOAD displaynames displaynames.htb
    }
  }
  UNSET %ActiveGame
}

ON *:EXIT: IF ($hget(displaynames)) HSAVE -o displaynames displaynames.htb

ON $*:TEXT:/^!games\s(on|off)$/iS:%mychan: {
  IF ($ModCheck) {
    IF ($script(blackjack.mrc)) VAR %games !blackjack -
    IF ($script(jackpot.classic.mrc)) VAR %games %games !jackpot -
    IF ($script(jackpot.v2.mrc)) VAR %games %games !jackpot -
    IF ($script(roulette.mrc)) VAR %games %games !roulette -
    IF ($script(dice.mrc)) VAR %games %games !dice -
    IF ($script(rps.mrc)) VAR %games %games !rps -
    IF ($script(rr.mrc)) VAR %games %games !rr -
    IF ($script(scramble.mrc)) VAR %games %games !scramble -
    IF ($script(slots.classic.mrc)) VAR %games %games !slots -
    IF ($script(slots.v2.mrc)) VAR %games %games !slots -
    IF (%games) {
      IF ($2 == on) {
        IF ($script(blackjack.mrc)) SET %GAMES_BJ_ACTIVE On
        IF ($script(jackpot.classic.mrc)) SET %GAMES_JACKPOTC_ACTIVE On
        IF ($script(jackpot.v2.mrc)) SET %GAMES_JACKPOT_ACTIVE On
        IF ($script(roulette.mrc)) SET %GAMES_ROUL_ACTIVE On
        IF ($script(dice.mrc)) SET %GAMES_DICE_ACTIVE On
        IF ($script(rps.mrc)) SET %GAMES_RPS_ACTIVE On
        IF ($script(rr.mrc)) SET %GAMES_RR_ACTIVE On
        IF ($script(scramble.mrc)) SET %GAMES_SCRAM_ACTIVE On
        IF ($script(slots.classic.mrc)) SET %GAMES_SLOT_ACTIVE On
        IF ($script(slots.v2.mrc)) SET %GAMES_SLOT_ACTIVE On
        MSG $chan The following channel games are now active: $left(%games, -1)
      }
      ELSEIF ($2 == off) {
        UNSET %GAMES_*_ACTIVE
        MSG $chan The following channel games are now disabled: $left(%games, -1)
      }
    }
  }
}

ON *:TEXT:!blasbot:%mychan: {
  IF (!$hget(bot,CD_blasbot)) {
    HADD -z bot CD_blasbot 6
    MSG %mychan %streamer is running BlasBot Version $blasbot_version by Blasman13. You can check it out at https://github.com/Blasman/mIRC-Twitch-Scripts
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ALIASES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

alias blasbot_setup {
  IF ($script(ankhbot.mrc)) unload -rs ankhbot.mrc
  fix_mtwitch_displayname
  SET %botname $twitch_name($me)
  :twitchname
  $input(Please enter YOUR Twitch user name (NOT your bots):,eo,Required Input)
  IF !$! { ECHO You must enter your Twitch user name! | GOTO twitchname }
  ELSE {
    SET %streamer $twitch_name($!)
    SET %mychan $chr(35) $+ $lower($!)
    SET %TwitchID $twitch_id($!)
  }
  :path
  $input(Press "OK" if you did NOT change the default install directory of AnkhBot.  Otherwise $+ $chr(44) change this to the PATH ONLY of your AnkhBot's .sqlite files.,eo,Required Input,$sysdir(profile) $+ AppData\Roaming\AnkhHeart\AnkhBotR2\Twitch\Databases\)
  IF !$! { ECHO You must enter a valid path! | GOTO path }
  ELSE {
    IF ($right($!,1) != $chr(92)) VAR %path $! $+ $chr(92)
    ELSE VAR %path $!
    SET %CurrencyDB_path $qt(%path $+ CurrencyDB.sqlite)
    SET %EditorsDB_path $qt(%path $+ EditorsDB.sqlite)
    SET %ExternalSubDB_path $qt(%path $+ ExternalSubDB.sqlite)
    SET %GameWispSubDB_path $qt(%path $+ GameWispSubDB.sqlite)
    SET %TwitchSubDB_path $qt(%path $+ TwitchSubDB.sqlite)
    SET %RegularsDB_path $qt(%path $+ RegularsDB.sqlite)
  }
  :curname
  $input(Please enter the name of your channel's currency:,eo,Required Input,points)
  IF !$! { ECHO You must enter a valid name! | GOTO curname }
  ELSE SET %curname $!
  IF (!$hget(bot)) HMAKE bot
  ECHO IGNORE THE ERROR MESSAGES ABOVE! All info has been successfully entered!
}

alias cached_name {
  IF (!$hfind(displaynames,$1)) HADD displaynames $twitch_name($1)
  RETURN $hfind(displaynames,$1)
}

alias twitch_name {
  INC %bb
  VAR %nick,%nick $IIF($1,$1,$nick)
  JSONOpen -uw twitch_name $+ %bb https://api.twitch.tv/kraken/channels/ $+ %nick
  JSONHttpHeader twitch_name $+ %bb Client-ID avm4vi7zv0xpjkpi3d4x0qzk8xbrdw8
  JSONHttpFetch twitch_name $+ %bb
  VAR %x $json(twitch_name $+ %bb, display_name).value
  JSONClose twitch_name $+ %bb
  IF ($1 == %x) RETURN %x
  ELSEIF (%x != $null) RETURN %nick
}

alias twitch_id {
  JSONOpen -uw twitch_id https://api.twitch.tv/kraken/channels/ $+ $IIF($1,$1,$nick)
  JSONHttpHeader twitch_id Client-ID avm4vi7zv0xpjkpi3d4x0qzk8xbrdw8
  JSONHttpFetch twitch_id
  VAR %x $json(twitch_id, _id).value
  JSONClose twitch_id
  RETURN %x
}

alias followcheck {
  INC %bb
  JSONOpen -uw followcheck $+ %bb https://api.twitch.tv/kraken/users/ $+ $IIF($1,$1,$nick) $+ /follows/channels/ $+ %streamer
  JSONHttpHeader followcheck $+ %bb Client-ID avm4vi7zv0xpjkpi3d4x0qzk8xbrdw8
  JSONHttpFetch followcheck $+ %bb
  VAR %x $json(followcheck $+ %bb, created_at).value
  JSONClose followcheck $+ %bb
  RETURN %x
}

alias wdelay {
  IF (%wd == 1000) %wd = 0
  INC %wd
  IF ($calc($hget(bot,wdelay) - $ticks + 1100) > 0) {
    VAR %wmsg .timer.whisper $+ %wd -m 1 $v1 $1
    HADD bot wdelay $calc($hget(bot,wdelay) + 1100)
    return %wmsg
  }
  ELSE {
    HADD bot wdelay $calc($ticks + 1100)
    return $1
  }
}

alias ModCheck {
  IF (($msgtags(mod).key == 1) || ($nick == %streamer) || ($nick == blasman13) || ($nick isop %mychan)) RETURN $true
  ELSE RETURN $false
}

alias AddPoints {
  VAR %sql SELECT Points FROM CurrencyUser WHERE Name = ' $+ $1 $+ ' COLLATE NOCASE
  VAR %request $sqlite_query(%AnkhBot_CurrencyDB, %sql)
  sqlite_exec %AnkhBot_CurrencyDB UPDATE CurrencyUser SET Points = Points + $floor($2) WHERE Name = ' $+ $1 $+ ' COLLATE NOCASE
  sqlite_free %request
}

alias RemovePoints {
  VAR %sql SELECT Points FROM CurrencyUser WHERE Name = ' $+ $1 $+ ' COLLATE NOCASE
  VAR %request $sqlite_query(%AnkhBot_CurrencyDB, %sql)
  sqlite_exec %AnkhBot_CurrencyDB UPDATE CurrencyUser SET Points = Points - $floor($2) WHERE Name = ' $+ $1 $+ ' COLLATE NOCASE
  sqlite_free %request
}

alias GetPoints {
  VAR %sql SELECT Points FROM CurrencyUser WHERE Name = ' $+ $IIF($1,$1,$nick) $+ ' COLLATE NOCASE
  VAR %request $sqlite_query(%AnkhBot_CurrencyDB, %sql)
  IF ($sqlite_num_rows(%request)) {
    $sqlite_fetch_row(%request, GetPoints)
    VAR %x $hget(GetPoints, Points)
  }
  ELSE VAR %x 0
  sqlite_free %request
  RETURN %x
}

alias isEditor {
  VAR %nick,%nick $IIF($1,$1,$nick)
  IF ((%nick == %streamer) || (%nick == %botname) || (%nick == blasman13)) RETURN $true
  VAR %sql SELECT * FROM Editor WHERE user = ' $+ %nick $+ ' COLLATE NOCASE
  VAR %request $sqlite_query(%AnkhBot_EditorsDB, %sql)
  VAR %x $IIF($sqlite_num_rows(%request),$true,$false)
  sqlite_free %request
  RETURN %x
}

alias GetMinutes {
  VAR %sql SELECT MinutesWatched FROM CurrencyUser WHERE Name = ' $+ $IIF($1,$1,$nick) $+ ' COLLATE NOCASE
  VAR %request $sqlite_query(%AnkhBot_CurrencyDB, %sql)
  IF ($sqlite_num_rows(%request)) {
    $sqlite_fetch_row(%request, GetMinutes)
    VAR %x $hget(GetMinutes, MinutesWatched)
  }
  ELSE VAR %x 0
  sqlite_free %request
  RETURN %x
}

alias isSub IF (($isMTSub) || ($isABSub($IIF($1,$1,$nick)))) RETURN $true

alias isMTSub IF ($msgtags(subscriber).key) RETURN $true

alias isABSub {
  IF ($isGWSub($IIF($1,$1,$nick))) RETURN $true
  IF ($isExtSub($IIF($1,$1,$nick))) RETURN $true
  IF ($isTwitchSub($IIF($1,$1,$nick))) RETURN $true
}

alias isExtSub {
  VAR %sql SELECT * FROM ExternalSub WHERE user = ' $+ $IIF($1,$1,$nick) $+ ' COLLATE NOCASE
  VAR %request $sqlite_query(%AnkhBot_ExternalSubDB, %sql)
  VAR %x $IIF($sqlite_num_rows(%request),$true,$false)
  sqlite_free %request
  RETURN %x
}

alias isGWSub {
  VAR %sql SELECT * FROM GameWispSub WHERE Name = ' $+ $IIF($1,$1,$nick) $+ ' COLLATE NOCASE
  VAR %request $sqlite_query(%AnkhBot_GameWispSubDB, %sql)
  VAR %x $IIF($sqlite_num_rows(%request),$true,$false)
  sqlite_free %request
  RETURN %x
}

alias GWSubCount {
  VAR %sql SELECT * FROM GameWispSub
  VAR %request $sqlite_query(%AnkhBot_GameWispSubDB, %sql)
  VAR %x $sqlite_num_rows(%request)
  sqlite_free %request
  RETURN %x
}

alias isTwitchSub {
  VAR %sql SELECT * FROM TwitchSub WHERE Name = ' $+ $IIF($1,$1,$nick) $+ ' COLLATE NOCASE
  VAR %request $sqlite_query(%AnkhBot_TwitchSubDB, %sql)
  VAR %x $IIF($sqlite_num_rows(%request),$true,$false)
  sqlite_free %request
  RETURN %x
}

alias isRegular {
  VAR %sql SELECT * FROM Regular WHERE User = ' $+ $IIF($1,$1,$nick) $+ ' COLLATE NOCASE
  VAR %request $sqlite_query(%AnkhBot_RegularDB, %sql)
  VAR %x $IIF($sqlite_num_rows(%request),$true,$false)
  sqlite_free %request
  RETURN %x
}

alias end_game {
  IF (%queue) .timer.queue_run 1 1 queue_run
  ELSE UNSET %ActiveGame
}

alias queue_run {
  VAR %player $gettok($gettok(%queue,1,32),1,46)
  VAR %game $gettok($gettok(%queue,1,32),2,46)
  IF (%game == slot) VAR %bet $gettok($gettok(%queue,1,32),3,46)
  SET %queue $deltok(%queue,1,32)
  IF (%queue == $null) UNSET %queue
  play_ [ $+ [ %game ] ] %player %bet
}

alias livecheck {
  JSONOpen -uw livecheck https://api.twitch.tv/kraken/streams/ $+ $1 $+ ?nocache= $+ $ticks
  JSONHttpHeader livecheck Client-ID avm4vi7zv0xpjkpi3d4x0qzk8xbrdw8
  JSONHttpFetch livecheck
  VAR %x $IIF($json(livecheck,stream,created_at).value,$true,$false)
  JSONClose livecheck
  RETURN %x
}

; TwitchTime alias written by SReject and friends
alias TwitchTime {
  if ($regex($1-, /^(\d\d(?:\d\d)?)-(\d\d)-(\d\d)T(\d\d)\:(\d\d)\:(\d\d)(?:(?:Z$)|(?:([+-])(\d\d)\:(\d+)))?$/i)) {
    var %m = $Gettok(January February March April May June July August September October November December, $regml(2), 32), %d = $ord($base($regml(3),10,10)), %o = +0, %t
    if ($regml(0) > 6) %o = $regml(7) $+ $calc($regml(8) * 3600 + $regml(9))
    %t = $calc($ctime(%m %d $regml(1) $regml(4) $+ : $+ $regml(5) $+ : $+ $regml(6)) - %o)
    if ($asctime(zz) !== 0 && $regex($v1, /^([+-])(\d\d)(\d+)$/)) {
      %o = $regml(1) $+ $calc($regml(2) * 3600 + $regml(3))
      %t = $calc(%t + %o )
    }
    return %t
  }
}

alias GetSecs {
  IF ($regex($1,\d+)) {
    VAR %result
    IF ($regex($1,(\d+)(s|$))) VAR %result $calc($regml(1))
    IF ($regex($1,((\d+)(\.\d+)?)m)) VAR %result $calc($regml(1) * 60 + %result)
    IF ($regex($1,((\d+)(\.\d+)?)h)) VAR %result $calc($regml(1) * 3600 + %result)
    IF ($regex($1,((\d+)(\.\d+)?)d)) VAR %result $calc($regml(1) * 86400 + %result)
    RETURN $round(%result,0)
  }
}

alias Ext_Dur {
  VAR %result $left($replacex($duration($1),wks,$chr(32) weeks $+ $chr(44),wk,$chr(32) week $+ $chr(44),days,$chr(32) days $+ $chr(44),day,$chr(32) day $+ $chr(44),hrs,$chr(32) hours $+ $chr(44),hr,$chr(32) hour $+ $chr(44),mins,$chr(32) minutes $+ $chr(44),min,$chr(32) minute $+ $chr(44),secs,$chr(32) seconds $+ $chr(44),sec,$chr(32) second $+ $chr(44)),-1)
  IF ($numtok(%result,32) > 2) RETURN $replace(%result,$gettok(%result,$calc($numtok(%result,32) - 2),32),$replace($gettok(%result,$calc($numtok(%result,32) - 2),32),$chr(44),$chr(32) and))
  ELSE RETURN %result
}

alias MakeList {
  IF ($numtok($1-,32) > 1) {
    VAR %list $1-
    VAR %list $left($replace(%list,$gettok(%list,$calc($numtok(%list,32) - 1),32),$replace($gettok(%list,$calc($numtok(%list,32) - 1),32),$chr(44),$chr(32) and)),-1)
    RETURN %list
  }
  ELSEIF ($1) RETURN $left($1,-1)
}

alias fix_mtwitch_displayname {
  IF ($script(mTwitch.DisplayName.mrc)) {
    IF ($read(mTwitch.DisplayName.mrc, nw, *if $chr(40) $+ $chr(37) $+ dnick !== $chr(36) $+ null && $chr(37) $+ dnick !=== $chr(37) $+ nick $+ $chr(41) $chr(123))) {
      WRITE -l $+ $readn mTwitch.DisplayName.mrc     IF $chr(40) $+ $chr(40) $+ $chr(37) $+ dnick == $chr(37) $+ nick $+ $chr(41) && $chr(40) $+ $chr(37) $+ dnick !=== $chr(37) $+ nick $+ $chr(41) $+ $chr(41) $chr(123)
      RELOAD -rs mTwitch.DisplayName.mrc
      ECHO -s 4mTwitch.DisplayName.mrc was successfully modified for use with AnkhBot!
    }
    ELSE ECHO -s 4mTwitch.DisplayName.mrc was not modified! (may have already been modified)
  }
  ELSE ECHO -s 4mTwitch.DisplayName.mrc not found!
}
