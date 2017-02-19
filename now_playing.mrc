/*
Simple "Now Playing" Script Designed for Twitch.TV Channels
Created by Blasman13 @ Twitch.TV/Blasman13

This simple script will post a message in your channel chat every time that a new song begins playing.
It does this by reading a text file of the current song being played from whatever software that you
are using (AnkhBot, Twobbler, etc.) and checks to see if it has changed since it has last checked it.

Use the commands "!nowplaying on" and "!nowplaying off" to enable and disable the script in your channel.

You will need to specify the exact location of the text file that is to be read from your computer.
For ease of use, uncomment (delete the ; character) from the appropriate line below. If you are *not*
using BlasBot.mrc, you will also have to change %mychan and $ModCheck in the script appropriately.
*/

; FOR ANKHBOT, IF YOU INSTALLED TO THE DEFAULT DIRECTORY, UNCOMMENT THE LINE BELOW:
;alias -l txt_file RETURN $qt($sysdir(profile) $+ AppData\Roaming\AnkhHeart\AnkhBotR2\Twitch\Files\CurrentSong.txt)

; FOR TWOBBLER, IF YOU INSTALLED TO THE DEFAULT DIRECTORY, UNCOMMENT THE LINE BELOW:
;alias -l txt_file RETURN $qt($sysdir(profile) $+ Documents\Twobbler\nowplaying.txt)

; FOR ANYTHING ELSE, UNCOMMENT THE LINE BELOW AND CHANGE THE "FULL_PATH_AND_FILENAME_HERE" TO THE
; FULL PATH AND FILENAME OF THE TEXT FILE OF THE CURRENT SONG THAT IS BEING PLAYED.
;alias -l txt_file RETURN $qt(FULL_PATH_AND_FILENAME_HERE)

alias -l now_playing {
  IF ($read($txt_file) != %now_playing) {
    SET %now_playing $v1
    MSG %mychan 🎧 NOW PLAYING: %now_playing 🎧
  }
}

ON $*:TEXT:/^!nowplaying\s(on|off)$/iS:%mychan: {
  IF ($ModCheck) {
    IF ($2 == on) {
      IF (!$timer(.now_playing)) {
        .timer.now_playing 0 3 now_playing
        MSG $chan Song titles will now be displayed in chat whenever a new song begins playing.
      }
      ELSE MSG $chan The Now Playing feature is already enabled in chat.
    }
    ELSEIF ($2 == off) {
      IF ($timer(.now_playing)) {
        .timer.now_playing off
        MSG $chan Song titles will no longer be displayed in chat whenever a new song begins playing.
      }
      ELSE MSG $chan The Now Playing feature was already disabled in chat.
    }
  }
}
