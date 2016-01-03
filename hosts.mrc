;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;; !HOSTS COMMAND ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

/*
To use this command, you need to change the ######## on line 17 of
the script to YOUR Twitch User ID, which can be found at
https://api.twitch.tv/kraken/channels/USERNAME
(replace USERNAME with your Twitch username) and look for
"_id":########, that is your Twitch User ID.  This script also
requires the JSONForMirc.mrc script, as well as ankhbot.mrc (for the
twitch_name alias).
*/

ON *:TEXT:!hosts:#: {
  IF ($nick isop $chan) {
    JSONOpen -ud gethosts http://tmi.twitch.tv/hosts?include_logins=1&target=########
    VAR %x = 0
    WHILE ($json(gethosts, hosts, %x, host_login) != $null) {
      VAR %gethdn $json(gethosts, hosts, %x, host_login)
      VAR %gethdn $twitch_name(%gethdn) $+ $chr(44)
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
