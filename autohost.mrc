;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BLASBOT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;; TWITCH.TV/BLASMAN13 ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;; AUTOHOST VERSION 2.0.0.3 ;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Online Documentation @ https://github.com/Blasman/mIRC-Twitch-Scripts/wiki/Script-Documentation#advanced-autohost-version-2

; UNCOMMENT the line below (remove the ; at the start) if you are not requesting capabilities from the Twitch server in another script that you are running.
;ON *:CONNECT: IF ($server == tmi.twitch.tv) CAP REQ :twitch.tv/commands twitch.tv/tags twitch.tv/membership

alias autohost_version RETURN 2.0.0.3

ON *:LOAD: autohost_setup

alias autohost_setup {
  IF (!$isfile(autohost.txt)) WRITE -l1 autohost.txt
  IF (!%ah_rehost) SET %ah_rehost 28800
  IF (!%ah_tiers) SET %ah_tiers 3600,3600
  IF (!%ah_repeat) SET %ah_repeat 300
  IF (!%ah_grace) SET %ah_grace 300
  IF (!%ah_random) SET %ah_random $false
  IF (!%ah_hostmsg) SET %ah_hostmsg $true
  IF (!%ah_unhost_disables) SET %ah_unhost_disables $false
  IF (!%ah_modaccess) SET %ah_modaccess $true
  IF (!%ah_enable_tier_01) SET %ah_enable_tier_01 1
  IF (!%ah_enable_tier_02) SET %ah_enable_tier_02 -1
  IF (!%ah_forceswitch) SET %ah_forceswitch 0
  IF (!%ah_msg) SET %ah_msg $true
  $dialog(welcome,welcome)
  autohost_channel
  autohost_rehost
  autohost_tiers
  autohost_repeat
  autohost_grace
  autohost_random
  autohost_hostmsg
  autohost_unhost
  autohost_modaccess
  autohost_enable_tier_01
  autohost_enable_tier_02
  autohost_forceswitch
  $dialog(finish,finish)
}

dialog -l welcome {
  title "Welcome to Blasman13's Autohost Script Setup"
  size -1 -1 265 122
  option dbu
  text "This script is a multi tier based auto-hosting script for Twitch.TV. To use it, you must edit the autohost.txt file in your mIRC directory. Put all of the channels that you want to auto-host on any line in autohost.txt. All channels on line 1 will be Tier 1. All channels on line 2 will be Tier 2. All channels on line 3 will be Tier 3. Etc. Seperate channel names with a space. When the autohost is enabled, it will search each tier in the order that channels are listed. If a Tier 1 channel is still live and being hosted, the script will simply end. If a Tier 2 channel is still live and being hosted, the script will look for a Tier 1 channel to host if the amount of time passed since the host began is greater than the time specified during setup. If a Tier 3 channel is still live and being hosted, the script will look for a Tier 1 then Tier 2 channel to host if the amount of time passed since the host began is greater than the time specified during setup. You may have as many tiers as desired. You may configure any of the Autohost Script settings by right clicking on your status or channel window in mIRC. Please see the online documentation for more info.", 1, 12 10 239 84
  button "Okay", 3, 110 95 50 16, ok
}

dialog -l finish {
  title "Thank You"
  size -1 -1 140 60
  option dbu
  text "Thank you for using Blasman13's mIRC Autohost Script! You may change any of the options set during this setup by right clicking in your mIRC status or channel windows and selecting the 'Autohost' context menu.", 1, 3 3 130 40
  button "Okay", 3, 50 45 40 12, ok
}

