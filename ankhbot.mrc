;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; VARIABLES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

/*
HEY!  LOOK HERE!  This is what you need to change in this script...

Where it says "SET %CurrencyDB" below, change the path to the path of
YOUR AnkhBot's CurrencyDB.sqlite file.  Leave the quotation marks in!
You only need to change this variable if you installed AnkhBot to a
directory other than it's default install directory.

The %curname variable is the name of your channel currency.

The %mychan variable is your Twitch username, KEEP the # symbol there.

You will need to UNLOAD and RE-LOAD this script for any changes to the
variables below to take effect.  This can be done by pressing ALT-R in
mIRC > Select "View" > Select "ankhbot.mrc" > Click on "File" > "Unload."
Then, click on "File" and "Load..." and select the slot.mrc file again.
*/

ON *:LOAD: {
  SET %CurrencyDB "%APPDATA%\AnkhHeart\AnkhBotR2\Twitch\Databases\CurrencyDB.sqlite"
  SET %curname points
  SET %mychan #Your_Twitch_Name
}

ON *:UNLOAD: {
  UNSET %CurrencyDB
  UNSET %curname
  UNSET %mychan
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ALIASES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

alias twitch_name {

  if (%tn == 1000) %tn = 0
  inc %tn
  JSONOpen -ud twitch_name $+ %tn https://api.twitch.tv/kraken/channels/ $+ $1
  return $json(twitch_name $+ %tn $+ , display_name)
  JSONClose twitch_name $+ %tn
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
