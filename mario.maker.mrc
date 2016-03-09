;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;; MARIO MAKER LEVEL ID SCRIPT ;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON *:LOAD: {
  IF (!%mm_cost) SET %mm_cost 0
  IF (!%mm_maxperuser) SET %mm_maxperuser 1
  IF (!%mm_queuesize) SET %mm_queuesize 0
  IF (!%mm_followcheck) SET %mm_followcheck Off
  IF (!%mm_history) SET %mm_history 0
}

ON *:UNLOAD: {
  UNSET %mm_*
  UNSET %mm.*
}

ON $*:TEXT:/^!(mariomaker|mm)\s(((on|off)$)|cost|max|history|ban|queue|followcheck)/iS:%mychan: {
  IF ($nick isop $chan) {
    IF ($2 == on) {
      IF (!%MARIOMAKER_ACTIVE) {
        SET %MARIOMAKER_ACTIVE On
        MSG $chan $nick $+ , the Mario Maker Level ID script is now active! Have fun! PogChamp
      }
      ELSE MSG $chan $nick $+ , the Mario Maker Level ID script is already enabled. FailFish
    }
    ELSEIF ($2 == off) {
      IF (%MARIOMAKER_ACTIVE) {
        UNSET %MARIOMAKER_ACTIVE
        UNSET %mm.currentid_and_name
        MSG $chan $nick $+ , the Mario Maker Level ID script is now disabled.
      }
      ELSE MSG $chan $nick $+ , the Mario Maker Level ID script is already disabled. FailFish
    }
    ELSEIF (($2 == cost) && ($3 isnum)) {
      SET %mm_cost $3
      MSG $chan $nick $+ , the cost to submit a Mario Maker Level ID has been set to $3 %curname $+ .
    }
    ELSEIF (($2 == max) && ($3 isnum)) {
      SET %mm_maxperuser $3
      MSG $chan $nick $+ , the max number of Level ID's per user has been set to $3 $+ .
    }
    ELSEIF (($2 == history) && ($3 isnum)) {
      SET %mm_history $3
      MSG $chan $nick $+ , the history of Level ID's that cannot be submitted again has been set to $3 $+ .
    }
    ELSEIF (($2 == ban) && ($regex($3,^\w{4}\-\w{4}\-\w{4}\-\w{4}$))) {
      WRITE mm_banlist.txt $3
      MSG $chan $nick $+ , $3 has successfully been added to the ban list for Mario Maker Level ID's.
    }
    ELSEIF (($2 == queue) && ($3 isnum)) {
      SET %mm_queuesize $3
      MSG $chan $nick $+ , $3 the max queue size for Mario Maker Level ID's has been set to $3 $+ .
    }
    ELSEIF ($2 == followcheck) {
      IF ($3 == on) {
        IF (%mm_followcheck == Off) {
          SET %mm_followcheck On
          MSG $chan $nick $+ , the Mario Maker Level ID script settings have been changed. You now need to be a follower of %streamer to submit a level ID.
        }
        ELSE MSG $chan $nick $+ , the followcheck option is already enabled. FailFish
      }
      ELSEIF ($3 == off) {
        IF (%mm_followcheck == On) {
          SET %mm_followcheck Off
          MSG $chan $nick $+ , the Mario Maker Level ID script settings have been changed. You no longer need to be a follower of %streamer to submit a level ID.
        }
      }
    }
  }
}

ON *:TEXT:!submit *:%mychan: IF (%MARIOMAKER_ACTIVE) submitcode $2
ON *:TEXT:!submit *:?: IF (%MARIOMAKER_ACTIVE) submitcode $2

