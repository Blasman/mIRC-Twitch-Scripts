# mIRC-Twitch-Scripts
The main focus of the scripts on this GitHub are for use with a Twitch [mIRC](http://www.mirc.com/) bot that works in conjunction with [AnkhBot](http://marcinswierzowski.com/Code/AnkhBotR2/) and AnkhBot's point system.  [AnkhBot](http://marcinswierzowski.com/Code/AnkhBotR2/) is a free and versatile Twitch bot, yet like most things, there is always room for improvement.  These scripts are designed to compliment and enchance a Twitch channel that is currently running AnkhBot, however, many of the scripts can also be easily modified to use without AnkhBot.  See the [wiki](https://github.com/Blasman/mIRC-Twitch-Scripts/wiki) for more information regarding each script.  

Be aware that [mIRC](http://www.mirc.com/) is a shareware program with a 30-day trial period, after which you will be required to purchase a license for the program which [costs a one-time fee of $10](http://www.mirc.com/register.php?coupon=MIRC-SWV0-MNKL).  

# Installation

### If You Do Not Have a mIRC Twitch Bot, Set One Up

1. Download and install mIRC. UNCHECK EVERYTHING except "Scripts" and "Help Files" on the "Choose Components" section of the install, as you don't need most of it. http://www.mirc.com/get.html

2. Get your bot's Twitch account up and running with mIRC, and set up your Twitch channel as an auto-join channel as well. See http://help.twitch.tv/customer/portal/articles/1302780-twitch-irc#mIRC%20guide or https://www.youtube.com/watch?v=k7ULgVCZ3Ns

## Once You Do Have a mIRC Twitch Bot
### Download Required Scripts
To use any of the games scripts in this GitHub, you will need to download the following scripts to your mIRC directory.  If you did not change the default install directory of mIRC, you can find the directory by typing %APPDATA%/mIRC into your Windows Folder Titlebar.
* [JSONForMirc.mrc](https://raw.githubusercontent.com/SReject/mTwitch/master/resources/JSONForMirc.mrc): right click this link and "save link as..." to your mIRC directory.
* [mTwitch.Core.mrc](https://raw.githubusercontent.com/SReject/mTwitch/master/mTwitch.Core.mrc): right click this link and "save link as..." to your mIRC directory.
* [mTwitch.GroupChat.mrc](https://raw.githubusercontent.com/SReject/mTwitch/master/mTwitch.GroupChat.mrc): right click this link and "save link as..." to your mIRC directory.
* [mIRC SQLite](http://hawkee.com/scripts/11648275/): Extract the .zip file from this webpage to your mIRC directory.
* [ankhbot.mrc](http://raw.githubusercontent.com/Blasman/mIRC-Twitch-Scripts/master/ankhbot.mrc) : right click this link and "save link as..." to your mIRC directory.

### Install Required Scripts
In mIRC, type in the following commands anywhere.  When loading the last script (ankhbot.mrc), you will have to enter some information into input boxes that will pop up:  

/load -rs JSONForMirc.mrc  
/load -rs mTwitch.Core.mrc  
/load -rs mTwitch.GroupChat.mrc  
/load -rs msqlite.mrc  
/load -rs ankhbot.mrc  

### Download and Install Desired Scripts
For information on each script, see the [wiki](https://github.com/Blasman/mIRC-Twitch-Scripts/wiki).  You can also right click the links on the wiki and select "save link as..." and then use */load -rs script.mrc* just like the previous install instructions.  Do Not "save link as..." using the links on the main page, as they are links to the GitHub html pages.  

#### Contact Info / Help  
If you need help with anything here, please don't hesitate to send me a Twitch message or visit my Twitch channel at http://www.twitch.tv/blasman13/profile  