menu menubar,channel,status {
  AutoHost
  .$style(2) Version $autohost_version:$null
  .!AutoHost is $IIF(%autohost,ON,OFF) [click to $IIF(%autohost,disable,enable) $+ ]:autohost_switch
  .Announce in channel when AutoHost is enabled/disabled with the above option is set to $IIF(%ah_msg,ON,OFF) [click to $IIF(%ah_msg,disable,enable) $+ ]:autohost_msg_switch
  .Click to EDIT autohost.txt file:RUN autohost.txt
  .Channel $chr(91) $+ %ah_channel $+ $chr(93):autohost_channel
  .Display message in chat when hosting a channel is $IIF(%ah_hostmsg,ON,OFF) [click to $IIF(%ah_hostmsg,disable,enable) $+ ]:autohost_hostmsg_switch
  .Randomize the channels in each tier is $IIF(%ah_random,ON,OFF) [click to $IIF(%ah_random,disable,enable) $+ ]:autohost_random_switch
  .Minimum time between hosting the same channel $chr(91) $+ $duration(%ah_rehost) $+ $chr(93):autohost_rehost
  .Minimum time to host each tier of hosts (beginning with tier 2)
  ..CLICK HERE TO CONFIGURE:autohost_tiers
  ..$submenu($_autohost_tiers($1))
  .How often to repeat searching for new hosts $chr(91) $+ $duration(%ah_repeat) $+ $chr(93):autohost_repeat
  .Length of the autohost "grace" period $chr(91) $+ $IIF(%ah_grace,$duration(%ah_grace),OFF) $+ $chr(93):autohost_grace
  .Performing /unhost will turn off the autohost if it is active is set to $IIF(%ah_unhost_disables,TRUE,FALSE) $+ . [click to $IIF(%ah_unhost_disables,disable,enable) $+ ]:autohost_unhost_switch
  .Channel Moderators also have access to the autohost commands is set to $IIF(%ah_modaccess,TRUE,FALSE) $+ . [click to $IIF(%ah_modaccess,disable,enable) $+ ]:autohost_modaccess_switch
  .Default temporary tier for current host when starting the Autohost
  ..If channel is NOT in the autohost.txt file $+ $chr(44) set tier to $chr(91) $+ %ah_enable_tier_01 $+ $chr(93):autohost_enable_tier_01
  ..If channel IS in the autohost.txt file $+ $chr(44) set tier to $chr(91) $+ %ah_enable_tier_02 $+ $chr(93):autohost_enable_tier_02
  .Force search for new host on any tier $IIF(%ah_forceswitch isnum 0,after X amount of time is DISABLED,after $duration(%ah_forceswitch)) $+ .:autohost_forceswitch
  .Visit Online Documentation by clicking here:url -m https://github.com/Blasman/mIRC-Twitch-Scripts/wiki/Script-Documentation#advanced-autohost-version-2
}

alias -l _autohost_tiers {
  IF ($1 == begin) { RETURN - }
  IF ($1 == end) { RETURN - }
  IF ($gettok(%ah_tiers,$1,44)) { RETURN $style(2) Tier $calc($1 + 1) $IIF($1 == 1,$chr(32) $chr(47) Default) = $duration($gettok(%ah_tiers,$1,44)) : $v1 }
}

alias -l autohost_switch {
  IF (!%autohost) {
    autohost_enable
    IF (%ah_msg) MSG %ah_channel Autohost is now enabled!
    ELSE ECHO -a Autohost is now enabled!
  }
  ELSE {
    autohost_disable
    IF (%ah_msg) MSG %ah_channel Autohost is now disabled!
    ELSE ECHO -a Autohost is now disabled!
  }
}

alias -l autohost_random_switch {
  IF (!%ah_random) SET %ah_random $true
  ELSE SET %ah_random $false
}

alias -l autohost_msg_switch {
  IF (!%ah_msg) SET %ah_msg $true
  ELSE SET %ah_msg $false
}

alias -l autohost_hostmsg_switch {
  IF (!%ah_hostmsg) SET %ah_hostmsg $true
  ELSE SET %ah_hostmsg $false
}

alias -l autohost_unhost_switch {
  IF (!%ah_unhost_disables) SET %ah_unhost_disables $true
  ELSE SET %ah_unhost_disables $false
}

alias -l autohost_modaccess_switch {
  IF (!%ah_modaccess) SET %ah_modaccess $true
  ELSE SET %ah_modaccess $false
}

