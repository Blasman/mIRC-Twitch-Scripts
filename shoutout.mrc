;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;; SHOUT OUT SCRIPT ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; If you want to customize this script, you can easily figure out how to by
; editing the bot responses after the three "DESCRIBE $chan" parts of the script.

ON $*:TEXT:/^!(follow|caster|so|shoutout|streamer|ally)\s/iS:%mychan: {
  IF (($nick isop $chan) && ($2) && (!%follow.cd)) {
    IF (!$3) {
      VAR %follow.name $twitch_name($remove($2, @))
      IF (%follow.name != $null) {
        SET -eu3 %follow.cd On
        DESCRIBE $chan is telling everyone to do THEMSELVES a huge favor by taking just a few seconds and following %follow.name by visiting twitch.tv/ $+ %follow.name and pressing the FOLLOW button!
      }
      ELSE MSG $chan $nick $+ , $2 is not a valid user on Twitch. FailFish
    }
    ELSE {
      SET -eu3 %follow.cd On
      VAR %follow.total $calc($0 - 1)
      VAR %x = 1
      WHILE (%x <= %follow.total) {
        VAR %follow.name [ $+ [ %x ] ] $twitch_name($remove($ [ $+ [ $calc(%x + 1) ] ], @))
        IF (%follow.name [ $+ [ %x ] ] != $null) VAR %follow.names %follow.names twitch.tv/ $+ %follow.name [ $+ [ %x ] ] ▌
        INC %x
      }
      VAR %follow.names $left(%follow.names, -1)
      IF ($numtok(%follow.names,32) >= 2) DESCRIBE $chan is telling everyone to do THEMSELVES a huge favor by taking just a few seconds and following all of these amazing streamers: %follow.names
      ELSEIF ($numtok(%follow.names,32) == 1) DESCRIBE $chan is telling everyone to do THEMSELVES a huge favor by taking just a few seconds and following %follow.name by visiting twitch.tv/ $+ %follow.names and pressing the FOLLOW button!
      ELSE MSG $chan $nick $+ , none of those names are valid Twitch users. FailFish
    }
  }
}
