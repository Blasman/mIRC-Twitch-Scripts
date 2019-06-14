/*
mIRC Twitch Clip Info Script
Version 1.001 (June 13, 2019)
Created by Blasman13 @ https://twitch.tv/Blasman13 & https://github.com/Blasman/mIRC-Twitch-Scripts
This script will have your mIRC Twitch Bot automatically post a message in chat whenever a user posts a link to a Twitch clip
This script relies on aliases and variables from BlasBot.mrc
The message that your bot posts contains the following info:
- who just posted the link
- who the streamer is in the clip
- the title of the clip
- the game being played in the clip
- who created the clip
- how long ago (or the date if not recently made) that the clip was created
- (optional, off by default) the URL of the clip
- (optional, off by default) the view count of the clip

OPTIONAL FEATURE: Streamer Clips Only
To only post a message when the Twitch Clip is a clip that contains the streamer of the channel, you can remove the semi-colon at the start of the second line of the script below -> ;VAR %tc_streamer_only $true

OPTIONAL FEATURE: Re-Post URL
To repost the URL to the clip at the end of the info message, you can remove the semi-colon at the start of the third line of the script below -> ;VAR %tc_repost_link $true

OPTIONAL FEATURE: View Count
To show the view count of the linked clip, you can remove the semi-colon at the start of the fourth line of the script below -> ;VAR %tc_view_count $true
*/


ON $*:TEXT:/clips\.twitch\.tv\/(\w+)/iS:%mychan: {
  ;VAR %tc_streamer_only $true
  ;VAR %tc_repost_link $true
  ;VAR %tc_view_count $true
  INC %tc
  VAR %tc %tc $+ $ticks
  JSONOpen -uw get_twitch_clip $+ %tc https://api.twitch.tv/helix/clips?id= $+ $regml(1)
  JSONHttpHeader get_twitch_clip $+ %tc Client-ID avm4vi7zv0xpjkpi3d4x0qzk8xbrdw8
  JSONHttpHeader get_twitch_clip $+ %tc Accept application/vnd.twitchtv.v5+json
  JSONHttpFetch get_twitch_clip $+ %tc
  IF (!$JSONError) {
    VAR %tc_streamer $json(get_twitch_clip $+ %tc, data, 0, broadcaster_name).value
    IF ((%tc_streamer_only) && (%tc_streamer != %streamer)) NOOP
    ELSE {
      VAR %created_at $TwitchTime($json(get_twitch_clip $+ %tc, data, 0, created_at).value)
      IF ($calc($ctime - %created_at) < 3600) VAR %created_at Clipped $duration($calc($ctime - %created_at)) ago
      ELSEIF ($calc($ctime - %created_at) isnum 3600 - 86399) VAR %created_at Clipped $duration($calc($ctime - %created_at), 2) ago
      ELSE VAR %created_at Clipped on $asctime(%created_at, mmm dd - h:nn TT)
      MSG $chan 📽 Twitch Clip Info linked by $nick ▌ Streamer: %tc_streamer ▌ Title: $json(get_twitch_clip $+ %tc, data, 0, title).value ▌ Game: $twitch_lookup_game($json(get_twitch_clip $+ %tc, data, 0, game_id).value) ▌ Clipped By: $json(get_twitch_clip $+ %tc, data, 0, creator_name).value ▌ %created_at $IIF(%tc_view_count, ▌ View Count: $json(get_twitch_clip $+ %tc, data, 0, view_count).value, $null) $IIF(%tc_repost_link, ▌ Link: $json(get_twitch_clip $+ %tc, data, 0, url).value, $null)
    }
  }
  JSONClose get_twitch_clip $+ %tc
}

alias twitch_lookup_game {
  INC %tc
  VAR %tc %tc $+ $ticks , %result
  JSONOpen -uw twitch_lookup_game $+ %tc https://api.twitch.tv/helix/games?id= $+ $1
  JSONHttpHeader twitch_lookup_game $+ %tc Client-ID avm4vi7zv0xpjkpi3d4x0qzk8xbrdw8
  JSONHttpHeader twitch_lookup_game $+ %tc Accept application/vnd.twitchtv.v5+json
  JSONHttpFetch twitch_lookup_game $+ %tc
  IF (!$JSONError) VAR %result $json(twitch_lookup_game $+ %tc, data, 0, name).value
  JSONClose twitch_lookup_game $+ %tc
  RETURN %result
}
