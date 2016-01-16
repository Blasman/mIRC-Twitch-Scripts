;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;; CORE TWITCH BOT / ANKHBOT SCRIPT ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

/*
This is the main script that sets commonly used variables and contains
commonly used aliases for many of the other scripts found on my GitHub
at https://github.com/Blasman/mIRC-Twitch-Scripts

When first loading this script, you will have to enter some info in input
boxes that will appear.  If you change any of this info or enter it
incorrectly, you will need to re-run the setup.  You can re-run the setup
by re-loading the script, or by typing /ankhbot_setup in mIRC.
*/

ON *:LOAD: { ankhbot_setup }

ON *:UNLOAD: {
  UNSET %CurrencyDB
  UNSET %streamer
  UNSET %curname
  UNSET %mychan
  UNSET %TwitchID
  UNSET %botname
}

ON *:CONNECT: { 
  IF ($server == tmi.twitch.tv) {
    UNSET %ActiveGame
    UNSET %wdelay
  }
}

ON $*:TEXT:/^!games(\s)(on|off)$/iS:%mychan: {
  IF ($nick isop $chan) {
    IF (($script(blackjack.mrc)) || ($script(jackpot.classic.mrc)) || ($script(roulette.mrc)) || ($script(rps.mrc)) || ($script(rr.mrc)) || ($script(scramble.mrc)) || ($script(slots.classic.mrc))) {
      IF ($script(blackjack.mrc)) VAR %games !blackjack -
      IF ($script(jackpot.classic.mrc)) VAR %games %games !jackpot -
      IF ($script(roulette.mrc)) VAR %games %games !roulette -
      IF ($script(rps.mrc)) VAR %games %games !rps -
      IF ($script(rr.mrc)) VAR %games %games !rr -
      IF ($script(scramble.mrc)) VAR %games %games !scramble -
      IF ($script(slots.classic.mrc)) VAR %games %games !slots -
      IF ($2 == on) {
        IF ($script(blackjack.mrc)) SET %GAMES_BJ_ACTIVE On
        IF ($script(jackpot.classic.mrc)) SET %GAMES_JACKPOTC_ACTIVE On
        IF ($script(roulette.mrc)) SET %GAMES_ROUL_ACTIVE On
        IF ($script(rps.mrc)) SET %GAMES_RPS_ACTIVE On
        IF ($script(rr.mrc)) SET %GAMES_RR_ACTIVE On
        IF ($script(scramble.mrc)) SET %GAMES_SCRAM_ACTIVE On
        IF ($script(slots.classic.mrc)) SET %GAMES_SLOT_ACTIVE On
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


alias ankhbot_setup {

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
  $input(Press "OK" if you did NOT change the default install directory of AnkhBot.  Otherwise $+ $chr(44) change this to the path and filename of your AnkhBot's CurrencyDB.sqlite file.,eo,Required Input,$sysdir(profile) $+ AppData\Roaming\AnkhHeart\AnkhBotR2\Twitch\Databases\CurrencyDB.sqlite)
  IF !$! { ECHO You must enter a valid path! | GOTO path }
  ELSE SET %CurrencyDB $qt($!)
  :curname
  $input(Please enter the name of your channel's currency:,eo,Required Input,points)
  IF !$! { ECHO You must enter a valid name! | GOTO curname }
  ELSE SET %curname $!
}

alias cached_name {

  VAR %nick $wildtok(%display.names, $1, 1, 32)
  IF (%nick != $null) return %nick
  ELSE {
    SET %display.names $addtok(%display.names, $twitch_name($1), 32)
    return $wildtok(%display.names, $1, 1, 32)
  }
}

alias twitch_name {

  if (%tn == 1000) %tn = 0
  inc %tn
  JSONOpen -ud twitch_name $+ %tn https://api.twitch.tv/kraken/channels/ $+ $1
  return $json(twitch_name $+ %tn $+ , display_name)
  JSONClose twitch_name $+ %tn
}

alias twitch_id {

  JSONOpen -ud twitch_id https://api.twitch.tv/kraken/channels/ $+ $1
  return $json(twitch_id, _id)
  JSONClose twitch_id
}

alias wdelay {

  VAR %wcheck $calc(%wdelay - $ticks + 1100)
  IF (%wcheck > 0) {
    VAR %wmsg .timer.whisper $+ $ticks -m 1 %wcheck $1
    SET -e %wdelay $calc(%wdelay + 1100)
    return %wmsg
  }
  ELSE {
    SET -e %wdelay $ticks
    return $1
  }
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

  SET %newpoints = $calc(%ankhbot_points + $2)
  sqlite_exec %ankhbot_currency UPDATE CurrencyUser SET Points %newpoints WHERE Name = ' $+ $1 $+ ' COLLATE NOCASE
  sqlite_free %request_points
  UNSET %newpoints
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

  SET %newpoints = $calc(%ankhbot_points - $2)
  sqlite_exec %ankhbot_currency UPDATE CurrencyUser SET Points %newpoints WHERE Name = ' $+ $1 $+ ' COLLATE NOCASE
  sqlite_free %request_points
  UNSET %newpoints
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
