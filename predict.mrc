ON *:TEXT:!predict*:#blasman13: {

  IF ($2 == help) || ($2 == $null) {
    IF (%floodPREDICTHELP) halt
    SET -u20 %floodPREDICTHELP On
    MSG $chan The !predict game is simple.  It costs no points to enter.  You make a prediction of what percentage that the predict hack will end at.  If your guess is closest to the final percentage of the hack, you will win points!  If you get the percentage exactly correct (except for 100%), then you will win twice as many points!  Points are split if there is a tie.  Predict using !predict [percentage]
  }
  IF ($2 == types) {
    IF (%floodPREDICTTYPES) halt
    SET -u20 %floodPREDICTTYPES On
    MSG $chan The different types of !predict hacks include:  Firetruck (firetruck)  ▌  immediate on foot (foot)  ▌  "Stevie Wonder" (blind)  ▌  Ice Cream or Taco Truck (icetaco)  ▌  Ambulance (ambulance)  ▌  hiding a car (carhide)  ▌  standing at a bus stop (busstop)  ▌  clothing store display case (display)  ▌  store clerk (storeclerk)  ▌  standing in an intersection (intersection)
  }
  IF (%predictsopen) {
    IF ($2 isnum 1-100) && (%predict. [ $+ [ $nick ] ] == $null) {
      VAR %nick $twitch_name($nick)
      WRITE predict.txt %nick $floor($2)
      SET %predict. [ $+ [ $nick ] ] On
      IF ($2 isnum 1-99) MSG $nick %nick $+ , your prediction of $2 $+ % has been recorded.  You will win %ppayout points if you predicted closest to the final percentage of the hack.  You will win DOUBLE the points ( $+ $calc(%ppayout * 2) $+ ) if you get the percentage exactly correct!  Good luck!  BloodTrail
      IF ($2 isnum 100) MSG $nick %nick $+ , your prediction of $2 $+ % has been recorded.  You will win %ppayout points if you predicted closest to the final percentage of the hack.  Good luck!  BloodTrail
    }
  }
  IF ($nick isop $chan) {
    IF ($2 == $chr(35)) {
      IF ($isfile(predict.txt)) MSG $chan Total number of predicts:  $lines(predict.txt)
      ELSE MSG $chan There are no current predicts!
    }
    IF ($2 == firetruck) && ($3 isnum) {
      IF (%predictsopen) halt
      SET %ppayout $floor($3)
      SET %predictsopen On
      MSG $chan PREDICT HACK!!! Blasman will attempt to win the next hack while staying in a Firetruck with the sirens on.  The viewer with the closest guess to the percentage that the hack will end at will receive %ppayout points.  Please predict now using the format !predict [percent] and BEFORE Blasman enters the players game.
    }
    IF ($2 == foot) && ($3 isnum) {
      IF (%predictsopen) halt
      SET %ppayout $floor($3)
      SET %predictsopen On
      MSG $chan PREDICT HACK!!! Blasman will attempt to win the next hack by beginning it asap, remaining on foot, and not hiding at the edge of the circle.  The viewer with the closest guess to the percentage that the hack will end at will receive %ppayout points.  Please predict now using the format !predict [percent] and BEFORE Blasman enters the players game.
    }
    IF ($2 == blind) && ($3 isnum) {
      IF (%predictsopen) halt
      SET %ppayout $floor($3)
      SET %predictsopen On
      MSG $chan PREDICT HACK!!! Blasman will attempt to win the next hack by remaining highly visable to the opponent.  The viewer with the closest guess to the percentage that the hack will end at will receive %ppayout points.  Please predict now using the format !predict [percent] and BEFORE Blasman enters the players game.
    }
    IF ($2 == icetaco) && ($3 isnum) {
      IF (%predictsopen) halt
      SET %ppayout $floor($3)
      SET %predictsopen On
      MSG $chan PREDICT HACK!!! The next time Blasman spots an ice cream truck or taco van, he will attempt to win the hack while driving in it.  The viewer with the closest guess to the percentage that the hack will end at will receive %ppayout points.  Please predict now using the format !predict [percent] and BEFORE Blasman enters the players game.
    }
    IF ($2 == ambulance) && ($3 isnum) {
      IF (%predictsopen) halt
      SET %ppayout $floor($3)
      SET %predictsopen On
      MSG $chan PREDICT HACK!!! Blasman will attempt to win the next hack while staying in an ambulance with the sirens on.  The viewer with the closest guess to the percentage that the hack will end at will receive %ppayout points.  Please predict now using the format !predict [percent] and BEFORE Blasman enters the players game.
    }
    IF ($2 == carhide) && ($3 isnum) {
      IF (%predictsopen) halt
      SET %ppayout $floor($3)
      SET %predictsopen On
      MSG $chan PREDICT HACK!!! Blasman will attempt to win the next hack while hiding in vehicle (not a bike).  The viewer with the closest guess to the percentage that the hack will end at will receive %ppayout points.  Please predict now using the format !predict [percent] and BEFORE Blasman enters the players game.
    }
    IF ($2 == busstop) && ($3 isnum) {
      IF (%predictsopen) halt
      SET %ppayout $floor($3)
      SET %predictsopen On
      MSG $chan PREDICT HACK!!! The first chance that Blasman gets, he will start a hack while standing center circle at a bus stop.  The viewer with the closest guess to the percentage that the hack will end at will receive %ppayout points.  Please predict now using the format !predict [percent] and BEFORE Blasman enters the players game.
    }
    IF ($2 == display) && ($3 isnum) {
      IF (%predictsopen) halt
      SET %ppayout $floor($3)
      SET %predictsopen On
      MSG $chan PREDICT HACK!!! The first chance that Blasman gets, he will start a hack while standing center circle in a clothing store display case.  The viewer with the closest guess to the percentage that the hack will end at will receive %ppayout points.  Please predict now using the format !predict [percent] and BEFORE Blasman enters the players game.
    }
    IF ($2 == storeclerk) && ($3 isnum) {
      IF (%predictsopen) halt
      SET %ppayout $floor($3)
      SET %predictsopen On
      MSG $chan PREDICT HACK!!! The first chance that Blasman gets, he will start a hack while standing center circle and taking the place of a store clerk.  The viewer with the closest guess to the percentage that the hack will end at will receive %ppayout points.  Please predict now using the format !predict [percent] and BEFORE Blasman enters the players game.
    }
    IF ($2 == intersection) && ($3 isnum) {
      IF (%predictsopen) halt
      SET %ppayout $floor($3)
      SET %predictsopen On
      MSG $chan PREDICT HACK!!! The first chance that Blasman gets, he will attempt to win a hack while standing in the middle of an intersection.  The viewer with the closest guess to the percentage that the hack will end at will receive %ppayout points.  Please predict now using the format !predict [percent] and BEFORE Blasman enters the players game.
    }
    IF ($2 == close) {
      IF (%predictsopen) {
        UNSET %predictsopen
        MSG $chan Predicts are now CLOSED!  Please enjoy the hacks and wait until the predict game is over to see if you are a winner!  BloodTrail
      }
    }
    IF ($2 == open) {
      IF (!%predictsopen) {
        SET %predictsopen On
        MSG $chan Predictions for the current prediction hack have been re-opened!  You have another chance to !predict if you have not already!  FeelsGoodMan
      }
    }
    IF ($2 == cancel) {
      IF (%predictsopen) {
        MSG $chan The !predict hack has been cancelled.
        endpredict
      }
    }
    IF ($2 == change) && ($3 isnum) {
      IF (%predictsopen) {
        VAR %newppayout $floor($3)
        MSG $chan The current payout for the !predict hack has been changed from %ppayout to %newpppayout points!
        SET %ppayout %newppayout
      }
    }
    IF ($2 == end) && ($3 isnum 1-100) {
      IF $exists(predict.txt) == $false { MSG $chan There are no predictions! | halt }
      UNSET %predictsopen
      VAR %finalpercent = $3
      VAR %predict_count = 1
      VAR %narrowpercent = 1
      WHILE (%findwinner == $null) && (%exactwinner == $null) {
        WHILE ($read(predict.txt, %predict_count) != $null) {
          VAR %nick $wildtok($read(predict.txt, %predict_count), *, 1, 32)
          VAR %predict $wildtok($read(predict.txt, %predict_count), *, 2, 32)
          IF (%predict == %finalpercent) VAR %exactwinner $+(%exactwinner, $chr(32), %nick, $chr(32))
          ELSEIF ($calc(%predict + %narrowpercent) == %finalpercent) || ($calc(%predict - %narrowpercent) == %finalpercent) {
            VAR %findwinner $+(%findwinner, $chr(32), %nick, $chr(32))
            VAR %findpercent $+(%findpercent, $chr(32), %predict, $chr(32))
          }
          INC %predict_count
        }
        VAR %predict_count = 1
        INC %narrowpercent
      }

      VAR %countwinners = 1
      IF (%exactwinner) {
        VAR %numwinners = $numtok(%exactwinner,32)
        IF (%finalpercent == 100) {
          SET %ppayout $floor($calc(%ppayout / %numwinners))
          WHILE (%numwinners >= %countwinners) {
            VAR %winner $wildtok(%exactwinner, *, %countwinners, 32)
            ADDPOINTS %winner %ppayout
            INC %countwinners
          }
          IF (%numwinners == 1) MSG $chan Congrats, $twitch_name(%winner) $+ , for predicting that the hack would end at exactly %finalpercent $+ $chr(37) $+ !  You win %ppayout points!  PogChamp
          IF (%numwinners > 1) MSG $chan Congrats to the following people for predicting that the hack would end at exactly %finalpercent $+ $chr(37) $+ !  You all split the winnings at %ppayout points each!  Winners:  %exactwinner  BloodTrail
        }
        IF (%finalpercent < 100) {
          SET %ppayout $floor($calc(%ppayout * 2 / %numwinners))
          WHILE (%numwinners >= %countwinners) {
            VAR %winner $wildtok(%exactwinner, *, %countwinners, 32)
            ADDPOINTS %winner %ppayout
            INC %countwinners
          }
          IF (%numwinners == 1) MSG $chan Congrats, $twitch_name(%winner) $+ , for predicting that the hack would end at exactly %finalpercent $+ $chr(37) $+ !  You win %ppayout points!  PogChamp
          IF (%numwinners > 1) MSG $chan Congrats to the following people for predicting that the hack would end at exactly %finalpercent $+ $chr(37) $+ !  You all split the winnings at %ppayout points each!  Winners:  %exactwinner  BloodTrail
        }
      }

      ELSEIF (%findwinner) {
        VAR %numwinners = $numtok(%findwinner,32)
        SET %ppayout $floor($calc(%ppayout / %numwinners))
        WHILE (%numwinners >= %countwinners) {
          VAR %winner $wildtok(%findwinner, *, %countwinners, 32)
          VAR %percent $wildtok(%findpercent, *, %countwinners, 32)
          ADDPOINTS %winner %ppayout
          INC %countwinners
        }
        IF (%numwinners == 1) MSG $chan Congrats, $twitch_name(%winner) $+ , for getting the closest prediction to %finalpercent $+ $chr(37) with your prediction of %percent $+ $chr(37) $+ !  You win %ppayout points!  PogChamp
        IF (%numwinners > 1) MSG $chan Congrats to the following people for making the closest predictions to %finalpercent $+ $chr(37) $+ !  You all split the winnings at %ppayout points each!  Winners:  %findwinner  BloodTrail
      }
      endpredict
    }
  }
}

alias endpredict {
  IF ($isfile(predict.txt)) REMOVE predict.txt
  UNSET %predictsopen
  UNSET %ppayout
  UNSET %predict.*
}
