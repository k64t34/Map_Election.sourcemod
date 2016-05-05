# Map_Election

![GitHub Logo](/fy_xbox0086.png)

The plugin works like RTV (Rock The Vote) till the moment vote. While voting, the panel is displayed all the time of voting. The player can see a selection of other players and can change their choice in favor of the other map.

In the period of voting, plugin sets sv_alltalk 1, that allows players to additionally discuss the choice of map.

Voting starts at the beginning of the round. 
Plugin sets mp_freeztime equal to voting time. Thus, the world stops at the time of the vote, and the players can fully concentrate on the vote.

In my opinion this interface allows to reach a consensus between the players.

Sourcemod плагин для голосования выбора карты.
Плагин работает подобно RTV до момента голосования.
Во время голосования панель выбора карт отображается всё время голосования.
Игрок может видеть выбор других игроков и изменить свой выбор в пользу другой карты.

На время голосования плагин включает sv_alltalk 1, что дает возможность игрокам дополнительно обсудить выбор карты.
Голосование запускается в начале раунда, предворительно выставив  mp_freeztime  равно времени голосования.
Т.о. игровой мир как бы останавливается на время голосования и игроки полностью могут состредоточится на голосовании.

##Installation instructions
Download the attached [zip archive](/Map_Election.zip ) and extract to your game folder.

##Usage:
say key_word [map_name]

Now key_words are: votemap, карту.

You can set any key words in CVAR sm_votemap_keywords.
National words are supported, but case sensitive.

Можно использовать слова на любом языке. Ключевое слово чувствительно к регистру.
##Config CVAR  
####sm_votemap_keywords  
  Key words for demand map vote. Delimiter is ;  
  Слова, используемые в чате say или say_team для начала голосования.  
  Default: sm_votemap_keywords "votemap;карту"  

###Used from other plugins
####mp_freezetime  
####sv_alltalk    
####sm_vote_delay  
####sm_mapvote_voteduration  
####sm_rtv_minplayers  


##Plans
- [ ] Add sound accompaniment. Добавить звуковое сопровождение 
- [ ] Convert more internal stuff into CVARS
- [ ] Add sm_mapvote_dontchange Specifies if a 'Don't Change' option should be added to early votes (like rockthevote)
- [ ] Add sm_mapvote_include Specifies how many maps to include in the vote.
- [ ] Если единственный пользовтель (не считая ботов) подал запрос на смену карты, не зависимо от sm_rtv_minplayers разрешить голосование
- [x] Add select maps for vote like RTV v.0.4
- [x] Add cvar for customizing key_word v.0.3
- [x] Add translations support v.0.2

https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet  
##Changelog
* 0.5  
 - Add mark to selected item.  
  Добавлена метка выбранного пункта меню  
 
* 0.4  
  - Add select map for vote like RTV.
 
* 0.3  
  - Added CVAR sm_votemap_keywords - кey words for demand map vote.⋅⋅

* 0.2  
 - Added translation. Used phrases from common, nominations, basevotes, mapchooser, rockthevote,
  that guarantees more internationalization. Интернационализация

* 0.1  
  - Initial release.

##Other Information:
This plugin is meant to be run with Sourcemod 1.7 or above.

This is work in progress and is not a final product
