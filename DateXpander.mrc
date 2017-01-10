; THIS IS A SLIGHTLY MODIFIED VERSION OF RAMIUS' DATEXPANDER SCRIPT FOUND HERE http://pastebin.com/eRMp7U8E
; ALL CREDITS GO TO RAMIUS FOR THIS SCRIPT http://www.kakkoiitranslations.net/mircscripts/

alias DateXpander {

  if ($1 isalpha) {
    echo -a Error.  Use the same format as in $chr(36) $+ duration's output or seconds for the "value".
    halt
  }

  if ($1 isnum) {
    set %dx_value $duration($1)
  }
  else {
    set %dx_value $1
  }

  set %dx_weeks $iif($gettok(%dx_value,1,119) isnum,$gettok(%dx_value,1,119),0)
  set %dx_days $iif($gettok($gettok(%dx_value,1,100),-1,32) isnum,$gettok($gettok(%dx_value,1,100),-1,32),0)
  set %dx_hours $iif($gettok($gettok(%dx_value,1,104),-1,32) isnum,$gettok($gettok(%dx_value,1,104),-1,32),0)
  set %dx_minutes $iif($gettok($gettok(%dx_value,1,109),-1,32) isnum,$gettok($gettok(%dx_value,1,109),-1,32),0)
  set %dx_seconds $iif(sec isin $gettok(%dx_value,$gettok(%dx_value,0,32),32),$gettok($gettok(%dx_value,$gettok(%dx_value,0,32),32),1,115),0)
  set %dx_totaldays $calc(%dx_weeks * 7 + %dx_days)
  set %dx_outputdays %dx_totaldays

  if ($3 != $null) {
    set %dx_currentmonth $gettok($3,1,47)
    set %dx_currentyear $gettok($3,3,47)
  }
  elseif ($chr(47) isin $2) {
    set %dx_currentmonth $gettok($2,1,47)
    set %dx_currentyear $gettok($2,3,47)
  }
  else {
    set %dx_currentmonth $date(m)
    set %dx_currentyear $date(yyyy)
  }
  if ($len(%dx_currentmonth) == 1) { set %dx_currentmonth 0 $+ %dx_currentmonth }
  if ($len(%dx_currentyear) == 2) { set %dx_currentyear 20 $+ %dx_currentyear }

  :monthstart
  if ($istok(12.10.07.05,%dx_currentmonth,46)) {
    set %dx_monthdays 30
  }
  elseif ($istok(11.09.08.06.04.02.01,%dx_currentmonth,46)) {
    set %dx_monthdays 31
  }
  elseif (%dx_currentmonth == 03 && ($calc(%dx_currentyear % 4) != 0 || ($calc(%dx_currentyear % 100) == 0 && $calc(%dx_currentyear % 400) != 0 && %dx_currentyear > 1582))) {
    set %dx_monthdays 28
  }
  elseif (%dx_currentmonth == 03) {
    set %dx_monthdays 29
  }
  if (%dx_totaldays >= %dx_monthdays) {
    inc %dx_months
    dec %dx_totaldays %dx_monthdays
    if (%dx_currentmonth != 01) {
      dec %dx_currentmonth
      if ($len(%dx_currentmonth) == 1) { set %dx_currentmonth 0 $+ %dx_currentmonth }
      dec %dx_currentyear
    }
    else { set %dx_currentmonth 12 }
    inc %dx_totalmonths
    inc %dx_monthsdays %dx_monthdays
    if (%dx_totalmonths == 12) {
      inc %dx_yeardays %dx_monthsdays
      unset %dc_monthsdays
      unset %dx_totalmonths
    }
    goto monthstart
  }

  set %dx_years $int($calc(%dx_months / 12))
  dec %dx_months $calc(%dx_years * 12)
  set %dx_weeks $int($calc(%dx_totaldays / 7))
  set %dx_totaldays $calc(%dx_totaldays % 7)

  if ($2 && $chr(47) !isin $2) {
    if (y !isin $2 && %dx_years > 0) {
      set %dx_months $calc(%dx_months + (%dx_years * 12))
      set %dx_years 0
    }
    if (m !isin $2 && %dx_months > 0) {
      set %dx_weeks $iif(%dx_years == 0,$int($calc((%dx_outputdays) / 7)),$int($calc((%dx_outputdays - %dx_yeardays) / 7)))
      set %dx_totaldays $iif(%dx_years == 0,$calc((%dx_outputdays) % 7),$calc((%dx_outputdays - %dx_yeardays) % 7))
    }
    if (w !isin $2 && %dx_weeks > 0) {
      set %dx_totaldays $calc(%dx_totaldays + (%dx_weeks * 7))
    }
    if (d !isin $2 && %dx_days > 0) {
      set %dx_hours $calc(%dx_hours + (%dx_days * 24))
    }
    if (h !isin $2 && %dx_hours > 0) {
      set %dx_minutes $calc(%dx_minutes + (%dx_hours * 60))
    }
    if (n !isin $2 && %dx_minutes > 0) {
      set %dx_seconds $calc(%dx_seconds + (%dx_minutes * 60))
    }
    set %dateoutput $replacex($2,y,$bytes(%dx_years,b) $iif(%dx_years == 1,year $+ $chr(44) $+ $chr(32),years $+ $chr(44) $+ $chr(32)),m,$bytes(%dx_months,b) $iif(%dx_months == 1,month $+ $chr(44) $+ $chr(32),months $+ $chr(44) $+ $chr(32)),w,$bytes(%dx_weeks,b) $iif(%dx_weeks == 1,week $+ $chr(44) $+ $chr(32),weeks $+ $chr(44) $+ $chr(32)),d,$bytes(%dx_totaldays,b) $iif(%dx_totaldays == 1,day $+ $chr(44) $+ $chr(32),days $+ $chr(44) $+ $chr(32)),h,$bytes(%dx_hours,b) $iif(%dx_hours == 1,hour $+ $chr(44) $+ $chr(32),hours $+ $chr(44) $+ $chr(32)),n,$bytes(%dx_minutes,b) $iif(%dx_minutes == 1,minute $+ $chr(44) $+ $chr(32),minutes $+ $chr(44) $+ $chr(32)),s,$bytes(%dx_seconds,b) $iif(%dx_seconds == 1,second $+ $chr(44) $+ $chr(32),seconds $+ $chr(44) $+ $chr(32)))
    set %dateoutput $left(%dateoutput,-1)
  }
  else {
    if ($1 >= 86400) {
      if (%dx_years > 1) { set %dateoutput %dateoutput $bytes(%dx_years,b) $+ _years }
      elseif (%dx_years == 1) { set %dateoutput %dateoutput $bytes(%dx_years,b) $+ _year }
      if (%dx_months > 1) { set %dateoutput %dateoutput %dx_months $+ _months }
      elseif (%dx_months == 1) { set %dateoutput %dateoutput %dx_months $+ _month }
      if (%dx_weeks > 1) { set %dateoutput %dateoutput %dx_weeks $+ _weeks }
      elseif (%dx_weeks == 1) { set %dateoutput %dateoutput %dx_weeks $+ _week }
      if (%dx_totaldays > 1) { set %dateoutput %dateoutput %dx_totaldays $+ _days }
      elseif (%dx_totaldays == 1) { set %dateoutput %dateoutput %dx_totaldays $+ _day }
    }
    else {
      if (%dx_hours > 1) { set %dateoutput %dateoutput %dx_hours $+ _hours }
      elseif (%dx_hours == 1) { set %dateoutput %dateoutput %dx_hours $+ _hour }
      if (%dx_minutes > 1) { set %dateoutput %dateoutput %dx_minutes $+ _minutes }
      elseif (%dx_minutes == 1) { set %dateoutput %dateoutput %dx_minutes $+ _minute }
      if (%dx_seconds > 1) { set %dateoutput %dateoutput %dx_seconds $+ _seconds }
      elseif (%dx_seconds == 1) { set %dateoutput %dateoutput %dx_seconds $+ _second }
    }
    unset %dx_*

    set %dateoutput $replace(%dateoutput,$chr(32),$chr(44) $+ $chr(32),_,$chr(32))
  }
  if ($gettok(%dateoutput,0,32) > 2) {
    set %dateoutput $instok(%dateoutput,$chr(32) $+ and,-2,32)
  }
  unset %dx_*
  var %result %dateoutput
  unset %dateoutput
  return %result
}
