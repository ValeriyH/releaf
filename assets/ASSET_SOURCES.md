# Releaf — джерела та ліцензії ассетів

## Підтверджено файлами проєкту

| Компонент | Шлях | Автор | Ліцензія | Підтвердження |
|---|---|---|---|---|
| Godot Engine 4.6 | — | Godot contributors | MIT | https://godotengine.org/license |

## Інші ассети що використовуються в проекті

| Ассет | Шлях | Автор / джерело | Ліцензія | Вимоги атрибуції | Примітка |
|---|---|---|---|---|---|
| Атлас землі, дерев, каменів, води | `assets/atlas/terrain_atlas.png` | «LPC Tile Atlas», збірка ассетів Liberated Pixel Cup, склав adrix89, https://opengameart.org/content/lpc-tile-atlas . Автори перелічені в `Attribution.txt` усередині `assets/atlas/Attribution.txt` | CC-BY-SA 3.0 **або** GPL 3.0 | **Обов'язково**: вказати авторів і ліцензію (файл `Attribution.txt` додано; усі автори вказані на екрані Credits, `ui/main_menu/credits_screen.gd`); | 1024×1024, сітка 16 px. Використовується через `objects/tree/res/*.tres`, `objects/stone/*.tres`, `ui/hud/res/tree_icon.tres`. Список авторів: `assets/atlas/Attribution.txt` |
| Лис (гравець) | `objects/player/player.png` | ansimuz, «SunnyLand – Free Pixel Game Art Assets Pack», https://ansimuz.itch.io/sunny-land-pixel-game-art | CC0 1.0 (на 2026-10-30) | Не вимагається (CC0); автора варто згадати в Credits | 6 кадрів 33×32. |
| Анімація вогню | `objects/fire/res/fire.png` | tauran https://opengameart.org/content/animated-flame-texture | CC0 | Не вимагається (CC0); автора варто згадати в Credits | 12×6 кадрів, 1024×512 |
| Звук вогню та горіння | `objects/fire/res/fire.wav`, `burn.wav` | PagDev https://opengameart.org/content/fireplace-sound-loop | CC0| Не вимагається (CC0); автора варто згадати в Credits | |

## Правила додавання в таблицю

1. Для кожного ассета вказувати сторінку-джерело (itch.io / OpenGameArt / Kenney / тощо)
2. Записати: назву паку, автора, URL, ліцензію (CC0 / CC BY / CC BY-SA / платна тощо), дату завантаження.
3. Якщо ліцензія CC BY — додати атрибуцію в гру (екран Credits) і сюди.
4. Якщо ліцензія забороняє перерозповсюдження ассетів у вихідному коді (комерційні паки) — не тримати їх у публічному git-репозиторії;
5. Якщо ліцензію встановити не вдається, ассет безпечніше замінити на власний/CC0
6. Ассети, які зроблений з нуля й власності третіх осіб не містить (як от тайлсет `assets/tilesets/`) в таблицю не додаються.