alias autohost_channel {
  :start
  $input(Input the name of your Twitch channel that you will be hosting from:,eof,Required Input,%ah_channel)
  IF ($regex($!,^#?(\w+)$)) {
    SET %ah_channel $chr(35) $+ $regml(1)
    SET %ah_twitchid $twitch_id($regml(1))
  }
  ELSE { ECHO You need to input a valid name for your channel! | GOTO start }
}

alias autohost_rehost {
  :start
  $input(Input the amount of time $chr(40) $+ in seconds $+ $chr(41) that you want the autohost script to wait before being allowed to host the same channel again from when you last started a host on that channel. $chr(40) $+ 28800 = 8 Hours $+ $chr(41) $+ :,eof,Required Input,%ah_rehost)
  IF ($regex($!,^\d+$)) SET %ah_rehost $floor($!)
  ELSEIF ($! == $false) RETURN
  ELSE { ECHO You need to input a numeric value for the rehost time! | GOTO start }
}

alias autohost_tiers {
  :start
  $input(Input the minimum length of time $chr(40) $+ in seconds $+ $chr(41) for a channel to remain hosted for each tier $chr(40) $+ line of text $+ $chr(41) in the autohost.txt file $+ $chr(44) beginning with tier 2. $chr(40) $+ tier 1 channels stay hosted until they go offline or you manually unhost them $+ $chr(41) $+ . Seperate each number with a comma. If no number is specified for a tier $+ $chr(44) then the wait time for tier 2 is used as the default wait time.,eof,Required Input,%ah_tiers)
  IF ($regex($!,\d+)) SET %ah_tiers $!
  ELSEIF ($! == $false) RETURN
  ELSE { ECHO You need to input the wait times for each tier! | GOTO start }
}

alias autohost_repeat {
  :start
  $input(Input how often $chr(40) $+ in seconds $+ $chr(41) that you want the autohost script to re-search for a new host when the autohost is enabled:,eof,Required Input,%ah_repeat)
  IF ($regex($!,^\d+$)) SET %ah_repeat $floor($!)
  ELSEIF ($! == $false) RETURN
  ELSE { ECHO You need to input a numeric value for the repeat time! | GOTO start }
}

alias autohost_grace {
  :start
  $input(Input how long $chr(40) $+ in seconds $+ $chr(41) that you want to wait to see if a channel that you are hosting that has just recently gone offline will come back online. Useful in the event that a channel is having technically difficulties and has only momentarily gone offline. Set to 0 to disable:,eof,Required Input,%ah_grace)
  IF ($regex($!,^\d+$)) SET %ah_grace $floor($!)
  ELSEIF ($! == $false) RETURN
  ELSE { ECHO You need to input a numeric value for the autohost grace time! | GOTO start }
}

alias autohost_random {
  :start
  $input(Do you want the channels in each tier to be hosted in random order?,nv,Required Input)
  IF ($! == $yes) SET %ah_random $true
  ELSEIF ($! == $no) SET %ah_random $false
  ELSE RETURN
}

alias autohost_hostmsg {
  :start
  $input(Do you want to display a message in chat when you begin to a host a channel? $chr(40) $+ works when Autohost is off as well $+ $chr(41) $crlf $crlf $+ Eg. "We are now hosting Blasman13 who is playing Watch Dogs for 69 viewers. Uptime: 4hrs 20mins. You can visit them at twitch.tv/Blasman13",nv,Required Input)
  IF ($! == $yes) SET %ah_hostmsg $true
  ELSEIF ($! == $no) SET %ah_hostmsg $false
  ELSE RETURN
}

alias autohost_unhost {
  :start
  $input(Do you want the /unhost command to also disable the autohost script if it is currently active?,nv,Required Input)
  IF ($! == $yes) SET %ah_hostmsg $true
  ELSEIF ($! == $no) SET %ah_hostmsg $false
  ELSE RETURN
}

alias autohost_modaccess {
  :start
  $input(Do you want channel moderators to also be able to use the autohost commands in addition to the streamer?,nv,Required Input)
  IF ($! == $yes) SET %ah_modaccess $true
  ELSEIF ($! == $no) SET %ah_modaccess $false
  ELSE RETURN
}

alias autohost_enable_tier_01 {
  :start
  $input(What would you like the default tier to be for the current host if it is *NOT* a channel that is in your autohost.txt file when enabling the Autohost?,eof,Required Input,%ah_enable_tier_01)
  IF ($regex($!,^\d+$)) SET %ah_enable_tier_01 $floor($!)
  ELSEIF ($! == $false) RETURN
  ELSE { ECHO You need to input a numeric value for tier number! | GOTO start }
}

alias autohost_enable_tier_02 {
  :start
  $input(What would you like the default tier to be for the current host if it *IS* a channel that is in your autohost.txt file when enabling the Autohost? Set to 0 to use the tier number for the host from the autohost.txt file. Set to -1 to use the default tier number from the previous question $chr(40) $+ currently tier %ah_enable_tier_01 $+ $chr(41),eof,Required Input,%ah_enable_tier_02)
  IF (($regex($!,^\d+$)) || ($! == -1)) SET %ah_enable_tier_02 $floor($!)
  ELSEIF ($! == $false) RETURN
  ELSE { ECHO You need to input a numeric value for tier number! | GOTO start }
}

alias autohost_forceswitch {
  :start
  $input(If you would like to force searching for a new host on ANY tier after a specified length of time of hosting the current host $+ $chr(44) please specify the length of time $chr(40) $+ in seconds $+ $chr(41) $+ . Set to 0 to disable.,eof,Required Input,%ah_forceswitch)
  IF ($regex($!,^\d+$)) SET %ah_forceswitch $floor($!)
  ELSEIF ($! == $false) RETURN
  ELSE { ECHO You need to input a numeric value for tier number! | GOTO start }
}

ON $*:TEXT:/^!autohost\s(on|off)$/iS:*: {
  IF ($AccessCheck) {
    VAR %target $get_target
    IF ($2 == on) {
      IF (!%autohost) {
        autohost_enable
        MSG %target Autohost is now on!
      }
      ELSE MSG %target Autohost is already on!
    }
    IF ($2 == off) {
      IF (%autohost) {
        autohost_disable
        MSG %target Autohost is now disabled!
      }
      ELSE MSG %target Autohost was not on!
    }
  }
}

ON $*:TEXT:/^!settier\s\d+$/iS:*: {
  IF (($AccessCheck) && ($2 isnum 1 - $lines(autohost.txt))) {
    VAR %target $get_target
    IF (!%ah_run) {
      SET %host.tier $floor($2)
      MSG $nick The current host has been temporarily set as a Tier %host.tier host!
    }
    ELSE MSG $nick Autohost is currently running! Please try again in a few moments!
  }
}

ON *:TEXT:!nexthost:?: {
  IF ($AccessCheck) {
    VAR %target $get_target
    IF (%autohost) {
      IF (!%ah_run) {
        timer.AUTOHOST off
        UNSET %host.tier
        MSG %target Now trying to find a new host! If and when a new live host is found, it will replace the current host.
        autohost
        timer.AUTOHOST 0 %ah_repeat autohost
      }
      ELSE MSG %target Autohost is currently running! Please try again in a few moments!
    }
    ELSE MSG %target Autohost is not on!
  }
}

ON *:TEXT:!hostinfo:%mychan: {
  IF ($AccessCheck) {
    VAR %target $get_target
    IF (%host.name) {
      hostinfo %host.name
      MSG %target We have been hosting %host.name for $duration($calc($ctime - %host.uptime),2) $+ . They are playing %host.game for %host.viewers viewers. Uptime: %host.created_at $+ . You can visit them at twitch.tv/ $+ %host.name
    }
    ELSE MSG %target We do not appear to be hosting anyone at the moment!
  }
}

alias autohost_enable {
  SET %autohost $true
  IF (%host.name) VAR %livechecker $livechecker(%host.name)
  IF ((%host.name) && (%livechecker) && (%livechecker != $offline)) {
    VAR %x = 1,%tier = %ah_enable_tier_01
    IF (%ah_enable_tier_02 !isnum -1) {
      WHILE ($read(autohost.txt,%x)) {
        IF ($istok($v1,%host.name,32)) {
          IF (%ah_enable_tier_02 isnum 0) VAR %tier %x
          ELSE VAR %tier %ah_enable_tier_02
          BREAK
        }
        INC %x
      }
    }
    IF (!%host.uptime) SET %host.uptime $ctime
    SET %host.tier %tier
  }
  ELSE autohost
  .timer.AUTOHOST 0 %ah_repeat autohost
}

alias autohost_disable {
  UNSET %autohost
  IF ($timer(.AUTOHOST)) .timer.AUTOHOST off
  IF ($timer(.ah_grace)) .timer.ah_grace off
  IF ($timer(.ah_run_wait)) .timer.ah_run_wait off
}

alias -l get_target {
  IF ($target == %ah_channel) RETURN $target
  ELSEIF ($target == $me) RETURN $nick
  ELSE HALT
}

RAW HOSTTARGET:*: {
  TOKENIZE 32 $rawmsg
  IF (($3 == %ah_channel) && ($regex($4,/:(\w+)/)) && (%host.name != $regml(1))) {
    SET %host.name $twitch_name($regml(1))
    SET %host.uptime $ctime
    IF (%ah_hostmsg) {
      hostinfo %host.name
      MSG %ah_channel We are now hosting %host.name $IIF($5 > 1,for $5 active viewers) who is playing %host.game for %host.viewers viewers. Uptime: %host.created_at $+ . You can visit them at twitch.tv/ $+ %host.name
    }
  }
}

alias -l hostinfo {
  JSONOpen -uw hostinfo https://api.twitch.tv/kraken/streams/ $+ $1
  JSONHttpHeader hostinfo Client-ID avm4vi7zv0xpjkpi3d4x0qzk8xbrdw8
  JSONHttpFetch hostinfo
  IF ($json(hostinfo, stream).value == null) { SET %host.name ???? | SET %host.game ???? | SET %host.viewers ???? | SET %host.uptime ???? }
  ELSE {
    SET %host.name $json(hostinfo, stream, channel, display_name).value
    SET %host.game $json(hostinfo, stream, game).value
    SET %host.viewers $json(hostinfo, stream, viewers).value
    SET %host.created_at $duration($calc($ctime - $TwitchTime($JSON(hostinfo, stream, created_at).value)),2)
  }
  JSONClose hostinfo
}

ON *:NOTICE:*:%ah_channel: {
  IF (($msgtags(msg-id).key == host_target_went_offline) || ($msgtags(msg-id).key == host_off)) {
    IF (!%ah_run) unhosted $msgtags(msg-id).key %host.name
    ELSE .timer.ah_run_wait 0 1 ah_run_wait $msgtags(msg-id).key %host.name
  }
}

alias unhosted {
  UNSET %host.*
  IF ($timer(.ah_run_wait)) .timer.ah_run_wait off
  IF (%autohost) {
    .timer.AUTOHOST off
    IF ((%ah_unhost_disables) && ($1 == host_off)) autohost_disable
    ELSEIF (($1 == host_target_went_offline) && (%ah_grace > 0)) .timer.ah_grace 1 %ah_grace ah_grace $2
    ELSE {
      autohost
      .timer.AUTOHOST 0 %ah_repeat autohost
    }
  }
}

alias ah_grace {
  IF (%autohost) {
    VAR %x = 1,%still.live $livechecker($1)
    IF ((%still.live) && (%still.live != $offline)) MSG %ah_channel .host $1
    ELSE autohost
    .timer.AUTOHOST 0 %ah_repeat autohost
  }
}

alias ah_run_wait IF (!%ah_run) unhosted $1

alias autohost {
  IF ($hget(autohost)) HFREE autohost
  SET %ah_run $true
  VAR %x = 1, %still.live
  IF (%host.name) {
    IF ($am_i_hosting) VAR %still.live $true
    ELSE {
      VAR %double.check $livechecker(%host.name)
      IF ((%double.check) && (%double.check != $offline)) VAR %still.live $true
    }
  }
  IF ((%still.live) && (%host.tier) && ((!%ah_forceswitch) || ((%ah_forceswitch) && ($calc($ctime - %host.uptime) <= %ah_forceswitch)))) {
    IF (%host.tier == 1) { UNSET %ah_run | RETURN }
    ELSE {
      IF ($gettok(%ah_tiers,$calc(%host.tier - 1),44)) VAR %rh_time $v1
      ELSE VAR %rh_time $gettok(%ah_tiers,1,44)
      IF ($calc($ctime - %host.uptime) <= %rh_time) { UNSET %ah_run | RETURN }
    }
  }
  ELSE UNSET %host.*
  VAR %x = 1, %offset
  WHILE ((%x <= $lines(autohost.txt)) && (((%x < %host.tier) || (!%host.tier)) || ((%ah_forceswitch) && ($calc($ctime - %host.uptime) >= %ah_forceswitch)))) {
    IF (%ah_random) HADD -m autohost sorted_list $randomize($read(autohost.txt,nt,%x))
    ELSE HADD -m autohost sorted_list $read(autohost.txt,nt,%x)
    :search
    VAR %list $livechecker($gettok($hget(autohost,sorted_list),$calc(1 + %offset) - $calc(100 + %offset),32))
    IF ((%list) && (%list != $offline)) {
      VAR %y = 1
      WHILE ($gettok($hget(autohost,sorted_list),%y,32)) {
        VAR %name $v1
        IF (($istok(%list,%name,32)) && (%name != %host.name) && ($calc($ctime - $readini(hosts.ini,%name,Last_Hosted)) > %ah_rehost)) {
          MSG %ah_channel .host %name
          SET %host.tier %x
          SET %host.uptime $ctime
          WRITEINI hosts.ini %name Last_Hosted %host.uptime
          WRITEINI hosts.ini %name Times_Hosts $calc($readini(hosts.ini,%name,Times_Hosts) + 1)
          .timer.unset.ah.run 1 6 UNSET %ah_run
          HFREE autohost
          RETURN
        }
        INC %y
      }
    }
    IF ($numtok($hget(autohost,sorted_list),32) > $calc(%offset + 100)) {
      VAR %offset = %offset + 100
      GOTO search
    }
    HFREE autohost
    INC %x
  }
  UNSET %ah_run
}

alias -l AccessCheck {
  IF ($nick == $remove(%ah_channel,$chr(35))) RETURN $true
  ELSEIF ((%ah_modaccess) && (($msgtags(mod).key == 1) || ($nick isop %ah_channel))) RETURN $true
}

alias -l livechecker {
  IF (%lc == 100) %lc = 0
  INC %lc
  JSONOpen -uw live $+ %lc https://api.twitch.tv/kraken/streams/?limit=100&nocache= $+ %lc $+ &channel= $+ $replace($1-,$chr(32),$chr(44))
  JSONHttpHeader live $+ %lc Client-ID avm4vi7zv0xpjkpi3d4x0qzk8xbrdw8
  JSONHttpFetch live $+ %lc
  VAR %total, %list, %x = 0
  VAR %total $json(live $+ %lc,_total).value
  WHILE (%total > %x) {
    VAR %list %list $json(live $+ %lc,streams, %x, channel, name).value
    INC %x
  }
  JSONClose live $+ %lc
  IF (%total isnum 0) RETURN $offline
  IF (%list != $null) RETURN %list
}

alias -l twitch_name {
  JSONOpen -uw twitch_name https://api.twitch.tv/kraken/channels/ $+ $1 $+ ?nocache= $+ $ticks
  JSONHttpHeader twitch_name Client-ID avm4vi7zv0xpjkpi3d4x0qzk8xbrdw8
  JSONHttpFetch twitch_name
  VAR %x $json(twitch_name, display_name).value
  JSONClose twitch_name
  IF ($1 == %x) RETURN %x
  ELSEIF (%x != $null) RETURN $1
}

alias -l am_i_hosting {
  JSONOpen -ud currenthost http://tmi.twitch.tv/hosts?include_logins=1&host= $+ %ah_twitchid
  RETURN $JSON(currenthost, hosts, 0, target_display_name).value
}

alias -l twitch_id {
  JSONOpen -uw twitch_id https://api.twitch.tv/kraken/channels/ $+ $1
  JSONHttpHeader twitch_id Client-ID avm4vi7zv0xpjkpi3d4x0qzk8xbrdw8
  JSONHttpFetch twitch_id
  VAR %x $json(twitch_id, _id).value
  JSONClose twitch_id
  RETURN %x
}

alias -l randomize {
  VAR %txt = $1-,%result,%total = 0
  WHILE $numtok(%txt,32) > 0 {
    INC %total
    VAR %i = $rand(1,$v1) , %result = $instok(%result,$gettok(%txt,%i,32),%total +1,32) , %txt = $deltok(%txt,%i,32)
  }
  RETURN %result
}

; TwitchTime alias written by SReject and friends
alias -l TwitchTime {
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
