# mIRC-Twitch-Scripts
The main focus of the scripts on this GitHub are for use with a Twitch [mIRC](http://www.mirc.com/) bot that works in conjunction with [AnkhBot](http://marcinswierzowski.com/Code/AnkhBotR2/) and AnkhBot's point system. [AnkhBot](http://marcinswierzowski.com/Code/AnkhBotR2/) is highly regarded as a great choice for a free and versatile Twitch bot, yet development on it has stopped, and it's creator, AnkhHeart, refuses to release the source code to other creators. Therefor, these scripts are designed to compliment and enchance a Twitch channel that is currently using AnkhBot, however, many of the scripts can also be easily modified to work without AnkhBot. See the [WIKI](https://github.com/Blasman/mIRC-Twitch-Scripts/wiki/Script-Documentation) for documentation regarding each script.  

Be aware that [mIRC](http://www.mirc.com/) is a shareware program with a 30-day trial period, after which you will be required to purchase a license for the program. The standard cost is $20 US, however, there is a permanent [50% off coupon which drops the price to $10 found here](http://www.mirc.com/register.php?coupon=MIRC-SWV0-MNKL).  

# Credits  

**AnkhHeart**: For [AnkhBot](http://marcinswierzowski.com/Code/AnkhBotR2/), the bot that my scripts are designed to work with.  
**SReject**: For the [JSON Parser](https://github.com/SReject/JSON-For-Mirc), [mTwitch scripts](https://github.com/SReject/mTwitch) and the "TwitchTime" alias used in ankhbot.mrc.  
**Ramirez**: For the [mIRC SQLite](http://hawkee.com/profile/12444/) script.  

# Installation

### If You Do Not Have a mIRC Twitch Bot, Set One Up  

**Here is a video tutorial on how to set everything up as quickly and painlessly as possible:**  

[![Instructional Video](http://i3.ytimg.com/vi/8YefioQhUZA/hqdefault.jpg)](https://www.youtube.com/watch?v=8YefioQhUZA "Instructional Video")

1. Download and install mIRC. UNCHECK EVERYTHING except "Scripts" and "Help Files" on the "Choose Components" section of the install, as you don't need most of it. http://www.mirc.com/get.html  

2. Get **YOUR BOT'S** Twitch account (**NOT** the Twitch name that you stream with) up and running with mIRC, and set up your main Twitch account's channel as an auto-join channel as well. See http://help.twitch.tv/customer/portal/articles/1302780-twitch-irc#MIRC You may ignore the section titled "Join/Parts - mIRC," as one of the required scripts below will perform the same function automatically.  Keep in mind that for Step 5 of the tutorial, you will need to be logged into Twitch using your BOT'S Twitch account when retreiving the oauth token to use as your password.  

## Once You Do Have a mIRC Twitch Bot
### Download Required Scripts
To use any of the games scripts on this GitHub, you will need to download the following scripts to your MAIN (root) mIRC directory.  If you did not change the default install directory of mIRC, you can find the directory by typing **%APPDATA%/mIRC** into your Windows Folder Titlebar.
* [JSONForMirc.v0.2.41.mrc](https://github.com/SReject/JSON-For-Mirc/releases/download/v0.2.41-beta/JSONForMirc.v0.2.41.mrc): right click this link and "save link as..." to your mIRC directory.
* [mTwitch.Core.mrc](https://raw.githubusercontent.com/SReject/mTwitch/master/mTwitch.Core.mrc): right click this link and "save link as..." to your mIRC directory.
* [mTwitch.DisplayName.mrc](https://raw.githubusercontent.com/SReject/mTwitch/master/mTwitch.DisplayName.mrc): right click this link and "save link as..." to your mIRC directory.
* [mIRC SQLite](http://hawkee.com/scripts/11648275/): Extract the .zip file from this webpage to your mIRC directory. (you may [download here](https://dl.dropboxusercontent.com/u/1231209/msqlite.zip) if the website is currently offline)
* [ankhbot.mrc](http://raw.githubusercontent.com/Blasman/mIRC-Twitch-Scripts/master/ankhbot.mrc) : right click this link and "save link as..." to your mIRC directory.

### Install Required Scripts
In mIRC, type in the following commands anywhere. Accept and run any initialization command prompts. When loading the last script (ankhbot.mrc), you will have to enter some information into input boxes that will pop up. Ignore the "unknown command" error messages that will pop up in mIRC:  

`/load -rs JSONForMirc.v0.2.41.mrc`  
`/load -rs mTwitch.Core.mrc`  
`/load -rs mTwitch.DisplayName.mrc`  
`/load -rs msqlite.mrc`  
`/load -rs ankhbot.mrc`  

**You will have to exit and re-open mIRC after installing these scripts.**  

### Download and Install Desired Scripts
For detailed information about each script, please visit the [WIKI](https://github.com/Blasman/mIRC-Twitch-Scripts/wiki/Script-Documentation) page.  You can also right click the links on the [WIKI](https://github.com/Blasman/mIRC-Twitch-Scripts/wiki/Script-Documentation) (NOT THE MAIN GITHUB PAGE) and select "save link as..." and then use `/load -rs scriptname.mrc` just like the previous install instructions.  Again, do NOT "save link as..." using the links on the main GitHub page, as they are links to the GitHub html pages! Use the  [WIKI](https://github.com/Blasman/mIRC-Twitch-Scripts/wiki/Script-Documentation)!  

You may install as many of the games scripts as desired, as to prevent spam, most of the games are designed so that if one of them is currently being played by a user in the channel, then another game cannot be started by a user until that current game is completed.  

### Contact Info  

By visiting my Twitch channel at http://www.twitch.tv/blasman13 , you may Twitch message me regarding any help that you may require with anything on this GitHub (provided that it is not something that can be easily done yourself by following the instructions on this GitHub), and/or make a donation for my hard work by clicking on the donation link. Before messaging me for help, please make sure that you are using the most recent updates of the scripts on this GitHub, as I am constantly updating the scripts here, and many scripts require newly added segments of other scripts. For general mIRC help, consider joining the [mirchelp](http://www.twitch.tv/mirchelp) chat on Twitch.  

### Troubleshooting / FAQ  

**Issue:** The scripts are not responding to my commands or do not appear to work at all.  
**Answer:** Please be sure that you are right clicking the scripts on the [WIKI](https://github.com/Blasman/mIRC-Twitch-Scripts/wiki/Script-Documentation) and choosing "save as..." rather than using the main GitHub page, as the links on the main page are links to html pages. If you know what you're doing, you can also just download the zip file of all the scripts using the link on the GitHub page and load those files into mIRC. **Always be sure that you are running the LATEST versions of the scripts on the GitHub as well, especially ankhbot.mrc.**  

**Issue:** The scripts appear to be running very slow and/or using a lot of CPU.  
**Answer:** I have had this issue as well as others using my scripts using the latest mIRC version 7.46. I recommend using [version 7.45](http://filehippo.com/download_mirc/67569/) in the meantime as that is what I am using and it is functioning properly.  

### Twitch Channels Currently Running These Scripts  

Some of the Twitch channels currently using some of the scripts on this GitHub:  
[Blasman13](http://twitch.tv/Blasman13) | [xxxDESPERADOxxx](http://twitch.tv/xxxDESPERADOxxx) | [NakedAngel](http://twitch.tv/NakedAngel) | [thaithyme](http://twitch.tv/thaithyme) | [Evraee](http://twitch.tv/Evraee) | [AeroGarfield29](http://twitch.tv/AeroGarfield29) | [abrekke83](http://twitch.tv/abrekke83) | [KatieKakes32](http://twitch.tv/KatieKakes32) | [SmokinDank5280](http://twitch.tv/SmokinDank5280) | [A_Colder_Vision](http://twitch.tv/A_Colder_Vision) | [Tygastripe](http://twitch.tv/Tygastripe) | [XinarTheNeko](http://twitch.tv/XinarTheNeko) | [BruisedRetro](http://twitch.tv/BruisedRetro) | [TheYasmein](http://twitch.tv/TheYasmein) | [LeagueOfGambling](http://twitch.tv/LeagueOfGambling) | [ESurge](http://twitch.tv/ESurge) | [TripodGG](http://twitch.tv/TripodGG)

