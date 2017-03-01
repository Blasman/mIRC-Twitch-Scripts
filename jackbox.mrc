;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BLASBOT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;; CREATED BY BLASMAN13 ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;; TWITCH.TV/BLASMAN13 ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;; JACKBOX PARTY PACK SCRIPT ;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;; VERSION 1.0.0.1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON *:LOAD: jackbox_setup

dialog jackbox_important {
  title "IMPORTANT!"
  size -1 -1 200 60
  option dbu
  text "You are NOT running the latest version of BlasBot.mrc from Blasman's GitHub. This script will NOT work for you until you install it! Setup will exit once you click Okay.", 1, 8 8 180 30
  button "Okay", 3, 80 45 40 12, ok
}

alias jackbox_setup {
  IF ($blasbot_version < 1.0.0.6) {
    $dialog(jackbox_important,jackbox_important)
    url -m https://github.com/Blasman/mIRC-Twitch-Scripts/wiki/Script-Documentation
    unload -rs jackbox.mrc
    halt
  }
  IF (!%jackbox_subtimer) SET %jackbox_subtimer 30
  IF (!%jackbox_permissions) SET %jackbox_permissions fomm60
  subtimer
  permissions
}

menu menubar,channel,status {
  Jackbox Party Pack
  .$get_permissions [click to change]:permissions
  .'Sub Timer' is $gettimer [click to change]:subtimer
  .Restriction Exempt Users
  ..EDIT LIST:exempt
  ..$submenu($_exempt($1))
  .Banned Users
  ..EDIT LIST:banned
  ..$submenu($_banned($1))
  .Click Here to Visit Online Documentation:URL -m https://github.com/Blasman/mIRC-Twitch-Scripts/wiki/Script-Documentation#jackbox-party-pack-helper
}

alias -l exempt {
  $input(Input the list of restriction exempt users when requesting a !code $chr(40) $+ seperate with spaces $+ $chr(41):,eof,Required Input,$sorttok(%jackbox_allow,32))
  IF ($!) SET %jackbox_allow $sorttok($!,32)
  ELSEIF ($! == $false) RETURN
  ELSE UNSET %jackbox_allow
}

alias -l banned {
  $input(Input the list of banned users from requesting a !code $chr(40) $+ seperate with spaces $+ $chr(41):,eof,Required Input,$sorttok(%jackbox_deny,32))
  IF ($!) SET %jackbox_deny $sorttok($!,32)
  ELSEIF ($! == $false) RETURN
  ELSE UNSET %jackbox_deny
}

alias -l _exempt {
  IF ($1 == begin) { RETURN - }
  IF ($1 == end) { RETURN - }
  IF ($gettok($sorttok(%jackbox_allow,32),$1,32)) { RETURN $style(2) $ifmatch : $ifmatch }
}

alias -l _banned {
  IF ($1 == begin) { RETURN - }
  IF ($1 == end) { RETURN - }
  IF ($gettok($sorttok(%jackbox_deny,32),$1,32)) { RETURN $style(2) $ifmatch : $ifmatch }
}

alias -l gettimer {
  IF (%jackbox_subtimer) RETURN set to %jackbox_subtimer seconds.
  ELSE RETURN DISABLED.
}

alias -l subtimer {
  :start
  $input(Input how long $chr(40) $+ in seconds $+ $chr(41) that non-subscribers of the channel have to wait before being whispered the code after the option to request a code is enabled $chr(40) $+ set to 0 to disable $+ $chr(41):,eof,Required Input,%jackbox_subtimer)
  IF ($regex($!,^\d+$)) SET %jackbox_subtimer $floor($!)
  ELSEIF ($! == $false) RETURN
  ELSE { ECHO You need to input a numeric value! | GOTO start }
}

