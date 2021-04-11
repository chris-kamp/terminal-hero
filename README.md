# About

"Terminal Hero" is a simple turn-based roleplaying game playable from the terminal.

You begin the game by creating a character. In the game, you will navigate your character around a world map represented with ASCII art. Different symbols on the map represent different types of terrain and monsters. When your character encounters a monster, this triggers a turn-based combat system in which you select actions (such as "attack" or "flee") from a prompt menu. By defeating monsters, you gain experience to level up your character.

The game is designed to be played in short sessions between other tasks. Progress is saved regularly, so you can stop any time and pick up where you left off.

# Dependencies

Terminal Hero is developed in Ruby, and requires Ruby installed to run. You can find instructions to download and install Ruby for your operating system [here](https://www.ruby-lang.org/en/downloads/). The game was developed using Ruby 2.7. Newer Ruby versions may, but are not guaranteed to, be backwards-compatible.

The following gems are runtime dependencies required to play Terminal Hero:

- colorize ~> 0.8.1
- json ~> 2.5
- logger ~> 1.4
- remedy ~> 0.3.0
- tmpdir ~> 0.1.2
- tty-font ~> 0.5.0
- tty-prompt ~> 0.23.0

Additionally, rspec ~> 3.10 is a development dependency required in order to run the automated unit tests.

# System and hardware requirements

The tty-prompt gem is used to display menus in the game. There are known issues with the functionality of that gem when run on Windows using Git Bash: see [here](https://github.com/piotrmurach/tty-prompt#windows-support) for details and suggested fixes if you encounter these issues while playing Terminal Hero.

There are no other known system or hardware requirements and the game should otherwise be functional on all major operating systems.

# Installation

## Gem install

Terminal Hero has been published as a Ruby gem. The simplest way to install the game is to run the command `gem install terminal_hero` from a command-line terminal on a system with Ruby installed. All runtime dependencies should be installed automatically. Then, simply run the command `terminal_hero` to start the game.

## Manual installation

Alternatively, the game can be installed by cloning this GitHub repository. Then, to install dependencies, run the command `bundle install` from within the cloned directory. Finally, to run the game, run the command `ruby -Ilib ./bin/terminal_hero` from within the cloned directory.

# Running the game

To play Terminal Hero if installed as a Ruby gem, simply run the command `terminal_hero` from any terminal.

To run the game if installed by cloning this repository, run the command `ruby -Ilib ./bin/terminal_hero` from within the cloned directory.

In either case, the following command line arguments are accepted:

- "-n" or "--new" will skip the title menu and begin a new game. Example: `terminal_hero -n`
- "-l" or "--load" will skip the title menu and prompt the user for the name of a character with an existing save file to load. Optionally, a character name can be appended to skip the prompt and attempt to load a save file for that character directly. Examples: `terminal_hero --load` or `terminal_hero -l myname`

It is recommended to expand your terminal to fullscreen or a reasonably large size when playing. While the in-game map display will scale for smaller terminal sizes, some text interfaces may be cut of and the distance you are able to see away from your character on the map will be smaller.

# How to play

Terminal hero is a turn-based roleplaying game. It utilises many of the conventions of that genre, and will probably be fairly self-explanatory for those familiar with RPGs in general. The below is also explained in the in-game tutorial.

When you begin a new game, you will be prompted to create a character by choosing a name (via text input) and allocating stat points to your character's attributes. The stat menu and other menus in the game can be navigated using the arrow keys and "enter" to confirm a selection.

After creating your character, you will be presented with a map made up of the following symbols:

You can move your character around the map using the arrow keys or "WASD" controls. 

If you run into a monster, you will enter combat. In combat, you and the enemy will take turns to act. You will select your action each round from a list of options. Combat continues until you or the enemy loses all their hit points (HP), or you flee the battle.

When you defeat an enemy, you will gain experience points (XP). When you lose, you will lose some XP (but you won't lose levels). You will then be revived with full HP. When you gain enough XP, you will level up.

Leveling up awards stat points, which you can expend to increase your combat statistics. These are:

- Attack: With higher attack, you will deal more damage in combat.
- Defence: With higher defence, you will receive less damage in combat.
- Constitution: Determines your maximum HP.

The game will automatically save after every battle. To load a saved game, select "load" from the title menu and enter the name of a character with an existing save file when prompted. You can also load straight from the command line - see [Running the Game](#running-the-game).

You can press "escape" or "q" on the map screen at any time to save and exit the game.

Have fun!

# Features

Below is an overview of the main features of Terminal Hero.

## 1: Character creation

You will have the ability to create a customised character.

After starting the game and selecting "new game" from the initial prompt menu, you will be prompted to choose a name via text input, and then to allocate 5 "stat points" to different combat statistics using a prompt menu which can be navigated using arrow keys and "enter" to confirm. 

The name you choose, along with your character's combat statistics, current HP and XP, will be displayed above the map at all times while on the map screen. When saving the game, the chosen character name will be included in the filename for the save file created (and, when loading the game, you will need to input this name to access your save file).

The combat statistics chosen will affect your character's effectiveness in combat. Points allocated to "Attack" will increase the damage dealt to enemies, "Defence" will reduce damage received, and "Constitution" will increase maximum HP.

## 2: Map navigation

You will have the ability to freely navigate your character around a 2-dimensional game world.

Upon entering the game, you will be presented with a 2D map of the game world displayed using ASCII art. Colour-coded ASCII symbols will be used to represent your character, different types of terrain, monsters you can encounter, and the boundaries of the map. The distribution of terrain tiles on the map will be semi-random (ie. random within a pre-determined range of parameters). Monsters will be placed on the map in random locations, up to a given maximum number of monsters (which is also randomly determined within a given range).

You will be able to move around the map using arrow keys or "WASD" controls. Each time you move, each monster on the map will also have a random chance to move. Monsters will move in a random direction, unless they are close enough to your character, in which case they will move towards you. 

You will be able to move around freely on tiles that contain traversable terrain. Other tiles, including the map boundaries, will block movement. Additionally, if you walk into a monster tile (or if a monster walks into you during the monsters' movement phase), combat will be triggered and the display and interface will change to those representing the combat system (discussed below).

## 3: Combat

You will be able to fight monsters using a turn-based combat system.

A combat encounter begins when you encounter a monster on the map. The world map display is replaced by a combat interface which allows you to select an action ("Attack" or "Flee") in each round of combat. After you select your action, the outcome of that action will be resolved, and (unless your action has ended the combat) the monster will then attack you. The actions taken by your character and the monster, their outcome (such as the amount of damage dealt), and the current HP of your character and the monster will be displayed as text following each action.

Like your character, monsters have a level (randomly determined with a range of +/- 1 your level) and stats (with a number of stat points based on the monster's level being randomly distributed across the monster's combat statistics). The damage dealt by your character or a monster when attacking is determined randomly within a range, with that range calculated based on their respective "Attack" and "Defence" stats. This prevents combat from being entirely predictable, while also making choices and progress in developing a character more impactful. Additionally, the chance to successfully "Flee" combat is random with a chance based on your character's and the monster's respective levels. 

Combat ends when you successfully flee, or your or monster's hit points fall to zero or below. If you defeat the monster or successfully flee, any damage suffered by your character persists. If you are defeated, your HP is returned to full, but you suffer a penalty to accumulated experience points. 

After combat ends, you are returned to the map navigation interface. If the monster was defeated, it is removed from the map (and the map is repopulated with monsters, up to the randomly-fluctuating maximum population number). 

## 4: Leveling

You will be able to improve your character's statistics and effectiveness in combat by accumulating experience points (XP) and "leveling up" your character.

Defeating an enemy in combat will award an amount of XP based on the level of the enemy defeated (with higher-level enemies awarding more experience). When enough XP is accumulated, the character's level will increase. After leveling up, you will receive 5 stat points which you can allocate to your character's different combat statistics (Attack, Defence and Constitution discussed above).

Characters begin at level 1, and the amount of XP required to reach the next level will increase exponentially with each level gained. Because the amount of XP required increases formulaically, and monster level scales with your character's level, there is no need for a "level cap" and you can reach arbitrarily high levels if you play for long enough.

You will also lose XP when defeated in combat, in an amount equal to 50% of the XP you would have gained for defeating a monster of your character's current level. However, you will not lose levels and current XP towards the next level will not be reduced below 0.

## 5: Saving and loading

The game state will be automatically saved to a local file during play, and you can load saved games from a local file when entering the game, enabling the your progress to be recorded and preserved and allowing you to pick up where you left off in your next play session. You can also manually save and exit the game from the map screen at any time.

All variable aspects of the game state, including your level, stats, health, XP and coordinates on the map, the distribution of tiles on the map and the coordinates of all monsters on the map, will be saved to a file every time you enter the map screen (ie. after creating a character, and after finishing combat). Because the game is intended to be playable in very short sessions between other tasks, it is important that you can quickly exit the game at any time with minimal loss to progress in the game. 

The saved data will be stored in a "saves" subdirectory of the directory in which the application is installed (and the program will attempt to create that directory if it does not exist). Each time the game is saved, it will overwrite any existing save for the same character name (however, if creating a new character with the same name as an existing save file, you will be prompted to confirm whether you want to overwrite it).
