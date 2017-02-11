;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BLASBOT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;; CREATED BY BLASMAN13 ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;; TWITCH.TV/BLASMAN13 ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;; CORE MIRC SCRIPT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;; VERSION 1.0.0.4 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

alias blasbot_version return 1.0.0.4

menu menubar,channel,status {
  $chr(36) $+ $chr(36) $+ $chr(36) CLICK HERE TO DONATE $chr(36) $+ $chr(36) $+ $chr(36):URL -n https://twitch.streamlabs.com/blasman13
  BlasBot
  .$style(2) Version $blasbot_version:$null
  .$style(2) Created by Blasman13:$null
  .Visit Twitch.TV/Blasman13:URL -n https://twitch.tv/Blasman13
  .Visit GitHub:URL -n https://github.com/Blasman/mIRC-Twitch-Scripts
}

ON *:LOAD: blasbot_setup

ON *:UNLOAD: {
  UNSET %CurrencyDB
  UNSET %EditorsDB
  UNSET %ExternalSubDB
  UNSET %streamer
  UNSET %curname
  UNSET %mychan
  UNSET %TwitchID
  UNSET %botname
}

ON *:CONNECT: {
  IF ($server == tmi.twitch.tv) {
    IF (!$hget(bot)) HMAKE bot
    IF (!$hget(displaynames)) {
      IF ($script(hosts.mrc)) {
        HMAKE displaynames
        IF ($file(displaynames.htb)) HLOAD displaynames displaynames.htb
      }
    }
    UNSET %ActiveGame
  }
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
        MSG $chan The following channel games are now active:  $left(%games, -1)
      }
      ELSEIF ($2 == off) {
        UNSET %GAMES_*_ACTIVE
        MSG $chan The following channel games are now disabled:  $left(%games, -1)
      }
    }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ALIASES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

alias blasbot_setup {
  IF ($script(ankhbot.mrc)) unload -rs ankhbot.mrc
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
    SET %CurrencyDB $qt(%path $+ CurrencyDB.sqlite)
    SET %EditorsDB $qt(%path $+ EditorsDB.sqlite)
    SET %ExternalSubDB $qt(%path $+ ExternalSubDB.sqlite)
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
  IF (%tn == 1000) %tn = 0
  INC %tn
  JSONOpen -uw twitch_name $+ %tn https://api.twitch.tv/kraken/channels/ $+ $1
  JSONHttpHeader twitch_name $+ %tn Client-ID avm4vi7zv0xpjkpi3d4x0qzk8xbrdw8
  JSONHttpFetch twitch_name $+ %tn
  VAR %x $json(twitch_name $+ %tn $+ , display_name).value
  JSONClose twitch_name $+ %tn
  IF ($1 == %x) RETURN %x
  ELSEIF (%x != $null) RETURN $1
}

alias twitch_id {
  JSONOpen -uw twitch_id https://api.twitch.tv/kraken/channels/ $+ $1
  JSONHttpHeader twitch_id Client-ID avm4vi7zv0xpjkpi3d4x0qzk8xbrdw8
  JSONHttpFetch twitch_id
  VAR %x $json(twitch_id, _id).value
  JSONClose twitch_id
  RETURN %x
}

alias followcheck {
  JSONOpen -uw followcheck https://api.twitch.tv/kraken/users/ $+ $1 $+ /follows/channels/ $+ %streamer
  JSONHttpHeader followcheck Client-ID avm4vi7zv0xpjkpi3d4x0qzk8xbrdw8
  JSONHttpFetch followcheck
  VAR %x $json(followcheck, created_at).value
  JSONClose followcheck
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
  IF (($msgtags(mod).key == 1) || ($nick == %streamer) || ($nick isop %mychan)) return $true
  ELSE return $false
}

alias addpoints {
  set %ankhbot_currency $sqlite_open(%CurrencyDB)
  if (!%ankhbot_currency) {
    echo 4 -a Error: %sqlite_errstr
    return
  }
  var %sql_points = SELECT Points FROM CurrencyUser WHERE Name = ' $+ $1 $+ ' COLLATE NOCASE
  var %request_points = $sqlite_query(%ankhbot_currency, %sql_points)
  if (!%request_points) {
    echo 4 -a Error: %sqlite_errstr
    return
  }
  $sqlite_fetch_row(%request_points, row)
  var %ankhbot_points = $hget(row, Points)

  sqlite_exec %ankhbot_currency UPDATE CurrencyUser SET Points = Points + $floor($2) WHERE Name = ' $+ $1 $+ ' COLLATE NOCASE
  sqlite_free %request_points
}