alias -l permissions {
  :start
  $input(Please specify the criteria required for a user to be eligable to request the code to be whispered to them by typing !code in chat. Type all that apply in the editbox. "fo" for Follower of the channel -or- "fo#" for Follower of the channel for at least # number of minutes. "su" for subscriber of the channel. "re" for Regular in AnkhBot. "mm#" for minimum minutes. "mp#" for minimum points. Example: fomm60 would mean that the user needs to be a follower and have spent at least 60 minutes in the channel to be eligiable to receive a code using !code.,eof,Required Input,%jackbox_permissions)
  IF ((fo isin $!) || ($regex($!,/mm(\d+)/)) || ($regex($!,/mp(\d+)/)) || (su isin $!) || (re isin $!) || ($! isnum 0)) SET %jackbox_permissions $remove($!,$chr(34))
  ELSEIF (($! == $false) && ((%jackbox_permissions) || (%jackbox_permissions isnum 0)) RETURN
  ELSE { ECHO You need to input something! | GOTO start }
}

; mod only command to change required permissions for a user to request a !code
ON $*:TEXT:/^!jackbox\s(((perm|timer)\s)|help)/iS:%mychan: {
  IF ($ModCheck) {
    IF (($2 == perm) && (((fo isin $3) || ($regex($3,/mm\d+/)) || ($regex($3,/mp\d+/)) || (su isin $3) || ($3 isnum 0)))) {
      SET %jackbox_permissions $remove($3,$chr(34))
      IF (%jackbox_permissions) MSG $chan $get_permissions
      ELSE MSG $chan Anyone can now request a !code for the Jackbox Party Pack!
    }
    ELSEIF (($2 == timer) && ($regex($3,^\d+$))) {
      SET %jackbox_subtimer $floor($3)
      IF (%jackbox_subtimer) MSG $chan Non-Subscribers will receive the !code %jackbox_subtimer seconds after Subscribers do.
      ELSE MSG $chan There is no waiting time to receive a !code for the Jackbox Party Pack.
    }
    ELSEIF ($2 == help) MSG $chan Jackbox Party Pack Helper Online Documentation: https://github.com/Blasman/mIRC-Twitch-Scripts/wiki/Script-Documentation#jackbox-party-pack-helper
  }
}

alias -l get_permissions {
  VAR %perm
  IF (fo isin %jackbox_permissions) {
    IF (($regex(%jackbox_permissions,/fo(\d+)/)) && ($regml(1) > 0)) VAR %perm %perm Follower for at least $regml(1) minutes $+ $chr(44)
    ELSE VAR %perm %perm Follower $+ $chr(44)
  }
  IF (su isin %jackbox_permissions) VAR %perm %perm Subscriber $+ $chr(44)
  IF (re isin %jackbox_permissions) VAR %perm %perm Regular $+ $chr(44)
  IF ($regex(%jackbox_permissions,/mp(\d+)/)) VAR %perm %perm Min_ $+ %curname $+ : $regml(1) $+ $chr(44)
  IF ($regex(%jackbox_permissions,/mm(\d+)/)) VAR %perm %perm Min_Hours: $calc($regml(1) / 60) $+ $chr(44)
  IF (%perm != $null) RETURN To request a !code $+ $chr(44) you must meet the following requirements: $left(%perm,-1) $+ .
  ELSE RETURN Anyone may request a !code.
}

; when a mod whispers "!code XXXX" to the bot, the script is ran
ON *:TEXT:*:?: {
  IF (($1 == !code) && ($regex($2,^\w{4}$)) && ($ModCheck)) {
    SET %jackbox.code $upper($2)
    VAR %perm, %sub
    IF (%jackbox_permissions) VAR %perm $get_permissions
    IF ((%jackbox_subtimer) && (su !isin %jackbox_permissions)) {
      VAR %sub Subscribers will receive the code immediately. Non-Subscribers will receive the code in %jackbox_subtimer seconds from now.
      .timer.jackbox 1 %jackbox_subtimer MSG %mychan 📢 The Jackbox Code to enter the game is now being sent to all Non-Subscribers who have requested it! Anyone may still request a code using !code. %perm
    }
    MSG %mychan 📢 The Jackbox Party Pack !code has been entered into the bot by $nick $+ . Type !code in chat to request the code. %perm %sub
  }
}

; if script is active, viewers can request the code by typing "!code" in the channel chat
ON $*:TEXT:/^!code$/iS:%mychan: {
  IF ((%jackbox.code) && (!$($+(%,jackbox.,$nick),2))) {
    SET %jackbox. [ $+ [ $nick ] ] On
    IF ($istok(%jackbox_deny,$nick,32)) HALT
    IF ($isSub) msg_allow
    ELSE {
      IF ($istok(%jackbox_allow,$nick,32)) msg_allow nonsub
      IF ((su isin %jackbox_permissions) && (!$isSub)) msg_deny
      IF ((re isin %jackbox_permissions) && (!$isRegular)) msg_deny
      IF (($regex(%jackbox_permissions,/mp(\d+)/)) && ($GetPoints < $regml(1))) msg_deny
      IF (($regex(%jackbox_permissions,/mm(\d+)/)) && ($GetMinutes < $regml(1))) msg_deny
      IF (fo isin %jackbox_permissions) {
        IF ($FollowCheck) VAR %time $v1
        ELSE msg_deny
        IF (($regex(%jackbox_permissions,/fo(\d+)/)) && ($calc(($ctime - $TwitchTime(%time)) / 60) < $regml(1))) msg_deny
      }
      msg_allow nonsub
    }
  }
}

ON $*:TEXT:/^!invite\s/iS:%mychan: {
  IF ((%jackbox.code) && ($ModCheck)) {
    VAR %x = 1 , %list
    WHILE (%x < $0) {
      IF ($twitch_name($gettok($2-,%x,32))) {
        VAR %nick $v1
        $wdelay(MSG %nick %nick $+ $chr(44) the code is: %jackbox.code $+ . Please enter this code on jackbox.tv to enter the game. Use your Twitch login by selecting the option in the settings menu.)
        VAR %list %list %nick $+ $chr(44)
      }
      INC %x
    }
    IF (%list != $null) MSG $chan Successfully whispered the !code to $MakeList(%list) $+ .
  }
}

alias -l msg_allow {
  VAR %msg $nick $+ $chr(44) the code is: %jackbox.code $+ . Please enter this code on jackbox.tv to enter the game. Use your Twitch login by selecting the option in the settings menu.
  IF (($timer(.jackbox)) && ($1 == nonsub)) .timer.jackbox. [ $+ [ $nick ] ] 1 $timer(.jackbox).secs $wdelay(MSG $nick %msg)
  ELSE $wdelay(MSG $nick %msg)
  HALT
}

alias -l msg_deny {
  $wdelay(MSG $nick $nick $+ $chr(44) you do not meet the requirments to be allowed to receive a code.)
  HALT
}

; when the jackbox game is ready to play, a mod can type "!allin" in the channel chat to display the code to everyone in chat to join the audience
ON $*:TEXT:/^!allin$/iS:%mychan: {
  IF (($ModCheck) && (%jackbox.code)) {
    IF ($timer(.jackbox)) .timer.jackbox* off
    MSG $chan 📢 Everyone has entered the Jackbox Party Pack game. The audience may now join the game by visiting http://jackbox.tv and entering the following code: %jackbox.code $+ .
    UNSET %jackbox.*
  }
}

; if a mod types "!cancel" in chat, it will cancel the script processing
ON $*:TEXT:/^!cancel$/iS:%mychan: {
  IF (($ModCheck) && (%jackbox.code)) {
    IF ($timer(.jackbox)) .timer.jackbox* off
    MSG $chan 📢 The current Jackbox Party Pack game has been cancelled. Sorry! BrokeBack
    UNSET %jackbox.*
  }
}

; general info command usable by anyone
ON $*:TEXT:/^!jackbox$/iS:%mychan: {
  IF (!%jackbox_cd) {
    SET -eu6 %jackbox_cd On
    MSG $chan 📢 Anyone can join the current Jackbox Party Pack game by visiting http://jackbox.tv and using the CODE that is currently displayed on the stream.
  }
}

; mod command to allow specific users to bypass requirments needed to request a code in chat
ON $*:TEXT:/^!allow\s(add|rem(ove)?)\s\w+$/iS:%mychan: {
  IF ($ModCheck) {
    IF ($twitch_name($3)) {
      VAR %name $v1
      IF ($2 == add) {
        IF (!$istok(%jackbox_allow,%name,32)) {
          SET %jackbox_allow %jackbox_allow %name
          MSG $chan %name is now exempt from all restrictions to request a !code to Jackbox Party Pack games.
        }
        ELSE MSG $chan %name is already on the list of Jackbox Party Pack allowed users.
      }
      ELSEIF ($regex($2,/^rem(ove)?$/iS)) {
        IF ($istok(%jackbox_allow,%name,32)) {
          SET %jackbox_allow $remtok(%jackbox_allow,%name,0,32)
          MSG $chan %name has now been removed from the list of Jackbox Party Pack !code request restrictions exempt users.
        }
        ELSE MSG $chan %name was not on the list of Jackbox Party Pack allowed users.
      }
    }
    ELSE MSG $chan $nick $+ , $3 is not a valid user on Twitch.
  }
}

; mod command to deny specific users from requesting a code in chat
ON $*:TEXT:/^!deny\s(add|rem(ove)?)\s\w+$/iS:%mychan: {
  IF ($ModCheck) {
    IF ($twitch_name($3)) {
      VAR %name $v1
      IF ($2 == add) {
        IF (!$istok(%jackbox_deny,%name,32)) {
          SET %jackbox_deny %jackbox_deny %name
          MSG $chan %name can no longer request a !code to enter the Jackbox Party Pack games.
        }
        ELSE MSG $chan %name is already on the list of Jackbox Party Pack banned users.
      }
      ELSEIF ($regex($2,/^rem(ove)?$/iS)) {
        IF ($istok(%jackbox_deny,%name,32)) {
          SET %jackbox_deny $remtok(%jackbox_deny,%name,0,32)
          MSG $chan %name has now been removed from the list of Jackbox Party Pack banned users.
        }
        ELSE MSG $chan %name was not on the list of Jackbox Party Pack banned users.
      }
    }
    ELSE MSG $chan $nick $+ , $3 is not a valid user on Twitch.
  }
}
