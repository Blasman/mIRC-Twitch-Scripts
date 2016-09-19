/*
****************************************************************************
************** Twitch Multi-Tier Advanced Auto-Hosting Script **************
****************************************************************************

** This script is a three tier based auto-hosting script for twitch.tv.
** To use it, you must create an autohost.txt file in your mIRC directory.
** Put all of the channels that you want to auto-host on either line 1, 2, or 3 of autohost.txt.
** All channels on line 1 will be "Tier 1." All channels on line 2 will be "Tier 2."
** All channels on line 3 will be "Tier 3." Seperate channel names with a space.
**
** When the autohost alias is ran, it will search each tier in the order that channels are listed.
** If a Tier 1 channel is still live and being hosted, the script will simply end.
** If a Tier 2 channel is still live and being hosted, the script will look for a Tier 1 channel
** to host if the amount of time passed since the host began is greater than %t2.wait.
** If a Tier 3 channel is still live and being hosted, the script will look for a Tier 1 or 2
** channel to host if the amount of time passed since the host began is greater than %t3.wait.
**
** Set the variables below that are needed for the script.
** Change %mychan to your own channel name (keep the # symbol).
** Change %t2.wait to the amount of time (in seconds) that you want the autohost script to wait
** before trying to host a Tier 1 channel if a Tier 2 channel is still being hosted.
** Change %t3.wait to the amount of time (in seconds) that you want the autohost script to wait
** before trying to host a Tier 1 or Tier 2 channel if a Tier 3 channel is being hosted.
** Change %rh.wait to the amount of time (in seconds) that you want the autohost script to wait
** before being allowed to host the same channel again.
**
** This script needs the JSON and mTwitch scripts in the "required scripts" section of the GitHub.
** This script needs the $twitch_name alias and %mychan and %TwitchID variables from ankhbot.mrc.
**
** You will need to un-load and re-load this script for the changes to the variables below
** to take effect.
*/

ON *:LOAD: {
  SET %t2.wait 3600
  SET %t3.wait 3600
  SET %rh.wait 28800
}

ON *:UNLOAD: {
  UNSET %t2.wait
  UNSET %t3.wait
  UNSET %rh.wait
  UNSET %AutoHost
}

ON *:EXIT: {
  UNSET %AutoHost
}

; ** This section looks for ANY time that you host a channel (not just auto-host) and displays a
; ** message in your channel that you are currently hosting another channel.
; ** If you are hosting for more than 1 active viewer, it will also display that in the message.
; ** This also sets the %current.host variable needed for the rest of the script.

RAW *:*: {
  IF (($nick == tmi.twitch.tv) && (HOSTTARGET isin $rawmsg) && (%mychan isin $rawmsg)) {
    tokenize 32 $rawmsg
    IF ($chr(45) !isin $4) {
      SET %current.host $twitch_name($remove($4, :))
      IF (%current.host != $null) && ($5 isnum 2-) MSG %mychan We are now hosting %current.host for $5 active viewers!  Go visit them at twitch.tv/ $+ %current.host and say hello!
      ELSEIF (%current.host != $null) && ($5 isnum 0-1) MSG %mychan We are now hosting %current.host $+ !  Go visit them at twitch.tv/ $+ %current.host and say hello!
    }
  }
}