alias removepoints {
  set %ankhbot_currency $sqlite_open(%CurrencyDB)
  if (!%ankhbot_currency) {
    echo 4 -a Error: %sqlite_errstr
    return
  }
  var %sql_points = SELECT Points FROM CurrencyUser WHERE Name = ' $+ $1 $+ ' COLLATE NOCASE
  var %request_points = $sqlite_query(%ankhbot_currency, %sql_points)
  if (!%request_points) {
    echo 4 -a Error: %sqlite_errstr
    return
  }
  $sqlite_fetch_row(%request_points, row)
  var %ankhbot_points = $hget(row, Points)

  sqlite_exec %ankhbot_currency UPDATE CurrencyUser SET Points = Points - $floor($2) WHERE Name = ' $+ $1 $+ ' COLLATE NOCASE
  sqlite_free %request_points
}

alias checkpoints {
  set %ankhbot_currency $sqlite_open(%CurrencyDB)
  if (!%ankhbot_currency) {
    echo 4 -a Error: %sqlite_errstr
    return
  }
  var %sql_points = SELECT Points FROM CurrencyUser WHERE Name = ' $+ $1 $+ ' COLLATE NOCASE
  var %request_points = $sqlite_query(%ankhbot_currency, %sql_points)
  if (!%request_points) {
    echo 4 -a Error: %sqlite_errstr
    return
  }
  if ($sqlite_num_rows(%request_points) == 0) { return false }
  else {
    $sqlite_fetch_row(%request_points, row)
    var %ankhbot_points = $hget(row, Points)
    if (%ankhbot_points < $2) { return false }
    elseif (%ankhbot_points >= $2) { return true }
    sqlite_free %request_points
  }
}

alias editorcheck {
  IF (($1 == %streamer) || ($1 == %botname)) return true
  SET %ankhbot_editors $sqlite_open(%EditorsDB)
  IF (!%ankhbot_editors) {
    echo 4 -a Error: %sqlite_errstr
    halt
  }
  VAR %sql = SELECT * FROM Editor WHERE user = ' $+ $1 $+ ' COLLATE NOCASE
  VAR %request = $sqlite_query(%ankhbot_editors, %sql)
  IF (!%request) {
    echo 4 -a Error: %sqlite_errstr
    halt
  }
  IF ($sqlite_num_rows(%request) == 0) return false
  ELSE return true
  sqlite_free %request
}

alias checkhours {
  set %ankhbot_hours $sqlite_open(%CurrencyDB)
  if (!%ankhbot_hours) {
    echo 4 -a Error: %sqlite_errstr
    return
  }
  var %sql = SELECT Hours FROM CurrencyUser WHERE Name = ' $+ $1 $+ ' COLLATE NOCASE
  var %request = $sqlite_query(%ankhbot_hours, %sql)
  if (!%request) {
    echo 4 -a Error: %sqlite_errstr
    return
  }
  if ($sqlite_num_rows(%request) == 0) { return 0  |  return }
  else {
    $sqlite_fetch_row(%request, row)
    var %hours_full = $hget(row, Hours)
    var %hr_pos = $pos(%hours_full,:)
    dec %hr_pos
    var %hours = $left(%hours_full, %hr_pos)
    var %days_pos = $pos(%hours, .)
    if (%days_pos) {
      var %hour_count = $right(%hours, 2)
      dec %days_pos
      var %day_count = $left(%hours, %days_pos)
      var %hours = %day_count * 24
      var %hours = %hours + %hour_count
    }
    if (%hours < 10) { %hours = $right(%hours, 1) }
    if (%hours < $2) { return %hours  |  return }
    else { return true }
  }
  sqlite_free %request
}

alias isExtSub {
  SET %AnkhBot_Subs $sqlite_open(%ExternalSubDB)
  IF (!%AnkhBot_Subs) {
    echo 4 -a Error: %sqlite_errstr
    return
  }
  VAR %sql = SELECT * FROM ExternalSub WHERE user = ' $+ $1 $+ ' COLLATE NOCASE
  VAR %request = $sqlite_query(%AnkhBot_Subs, %sql)
  IF (!%request) {
    echo 4 -a Error: %sqlite_errstr
    return
  }
  IF ($sqlite_num_rows(%request) == 0) return $false
  ELSE return $true
  sqlite_free %request
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
