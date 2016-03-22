ON $*:TEXT:/!counter (((start|end)$)|words\s)/iS:%mychan: {
  IF ($nick isop $chan) {
    IF ($2 == start) {
      IF (!%Counter_Active) {
        SET %Counter_Active On
        MSG $chan $nick $+ , the spam counter script is now active.
      }
      ELSE MSG $chan $nick $+ , the spam counter script is already active in the channel. FailFish
    }
    ELSEIF (($2 == words) && ($3)) {
      VAR %x = 1
      UNSET %Counter_Words
      WHILE ($0 >= %x) {
        SET %Counter_Words %Counter_Words $ [ $+ [ $calc(%x + 2) ] ]
        INC %x
      }
      MSG $chan The spam counter words to match have been set to: %Counter_Words
    }
    ELSEIF (($2 == end) && (%Counter_Active)) counter_end
  }
}

ON *:TEXT:*:%mychan: {
  IF (%Counter_Active) {
    VAR %x = 1
    WHILE ($numtok(%Counter_Words,32) >= %x) {
      IF ($count($1-,$gettok(%Counter_Words,%x,32)) > 0) {
        INC %Counter_Word_ [ $+ [ $gettok(%Counter_Words,%x,32) ] ] $count($1-,$gettok(%Counter_Words,%x,32))
        .TIMER.COUNTER 1 10 counter_end
      }
      INC %x
    }
  }
}

alias -l counter_end {
  UNSET %Counter_Active
  VAR %x = 1
  WHILE ($numtok(%Counter_Words,32) >= %x) {
    IF ($($+(%,Counter_Word_,$gettok(%Counter_Words,%x,32)),2)) {
      VAR %Counter_Matches %Counter_Matches $gettok(%Counter_Words,%x,32): $chr(40) $+ $($+(%,Counter_Word_,$gettok(%Counter_Words,%x,32)),2) $+ $chr(41) -
      IF ($($+(%,Counter_Word_,$gettok(%Counter_Words,%x,32)),2) > $($+(%,counter.record.,$gettok(%Counter_Words,%x,32)),2)) {
        WRITE -l1 counter_record_ $+ $gettok(%Counter_Words,%x,32) $+ .txt The most $gettok(%Counter_Words,%x,32) was spammed on stream was $($+(%,Counter_Word_,$gettok(%Counter_Words,%x,32)),2) times on $asctime(mmm d yyyy)
        SET %counter.record. [ $+ [ $gettok(%Counter_Words,%x,32) ] ] $($+(%,Counter_Word_,$gettok(%Counter_Words,%x,32)),2)
        VAR %NewRecords %NewRecords New Spam Record! $gettok(%Counter_Words,%x,32) $chr(40) $+ $($+(%,Counter_Word_,$gettok(%Counter_Words,%x,32)),2) $+ $chr(41) -
      }
    }
    INC %x
  }
  IF (%Counter_Matches) {
    MSG %mychan Spam Counter has matched the following: $left(%Counter_Matches,-1)
    IF (%NewRecords) MSG %mychan $left(%NewRecords,-1)
  }
  ELSE MSG %mychan Spam Counter did not match anything!
  UNSET %Counter_Word_*
}
