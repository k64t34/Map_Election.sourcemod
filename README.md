# Map_Election
Sourcemod плагин для голосования выбора карты.
Плагин работает подобно RTV до момента голосования.
Во время голосования панель выбора карт отображается всё время голосования.
Игрок может видеть выбор других игроков и изменить свой выбор в пользу другой карты.

На время голосования плагин включает sv_alltalk 1, что дает возможность игрокам дополнительно обсудить выбор карты.
Голосование запускается в начале раунда, предворительно выставив  mp_freeztime  равно времени голосования.
Т.о. игровой мир как бы останавливается на время голосования и игроки полностью могут состредоточится на голосовании.

##Title: Map election
##Descriptione: Provides map voting and immediately showing the choice users.Players can agree during voting  and change their choice to any map.
##Cvar:No cvar yet
##Dependencies: No

The plugin works like RTV (Rock The Vote) till the moment vote.
While voting, the panel is displayed all the time of voting.
The player can see a selection of other players and can change their choice in favor of the other cards.

In the period of voting, plugin sets sv_alltalk 1, that allows players to additionally discuss the choice of map.

Voting starts at the beginning of the round. Plugin sets mp_freeztime equal to voting time.
Thus, the world stops at the time of the vote, and the players can fully concentrate on the vote.

In my opinion this interface allows to reach a consensus between the players.

##Pic

##Video

##Changelog
* Initial release.

##Installation instructions
Download the attached zip archive and extract to your game folder.
Install archive contain:
addons
  plugins
    map_vote.smx
  transletion
    map_Elections.phrases.txt 

##Usage:
say key_word [map_name]

Now key_words are map, wantmap, карта, карту.
##Known Issues:
-Incorrect translation
-Incorrect language

##Plans
-Add translations support
-Add select maps for vote like RTV.
-Add sound accompaniment.
-Add cvar for customizing key_word
-Convert more internal stuff into CVARS
-Add sm_mapvote_dontchange Specifies if a 'Don't Change' option should be added to early votes (like rockthevote)
-Add sm_mapvote_include Specifies how many maps to include in the vote.
-Если единственный пользовтель (не считая ботов) подал запрос на смену карты, не зависимо от sm_rtv_minplayers разрешить голосование
-

##Other Information:
This plugin is meant to be run with Sourcemod 1.7 or above.

This is work in progress and is not a final product

## Possible problem
1. Не проверял что будет при 100% кол-ве голосов за одну карту