; ** This section will immediately run the autohost script as soon as the current host
; ** goes offline and auto-hosting is currently enabled (as long as the autohost script
; ** isn't already searching for another host).

RAW *:*: {
  IF ((%AutoHost == On) && (HOSTTARGET isin $rawmsg) && (%mychan isin $rawmsg) && ($chr(45) isin $rawmsg) && ($nick == tmi.twitch.tv) && (!%ah.run)) {
    timer.[AUTOHOST] 0 300 autohost
    autohost
  }
}

; ** This is the auto-host command.  When a mod on your channel sends a whisper to your bot with
; ** "!autohost on" or "!autohost off" it will enable or disable autohosting.
; **
; ** If a channel is currently being hosted when the "!autohost on" command is ran, it will add that
; ** channel as a temporary "Tier 1" channel, regardless of if it is in the autohost.txt file or not.
; ** This is a personal preference, as I generally don't want the autohost to start looking for other
; ** channels until the channel that I was just visiting has gone offline.  Modify it to your preference.
; **
; ** "!autohost on" sets a timer to run the autohost script every five minutes.

ON *:TEXT:!autohost &:?: {
  IF ($nick isop %mychan) {
    IF ($2 == on) {
      IF (!%AutoHost) {
        MSG $nick Auto-Host is now on!
        UNSET %current.host
        IF ($getcurrenthost == $true) {
          SET %ah.tier 1
          SET %ah.uptime $ctime
        }
        SET %AutoHost On
        .timer.[AUTOHOST] 0 300 autohost
        IF (!%current.host) autohost
      }
      ELSE MSG $nick Auto-host is already on!
    }
    IF ($2 == off) {
      IF (%AutoHost == On) {
        MSG $nick Auto-Host is now disabled!
        .timer.[AUTOHOST] off
        UNSET %AutoHost
      }
      ELSE MSG $nick Auto-host was not on!
    }
  }
}

; ** !nexthost will unhost the current host and force a search for a new host.

ON *:TEXT:!nexthost:?: {
  IF ($nick isop %mychan) {
    IF (%AutoHost == On) {
      IF (!%ah.run) {
        timer.[AUTOHOST] off
        UNSET %current.host
        MSG %mychan .unhost
        MSG $nick The current host has been skipped!  Now searching for another host!
        timer.[AUTOHOST] 0 300 autohost
      }
      ELSE MSG $nick Auto-Host is currently running!  Please try again in a few moments!
    }
    IF (%AutoHost == Off) MSG $nick Auto-Host is not on!
  }
}

; ** !settier # will force a temporary tier for the current host.

ON *:TEXT:!settier &:?: {
  IF ($nick isop %mychan) && ($2 isnum 1-3) {
    IF (!%ah.run) {
      SET %ah.tier $floor($2)
      MSG $nick The current host has been temporarily set as a Tier $2 host!
    }
    ELSE MSG $nick Auto-Host is currently running!  Please try again in a few moments!
  }
}

; ****** This is the main autohost script.  ******

alias autohost {

  SET %ah.run True

  ; ** two ways to check if the current host is live, as Twitch is prone to API
  ; ** downtime and other various malfunctions quite often.

  IF (($livechecker(%current.host) == $true) || ($getcurrenthost == $true)) VAR %still.live $true

  IF (%still.live) {
    IF (%ah.tier == 1) { UNSET %ah.run | halt }
    IF (%ah.tier == 2) && ($calc($ctime - %ah.uptime) < %t2.wait) { UNSET %ah.run | halt }
    IF (%ah.tier == 3) && ($calc($ctime - %ah.uptime) < %t3.wait) { UNSET %ah.run | halt }
  }

  VAR %x = 1
  WHILE ($wildtok($read(autohost.txt, n, 1), *, %x, 32) != $null) {
    VAR %ahn $wildtok($read(autohost.txt, n, 1), *, %x, 32)
    IF ($livechecker(%ahn) == $true) && ($rehostcheck(%ahn) != $true) && (%livechannel != %current.host) {
      SET %ah.tier 1
      autohost2
      halt
    }
    INC %x
  }

  IF (%still.live) && (%ah.tier == 2) { UNSET %ah.run | halt }
  VAR %x = 1
  WHILE ($wildtok($read(autohost.txt, n, 2), *, %x, 32) != $null) {
    VAR %ahn $wildtok($read(autohost.txt, n, 2), *, %x, 32)
    IF ($livechecker(%ahn) == $true) && ($rehostcheck(%ahn) != $true) && (%livechannel != %current.host) {
      SET %ah.tier 2
      autohost2
      halt
    }
    INC %x
  }

  IF (%still.live) && ((%ah.tier == 2) || (%ah.tier == 3)) { UNSET %ah.run | halt }
  VAR %x = 1
  WHILE ($wildtok($read(autohost.txt, n, 3), *, %x, 32) != $null) {
    VAR %ahn $wildtok($read(autohost.txt, n, 3), *, %x, 32)
    IF ($livechecker(%ahn) == $true) && ($rehostcheck(%ahn) != $true) && (%livechannel != %current.host) {
      SET %ah.tier 3
      autohost2
      halt
    }
    INC %x
  }
  UNSET %ah.run
}

alias autohost2 {
  MSG %mychan .host %livechannel
  SET %ah.uptime $ctime
  INC %no.rehost
  WRITE -l $+ %no.rehost norehost.txt %livechannel $ctime
  IF (%no.rehost == 20) %no.rehost = 0
  UNSET %livechannel
  .timer.unset.ah.run 1 10 UNSET %ah.run
}

; ****** These are the various aliases needed for the script to function.  ******

alias rehostcheck {
  VAR %rhcount = 1
  IF ($exists(norehost.txt)) {
    WHILE ($read(norehost.txt, %rhcount) != $null) {
      VAR %rhnick = $wildtok($read(norehost.txt, %rhcount), *, 1, 32)
      VAR %rhtime = $wildtok($read(norehost.txt, %rhcount), *, 2, 32)
      IF ($calc($ctime - %rhtime) < %rh.wait) && (%rhnick == $1) RETURN $true
      INC %rhcount
    }
  }
}

alias -l livechecker {
  IF (%tu == 1000) %tu = 0
  INC %tu
  JSONOpen -uw live $+ %tu https://api.twitch.tv/kraken/streams/ $+ $1 $+ ?nocache= $+ $ticks
  JSONUrlHeader live $+ %tu Client-ID avm4vi7zv0xpjkpi3d4x0qzk8xbrdw8
  JSONUrlGet live $+ %tu
  IF ( $json(live $+ %tu $+ ,stream) != $null ) {
    SET %livechannel $1
    VAR %x $true
  }
  JSONClose live $+ %tu
  IF (%x == $true) RETURN $true
}

alias getcurrenthost {
  JSONOpen -uw currenthost http://tmi.twitch.tv/hosts?host=83931881
  JSONUrlHeader currenthost Client-ID avm4vi7zv0xpjkpi3d4x0qzk8xbrdw8
  JSONUrlGet currenthost
  IF ( $json(currenthost, hosts, 0, target_id) != $null ) {
    JSONOpen -uw hostname https://api.twitch.tv/api/friendships/users?ids= $+ $v1
    JSONUrlHeader hostname Client-ID avm4vi7zv0xpjkpi3d4x0qzk8xbrdw8
    JSONUrlGet hostname
    SET %current.host $json(hostname, users, 0, display_name)
    VAR %x $true
    JSONClose hostname
  }
  JSONClose currenthost
  IF (%x == $true) RETURN $true
}
