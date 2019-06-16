; A Basic Script for Twitch Subscriber Notifications in mIRC
; Version 1.002 (June 15, 2019)
; by twitch.tv/Blasman13
; $MSGTAGS HELP: https://dev.twitch.tv/docs/irc/tags/#usernotice-twitch-tags
; You can find your Twitch User ID that is needed on the the third line (YOUR_TWITCH_USERID) of the actual script below here: https://bashtech.net/twitch/profile.php
; Please make sure that you are requesting cabilities from Twitch for IRC: https://dev.twitch.tv/docs/irc/guide/#twitch-irc-capabilities

RAW USERNOTICE:*: {
  ; LOOK FOR TRIGGER: your Twitch channel && are subscription related
  IF (($msgtags(room-id).key == YOUR_TWITCH_USERID) && ($istok(sub resub subgift submysterygift, $msgtags(msg-id).key, 32))) {
    ; GET VARIABLES
    VAR %name $IIF($regex($msgtags(display-name).key, /^[a-z\d_]+$/ig), $msgtags(display-name).key, $msgtags(login).key)
    VAR %msg-id $msgtags(msg-id).key
    VAR %msg-param-cumulative-months $msgtags(msg-param-cumulative-months).key
    VAR %msg-param-months $msgtags(msg-param-months).key
    VAR %msg-param-streak-months $msgtags(msg-param-streak-months).key
    VAR %msg-param-sub-plan $IIF($msgtags(msg-param-sub-plan).key isnum, $calc($msgtags(msg-param-sub-plan).key / 1000), $msgtags(msg-param-sub-plan).key)
    ; MASS SUB GIFTER ALERT: thank the person who gifted the subs and prevent messages for each individual sub
    IF (%msg-id == submysterygift) {
      VAR %msg-param-mass-gift-count $msgtags(msg-param-mass-gift-count).key
      INC %submysterygift. $+ %name %msg-param-mass-gift-count
      MSG $1 %name just gifted %msg-param-mass-gift-count tier %msg-param-sub-plan subscriptions to the community!
    }
    ; NEW SUBSCRIBER ALERT
    ELSEIF (%msg-id == sub) {
      IF (%msg-param-sub-plan isnum) MSG $1 %name just subscribed at tier %msg-param-sub-plan $+ !
      ELSEIF (%msg-param-sub-plan == Prime) MSG $1 %name just subscribed with Twitch Prime!
    }
    ; RE-SUBSCRIBER ALERT
    ELSEIF (%msg-id == resub) {
      IF (%msg-param-sub-plan isnum) VAR %msg_resub %name just re-subscribed at tier %msg-param-sub-plan $+ $chr(44)
      ELSEIF (%msg-param-sub-plan == Prime) VAR %msg_resub %name just re-subscribed using Twitch Prime $+ $chr(44)
      IF (%msg-param-cumulative-months > 1) VAR %msg_resub %msg_resub and has been subscribed for a total of %msg-param-cumulative-months months $+ $chr(44)
      IF (%msg-param-streak-months > 1) VAR %msg_resub %msg_resub and is on a %msg-param-streak-months month sub streak $+ $chr(44)
      MSG $1 $left(%msg_resub,-1) $+ !
    }
    ; GIFTED SUB ALERT
    ELSEIF (%msg-id == subgift) {
      ; IF the receiver of the Gifted Sub is the ONLY PERSON to be gifted a sub (ie it's NOT a Mass Sub Gift of two or more) then we WILL display a message in chat
      IF (!$($+(%,submysterygift.,%name),2)) {
        VAR %name_gifted_to $IIF($regex($msgtags(msg-param-recipient-display-name).key, /^[a-z\d_]+$/ig), $msgtags(msg-param-recipient-display-name).key, $msgtags(msg-param-recipient-user-name).key)
        MSG $1 %name just GIFTED a tier %msg-param-sub-plan subscription to %name_gifted_to $+ ! $IIF(%msg-param-months > 1, It is their %msg-param-months month sub anniversary!, $null)
      }
      ; ELSE the receiver of the Gifted Sub is part of a Mass Sub Gift, therefor we display NOTHING in chat to prevent spam!
      ELSE {
        DEC %submysterygift. [ $+ [ %name ] ]
        IF (!$($+(%,submysterygift.,%name),2)) UNSET %submysterygift. [ $+ [ %name ] ]
        RETURN
      }
    }
  }
}



/* ========================================================================================

; An Example that was used for Twitch's limited time "Subtember" promo

IF (($msgtags(room-id).key == YOUR_TWITCH_USERID) && ($msgtags(msg-id).key == giftpaidupgrade) && ($msgtags(msg-param-promo-name).key == Subtember)) {
  VAR %name_from $IIF($regex($msgtags(msg-param-sender-name).key, /^[a-z\d_]+$/ig), $msgtags(msg-param-sender-name).key, $msgtags(msg-param-sender-login).key)
  VAR %name_to $IIF($regex($msgtags(display-name).key, /^[a-z\d_]+$/ig), $msgtags(display-name).key, $msgtags(login).key)
  MSG $1 SUBTEMBER HYPE! %name_to is continuing their gifted subscription from %name_from for just $chr(36) $+ 1.00!
}

======================================================================================== */
