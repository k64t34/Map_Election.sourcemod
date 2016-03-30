# Map_Election
Sourcemod плагин для голосования выбора карты.
Плагин работает подобно RTV до момента голосования.
Во время голосования панель выбора карт отображается всё время голосования.
Игрок может видеть выбор других игроков и изменить свой выбор в пользу другой карты.

На время голосования плагин включает sv_alltalk 1, что дает возможность игрокам дополнительно обсудить выбор карты.
Голосование запускается в начале раунда, предворительно выставив  mp_freeztime  равно времени голосования.
Т.о. игровой мир как бы останавливается на время голосования и игроки полностью могут состредоточится на голосовании.


SourceMod plugin for votemap.
The plugin works like RTV (Rock The Vote) till the moment vote.
While voting, the panel is displayed all the time of voting.
The player can see a selection of other players and can change their choice in favor of the other cards.

In the period of voting, plugin sets sv_alltalk 1, that allows players to additionally discuss the choice of map.

Voting starts at the beginning of the round. Plugin sets mp_freeztime equal to voting time.
Thus, the world stops at the time of the vote, and the players can fully concentrate on the vote.

In my opinion this interface allows you to reach a consensus between the players.

SourceMod plugin for votemap

Plugin Category:Server Management
Plugin Game:Any (But tested in CS:S only)
Plugin Description: 

Title:Map Election
Feature list:
CVAR/Command list:
Changelog:
* Initial release.
1.0: First release
Installation instructions:
Dependencies:
Most people will file feature requests in your thread "Please add A", "Ohh I would love to see B". In order to keep the requests under control, you COULD add a "Plans" section in your post, so users don't have to requests features that you already plan on supporting in future versions.
Media
Credits:
Installation:
1. Download the attached zip archive and extract to your game folder.
2. 
Usage:
say map 
say map <map_name>

Plans:
Known Issues:
-Incoorect language
Notes:
Other Information:
This plugin is meant to be run with Sourcemod 1.7 or above.


https://forums.alliedmods.net/showthread.php?p=632031?p=632031
https://forums.alliedmods.net/showthread.php?p=633808?p=633808



This is work in progress and is not a final product







Title
I suppose it would be easiest if the title looked something like "[<game>] <plugin name> (<version>, <date>)" ("[TF2] Team Scramble (v1.2, 2010-06-12)"). This way everybody can quickly see if their favorite plugin updated, or what game a plugin is for without even having to open the thread.
Description
A description of what the plugin does. Even though you might think "it's all in the title" it might still be unclear to users what it is exactly that your plugin adds to the game.
Feature list
A list of features isn't necessary, and can be part of the description, however if you have a lot of features, a separate list adds clarity.
CVAR/Command list
Users shouldn't have to browse through your code for hidden ConVars and commands, you better list them all, including a clear description of what they do.
Changelog
It is useful for users to see how active you are, when the last update has been released, what you have fixed/added/changed, therefore a changelog would be nice to have.

An example of a changelog can be:
Quote:
2010-01-13 (v1.1)

* Improved the "algorithm".
* Cleaner code.

2010-01-12 (v1.0)

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