alias -l submitcode {
  IF (!$($+(%,mm_cd.,$nick),2)) {
    SET -eu5 %mm_cd. [ $+ [ $nick ] ] On
    IF ((%mm_followcheck == On) && ($followcheck($nick) == $null)) $wdelay(MSG $nick You must be a follower of %streamer to submit Mario Maker Level ID's to be played on stream.)
    ELSEIF ($($+(%,mm.levelid.,$nick),2) >= %mm_maxperuser) {
      $read(mm_queue.txt, ns, $nick)
      $wdelay(MSG $nick You have submitted the maximum amount of Mario Maker Level ID's permitted in the queue. Your next level is number $readn in the queue.)
    }
    ELSEIF ((%mm_queuesize > 0) && ($lines(mm_queue.txt) >= %mm_queuesize)) $wdelay(MSG $nick Sorry $+ but the max queue size of %mm_queuesize Level ID's has been reached. Please try again later.)
    ELSEIF ($regex($1,^\w{4}\-\w{4}\-\w{4}\-\w{4}$)) {
      IF ($isfile(mm_banlist.txt)) {
        VAR %x = 1
        WHILE ($read(mm_banlist.txt,%x) != $null) {
          IF ($v1 == $1) { $wdelay(MSG $nick Sorry $+ $chr(44) but that Level ID is blacklisted from being played here.) | halt }
          INC %x
        }
      }
      IF ($isfile(mm_queue.txt)) {
        VAR %x = 1
        WHILE ($gettok($read(mm_queue.txt,%x),2,32) != $null) {
          IF ($v1 == $1) { $wdelay(MSG $nick Sorry $+ $chr(44) that Level ID already exists in the queue.) | halt }
          INC %x
        }
      }
      IF ((%mm_history > 0) && ($isfile(mm_history.txt))) {
        VAR %x = 1
        WHILE ($read(mm_history.txt,%x) != $null) {
          IF ($v1 == $1) { $wdelay(MSG $nick Sorry $+ $chr(44) but that level has recently been played already.) | halt }
          INC %x
        }
      }
      IF (%mm_cost > 0) {
        IF ($checkpoints($nick,%mm_cost) == false) {
          $wdelay(MSG $nick It costs %mm_cost %curname to submit a Mario Maker Level ID. You do not have enough %curname $+ .)
          halt
        }
        ELSE {
          REMOVEPOINTS $nick %mm_cost
          VAR %mm.spent You spent %mm_cost %curname $+ .
        }
      }
      INC %mm.levelid. [ $+ [ $nick ] ]
      WRITE mm_queue.txt $nick $1
      IF (%mm_history > 0) {
        INC %mm_history_count
        WRITE -l $+ %mm_history_count mm_history.txt $1
        IF (%mm_history_count == %mm_history) SET %mm_history_count 0
      }
      $wdelay(MSG $nick You have successfully submitted a Mario Maker Level ID. Your level is number $lines(mm_queue.txt) in the queue. %mm.spent )
    }
    ELSE $wdelay(MSG $nick That is not a valid Mario Maker Level ID.)
  }
}

ON *:TEXT:!nextid:%mychan: {
  IF ((%MARIOMAKER_ACTIVE) && ($nick isop $chan)) {
    IF ($lines(mm_queue.txt) > 0) {
      SET %mm.currentid $read(mm_queue.txt,1)
      VAR %x $gettok(%mm.currentid,1,32)
      VAR %y $gettok(%mm.currentid,2,32)
      SET %mm.currentid_and_name %y submitted by %x
      DEC %mm.levelid. [ $+ [ %x ] ]
      IF ($($+(%,mm.levelid.,%x),2) == 0) UNSET $v1
      WRITE -dl1 mm_queue.txt
      WRITE -l1 mm_current.txt %y
      MSG $chan The Mario Maker Level ID about to be played is %mm.currentid_and_name $+ .
    }
    ELSE {
      UNSET %mm.currentid_and_name
      WRITE -dl1 mm_current.txt
      MSG $chan There are currently no submitted Mario Maker Level ID's in the queue.
    }
  }
}

ON *:TEXT:!currentid:%mychan: {
  IF ((%MARIOMAKER_ACTIVE) && (!%mm_currentid_cd)) {
    SET -eu10 %mm_currentid_cd On
    VAR %x $lines(mm_queue.txt)
    IF ((%x == 0) || (%x == $null)) VAR %mm.queue There are no more Level ID's in the queue.
    ELSEIF (%x > 0) VAR %mm.queue There are currently %x more Level ID's in the queue.
    IF (%mm.currentid_and_name) MSG $chan The current Mario Maker Level ID is %mm.currentid_and_name $+ . %mm.queue
    ELSE MSG $chan There is no Mario Maker Level ID being played from the queue.
  }
}
