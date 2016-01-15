;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;; !HOSTS COMMAND ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

/*
To use this command, you will need ankhbot.mrc for the %TwitchID variable
and various aliases.  Otherwise, you will have to edit the script
accordingly.  This script also requires the JSONforMirc.mrc script.
*/

ON *:TEXT:!hosts:%mychan: {
  IF ($nick isop $chan) {
    JSONOpen -ud gethosts http://tmi.twitch.tv/hosts?include_logins=1&target= $+ %TwitchID
    VAR %x = 0
    WHILE ($json(gethosts, hosts, %x, host_login) != $null) {
      VAR %gethdn $json(gethosts, hosts, %x, host_login)
      VAR %gethdn $cached_name(%gethdn) $+ $chr(44)
      VAR %gethosts %gethosts %gethdn
      INC %x
    }
    VAR %gethosts $sorttok(%gethosts , 32, a)
    VAR %gethosts $left(%gethosts, -1)
    VAR %numhosts $numtok(%gethosts, 32)
    IF (%gethosts != $null) MSG $chan bleedPurple Thank You to all these %numhosts awesome people who are currently hosting this stream:  %gethosts  bleedPurple
    ELSEIF (%gethosts == $null) MSG $chan $twitch_name($nick) $+ , no one is hosting the channel at the moment.  FeelsBadMan
  }
}
