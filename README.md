# Map_Election
Sourcemod плагин для голосования выбора карты.
Плагин работает подобно RTV до момента голосования.
Во время голосования панель выбора карт отображается всё время голосования.
Игрок может видеть выбор других игроков и изменить свой выбор в пользу другой карты.

На время голосования плагин включает sv_alltalk 1, что дает возможность игрокам дополнительно обсудить выбор карты.
Голосование запускается в начале раунда, предворительно выставив  mp_freeztime  равно времени голосования.
Т.о. игровой мир как бы останавливается на время голосования и игроки полностью могут состредоточится на голосовании.

Title: Map election
Descriptione: Map vote with displing 
Cvar:No cvar yet
Dependencies: No

The plugin works like RTV (Rock The Vote) till the moment vote.
While voting, the panel is displayed all the time of voting.
The player can see a selection of other players and can change their choice in favor of the other cards.

In the period of voting, plugin sets sv_alltalk 1, that allows players to additionally discuss the choice of map.

Voting starts at the beginning of the round. Plugin sets mp_freeztime equal to voting time.
Thus, the world stops at the time of the vote, and the players can fully concentrate on the vote.

In my opinion this interface allows to reach a consensus between the players.

Pic

Video

Changelog
* Initial release.

Installation instructions
Download the attached zip archive and extract to your game folder.
Install archive contain:
addons
  plugins
    map_vote.smx
  transletion
    map_Elections.phrases.txt 

Usage:
say <key_word> [map_name]

Now key_word is map, !map, mapvote,карта, карту.
Known Issues:
-Incorrect translation
-Incorrect language

Plans
Add select map for vote like RTV.
Add sound accompaniment.
Add cvar for customizing key_word

Other Information:
This plugin is meant to be run with Sourcemod 1.7 or above.

This is work in progress and is not a final product

----

https://forums.alliedmods.net/showthread.php?p=632031?p=632031
https://forums.alliedmods.net/showthread.php?p=633808?p=633808

* Initial release.
Installation instructions
If your plugin is NOT of the type "click 'Get Plugin' button, place SMX in the plugins folder and you're done" I highly recommend to write installation and/or configuration instructions for your users.
Dependencies
If your plugin has external dependencies (Extensions, other plugins) you have to tell the users this. Of course, most people do this, BUT there is also another type of dependencies, which are custom include files. Tell people why the web compiler doesn't work and supply them with your custom include files, or at least link them to the thread containing them. You could also include them in a special section in your file so the web compiler does work for everyone wanting to get it easily.
Plans
Most people will file feature requests in your thread "Please add A", "Ohh I would love to see B". In order to keep the requests under control, you COULD add a "Plans" section in your post, so users don't have to requests features that you already plan on supporting in future versions.
Media
Of course, a description in text is one thing, but a picture (or even better, a video) says more than a thousand words (PER FRAME). Get people to want your plugin, to see what the advantage is of having it, and how awesome/easy it is to use.

https://forums.alliedmods.net/showthread.php?t=134190


https://forums.alliedmods.net/showthread.php?p=2142940

-- Add translations support
-- Convert more internal stuff into CVARS
