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
  :windowsname
  $input(Please enter your Windows user name that you are running AnkhBot and mIRC on:,eo,Required Input)
  IF !$! { ECHO You must enter your Windows user name! | GOTO windowsname }
  ELSE VAR %windowsname $!
  :path
  $input(Press "OK" if you did NOT change the default install directory of AnkhBot $+ $chr(44) and AnkhBot is stored on your main C: drive.  Otherwise $+ $chr(44) change this to the path and filename of your AnkhBot's CurrencyDB.splite file.,eo,Required Input,C:\Users\ $+ %windowsname $+ \AppData\Roaming\AnkhHeart\AnkhBotR2\Twitch\Databases\CurrencyDB.sqlite)
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

  IF (!%wdelay) {
    SET -z %wdelay 2
    return $1
  }
  ELSE {
    VAR %wmsg .timer.whisper $+ $ticks 1 %wdelay $1
    INC %wdelay 2
    return %wmsg
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
