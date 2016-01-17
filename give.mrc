;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; !GIVE COMMAND ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON $*:TEXT:/^!give\s/iS:%mychan: {
  IF (%floodGIVE) halt
  SET -u3 %floodGIVE On
  IF ($regex($3,^\d+$)) {
    VAR %target $remove($2, @)
    IF (%target == $nick) MSG $chan $nick $+ , you cannot give points to yourself.  FailFish
    ELSEIF (%target == %botname) MSG $chan $nick $+ , I don't need the points, give them to someone else!  SwiftRage
    ELSEIF (%target == %streamer) MSG $chan $nick $+ , %streamer doesn't need the points!  Give them to someone else!  SwiftRage
    ELSEIF (%target !ison $chan) MSG $chan $nick $+ , %target is not a valid user in this channel.  Please make sure that they are here and that you have spelled the name correctly.
    ELSE {
      IF (!$istok($randuser(list),%target,32)) MSG $chan $nick $+ , $twitch_name(%target) is currently lurking here, but they have not recently been active.  You must choose a user who has recently been active in chat to give your points to.
      ELSE {
        IF ($checkpoints($nick,$3) == false) MSG $chan $nick $+ , you do not have $3 points to give to $twitch_name(%target) $+ .
        ELSE {
          REMOVEPOINTS $nick $3
          ADDPOINTS %target $3
          MSG $chan $nick $+ , you have successfully given $3 %curname to $twitch_name(%target) $+ .
        }
      }
    }
  }
  ELSE MSG $chan $nick $+ , you may !give some of your points to another user who is currently active in the channel.  Use: !give [username] [amount] - Example: !give %streamer 100
}
