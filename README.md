# About

"Terminal Hero" is a simple turn-based roleplaying game playable from the terminal.

You begin the game by creating a character. In the game, you will navigate your character around a world map represented with ASCII art. Different symbols on the map represent different types of terrain and monsters. When your character encounters a monster, this triggers a turn-based combat system in which you select actions (such as "attack" or "flee") from a prompt menu. By defeating monsters, you gain experience to level up your character.

The game is designed to be played in short sessions between other tasks. Progress is saved regularly, so you can stop any time and pick up where you left off.

# Dependencies

Terminal Hero is developed in Ruby, and requires Ruby installed to run. You can find instructions to download and install Ruby for your operating system [here](https://www.ruby-lang.org/en/downloads/). 

The following Ruby gems are runtime dependencies required to play Terminal Hero:

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

The game is known to run poorly in integrated terminals (such as in VSCode). Run in a stand-alone terminal for best performance.

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
