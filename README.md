# R5 - Statement of purpose and scope

## What will the application do?

"Terminal Hero" is a simple turn-based roleplaying game (RPG). Players begin the game by creating a character. In the game, players navigate their character around a static world map represented with ASCII art. Different ASCII symbols on the map represent different types of terrain and monsters. When the player encounters a monster, this triggers a turn-based combat system in which the player selects actions (such as "attack", "use item", "flee") from a prompt menu. By defeating monsters, the player gains experience to "level up" their character. Players may also receive items after defeating monsters, which they can equip (via a prompt menu accessible from the world map screen) or use in combat. The game state is auto-saved regularly to a local file, and can be loaded from these files on starting the application.

## Why, and what problem does it solve?

The purpose of the application is to provide a simple but entertaining game that can easily be played in very short sessions. Most modern, graphical computer games have long start-up or loading times and therefore require a certain amount of time investment to play. This application will solve that problem by providing a text-based terminal game that players can quickly and easily launch, play for as little as 1-2 minutes at a time, and easily exit at any time with their progress automatically saved. For example, a developer might play the game in a separate terminal to occupy time while their code is compiling, or when taking a brief relaxation break from work.

## Who is the target audience?

The game will be accessible to anyone with the ability to run a Ruby program from the command line. Gameplay will be simple and clearly explained. However, the game is likely to be most appealing to those who work regularly in a terminal environment (such as developers) and those who are already fans of the "turn-based RPG" genre.

## How will members of the target audience use the application?

Players will be able to launch the game from the terminal using Ruby or by executing a provided shell script. Players will interact with the game in two main ways. Firstly, in menus (including the title menu, player inventory and when selecting actions in combat), the player will be prompted to select one of a list of options. The player will navigate these menus using arrow keys and make a selection with the Enter key. Secondly, the player will move their character around a map presented visually using ASCII art. Movement around the map will be accomplished using arrow keys or the "WASD" control scheme. Occasionally, the player will be prompted to provide text input (such as when entering their character's name after beginning a new game). Additionally, in some contexts (such as while navigating the world map), player will be able to press a hotkey to open certain menus (such as the player's inventory) or to exit the game.

# R6 - List of features

## 1: Character creation

The player will have the ability to customise their character by selecting a name and allocating a number of "stat points" to particular combat statistics.

When starting the game and selecting "new game" from the initial prompt menu, the player will be asked to enter a name for their character via text input. Error handling will be used to notify and re-prompt the user when the name entered does not meet the required format (discussed in detail in the outline of user interaction below). The chosen name will be stored as an attribute of the "Player" class instance representing the player's character, and will persist throughout the game. Any in-game text addressing the player will address them by their chosen name. When saving the game, the chosen character name will be included in the filename for the save file created.

After entering a name, the player will be prompted to allocate a certain number of "stat points" to their character's various combat statistics, being Max HP ("hit points"), Defence and Attack. These statistics will affect the damage the character deals and receives, and the amount of damage the character can receive before dying, in combat. Again, the chosen allocation of stat points will be stored in the Player object representing the character and will persist throughout the game. 

## 2: Map navigation

The player will have the ability to freely navigate their character around a static, 2-dimensional game world.

Upon entering the game, the player will be presented with a 2D map of the game world displayed using ASCII art. Different ASCII symbols will be used to represent the player's character, different types of terrain, monsters the player can encounter, and other points of interest. Those symbols will also be colour-coded to more effectively distinguish them visually.  The player will be able to move around the map using arrow keys or "WASD" controls, and the map will be updated and displayed to the player each time the player moves to show their character's new position.

The player will be able to move around freely on tiles that contain symbols representing traversable terrain. Other tiles, including a border around the outside of the map, will block the player's movement. Finally, monsters will be represented on the map. If the player moves onto a tile containing a monster, combat will be triggered and the dispaly and interface will change to those representing the combat system (discussed below).

## 3: Combat

The player will be able to fight a variety of monsters using a turn-based combat system.

A combat encounter begins when a player encounters a monster on the map. The world map display is replaced by a combat interface which allows the player to select an action ("Attack", "Use Item" or "Flee") in each round of combat. After the player selects their action, the outcome of that action will be resolved, and (unless the player's action has ended the combat) the monster will then attack the player. The actions taken by the player and the monster, their outcome (such as the amount of damage dealt), and the current status of the player and the monster (ie. their current HP) will be displayed to the player as text following each round of combat.

The outcome of an action in combat, including damage dealt and the chance to successfully flee from an encounter, is randomly determined within a range, with that range determined based on the player's and the monster's level and combat statistics. This prevents combat from being entirely predictable, while also making the player's choices and progress in developing their character feel impactful. 

Combat ends when the player successfully flees, or the player's or monster's hit points fall to zero or below. If the player defeats the monster or successfully flees, any damage suffered by the player persists. If the player is defeated, their HP is returned to full, but they suffer a penalty to their accumulated experience points (discussed in "Leveling" below). 

After combat ends, the player is returned to the map navigation interface. Monsters the player can encounter will vary in their level and combat statistics, and as the player's level increases, the level of enemies will also "scale" with the player's level to provide a constant challenge.

## 4: Leveling

The player will be able to improve their character's statistics and effectiveness in combat by accumulating experience points (XP) and "leveling up" their character.

Defeating an enemy in combat will award an amount of XP based on the level of the enemy defeated (with stronger, higher-level enemies awarding more experience). When enough XP is accumulated, the player's character will "level up". After leveling up, the player will receive a number of stat points which they can allocate to their different combat statistics, increasing their character's strength.

Characters begin at level 1, and the amount of XP required to reach the next level will increase exponentially with each level gained. Because the amount of XP required increases formulaically, and monster strength scales with the player's level, there is no need for a "level cap" and the player can reach arbitrarily high levels if they play for long enough (though error handling will be used to prevent levels or other statistics from reaching values that exceed integer length restrictions, which could presumably only be reached by modifying game code or save files).

Level, experience points, stat points and combat statistics will be tracked as instance variables of the Player class, which will also have methods to handle gaining or losing experience, leveling up, and allocating stat points.


## 5: Items

The player will be able to collect items which can be equipped to provide a bonus to their character's combat statistics, or used in combat to generate effects such as restoring the player's HP or dealing a large amount of damage to the enemy.

The player will have a chance (random based on a given probability) to receive items when defeating enemies in combat. Items received will be added to the player's "inventory", represented as an array of hashes (with each hash containing an item and the quantity of identical items held) stored as an instance variable of the Player object. 

"Equipment" items can be equipped by the player in different item slots (such as "Weapon", "Helmet", "Shield" etc.) and provide a bonus to the player's combat statistics while equipped. "Consumable" items can be used by the player in combat to heal, deal damage, or potentially produce other effects. Classes will be used to represent "Items" generally, "Equipment" and "Consumable" sub-classes inheriting from "Item", and individual item types (such as a "Longsword" or "Health Potion" class) inheriting from those sub-classes.

Consumable items can be used in combat by selecting the "Use Item" action. Outside of combat, in the world map interface, the player can press a hotkey to open their inventory, represented as a nested menu allowing the player to view their equipment and consumable items, and equip equipment on their character in different item slots. The character's equipped items will be represented as a hash, associating the name of each item slot with an Equipment item instance.


## 6: Auto-save and loading

The game state will be automatically saved to a local file during play, and players can load saved games from a local file when entering the game, enabling the player's progress to be recorded and preserved and allowing them to pick up where they left off in their next play session.

The game will automatically save to file regularly (at minimum, every time a combat encounter concludes). Because the game is intended to be playable in very short sessions between other tasks, it is important that players can quickly exit the game at any time with minimal loss to their progress in the game. 

Players will be able to load saved games using an option in the prompt menu shown when starting the application, or by passing the filename of a saved game as a command-line argument. 

Save data will store relevant data attached to the Player and Map classes sufficient to fully represent all mutable aspects of the game state (including the player's level, health and combat statistics, equipment and inventory, location on the map, and the location of all other objects on the map). The Player and Map classes will have methods to export all such data to a hash, which will be converted to YAML and written to a local file. When loading the game from a file, the YAML data will be parsed into a hash and loaded by methods attached to the Player and Map classes to update the value of their relevant instance variables.

# R7

## Downloading and running the application

Users will be able to download the application by cloning its public GitHub repository, downloading the repository as a zip file and extracting its contents, or by installing the application as a Ruby gem. The README.md displayed on the GitHub repository page will contain clear instructions for each of these options for users who may be unfamiliar with Git, GitHub and/or Ruby. 

Regardless of the method chosen, the user will require Ruby installed on their system as a dependency. A link will be provided in the README.md to a page containing installation instructions and a download link for a compatible Ruby version.

Once Ruby is installed and the application source files have been downloaded, the user will need to install gems comprising the application's dependencies (unless the user has installed the application as a gem, in which case the dependencies should already have been installed as part of that process). All dependencies will be included in a Gemfile, so that the user can run "bundle install" from within the source folder to install dependencies. Instructions to do so will be included in the README.md.

Once all dependencies have been installed, the user can run the application with the command "ruby \<application_name.rb>" from within the source folder. Again, instructions to this effect will be included in the README.md. Instructions will also be provided (for certain operating systems) for setting up an alias to navigate to the source folder and execute the program with a single command. Because the game is intended to be playable in short sessions with minimal start-up time, the README.md will note that using an alias will allow the user to quicky start the game from a terminal opened anywhere on their system.

When running the game, command-line arguments can be appended (either to the "ruby \<application_name.rb>" command or the user's custom alias) to bypass the opening menu and allow the user to enter the game itself more quickly. The argument "new" will start a new game, while any other argument \<arg> will cause the game to search for a file called 
\<arg>.yml in the game directory and, if found, to parse and load it as a saved game state. 

Command-line arguments after the first will be ignored. Where a first argument other than "new" is provided (suggesting that the user is attempting to load a saved game), error handling will be used to process a range of exceptions which prevent a save file being loaded, including:

- where the argument provided is not in a format considered valid for a character/savegame name (raising a custom error);
- where a savegame file matching the argument is not found;
- where a savegame file matching the argument is found but cannot be read due to insufficient permissions; and
- where a savegame file is found and can be read but is not in a format that can be validly parsed into game date.

In the case of loading using command-line arguments, any rescued error will simply result in the user being taken to the title menu, with an additional message displayed indicating that loading failed (and stating the reason why, ie. the nature of the error in plain language) and that the user can select "Load Game" to try again.

The above process for using command-line arguments to quick-start the game will be explained in a "How to Run" section of the README.md in the repository.

## Title menu

After running the application, the first thing the user will be presented with is a title screen displaying the title of the game in ASCII-art lettering, and a prompt menu with the options "New Game", "Load Game" or "Exit" (assuming the quick-start process with command line arguments as described above was not used to skip this menu). Above the prompt menu, text will be displayed explaining that the user can navigate the prompt menu using the arrow keys, and make a selection with the "enter" or "return" key. This menu (and other similar menus throughout the application) will be implemented using the "tty-prompt" gem (https://rubygems.org/gems/tty-prompt).

If the user selects "Exit", the application exits with a message displayed in the user's terminal along the lines of "See you next time!". 

If the user selects "Load Game", the user will be prompted to enter their character's name as text input (because savegame files generated by the application will be named in the format \<character_name>.yml). That input will then be used to attempt to locate and load a saved game file in much the same manner as the process for loading using command-line arguments described above. Errors will also be handled in the same way as described above, by notifying the user of the error and returning them to the title screen to either try again or start a new game.

If the user selects "New Game", the user will enter the character creation process.

## Character creation and tutorial

After beginning a new game (either from the title menu or by passing the command line argument "new"), the player will be guided through the process of creating a character. First, they will be prompted to enter their character's name as text input. The prompt will explain the required format, including maximum name length, minimum name length, and permitted characters. To simplify the use of character names in savegame filenames, names will be required to be alphanumeric, without spaces, and within a reasonable range of lengths. Error handling will be used to raise custom errors where the provided input does not comply with the format restrictions (or where the user fails to provide input), and to handle those errors by displaying to the user a plain-language explanation of what was wrong with their input, and then re-prompting the user for new input, until a valid name is chosen.

Next, the user will be prompted to allocate a number of initial "stat points" to each of their character's combat statistics ("stats") of "Max HP", "Attack" and "Defence". The names of these statistics, a brief description of what each does, and their current values will be displayed to the player while on this screen, along with the number of stat points the player has to spend. The prompt will explain that the player can use the up and down arrows to navigate between stats, the left and right arrows to increase or decrease a stat, and "enter" to confirm. The player can adjust the value of each statistic up from or back down to its starting value (but not below), with each point of increase costing one stat point. The player can freely adjust the stat points allocated to each statistic while on this screen, until they press enter to confirm their choices.

After confirming, if not all stat points have been expended, an error will be raised and error handling will be used to display a message notifying the player that they must expend all stat points, and return them to the stat point allocation screen. 

Once a valid selection is made and confirmed, the player will be presented with a series of tutorial messages explaining the basic game controls, with a prompt to press "Enter" to progress to the next message. These tutorial messages will explain how the world map is presented and what the different symbols included in it mean (see "map navigation" below), how the player can navigate the map (using arrow keys or the "WASD" control scheme), how the player can use a hotkey to open the Options menu (which includes a "help" option to repeat the tutorial) from the map screen, and a basic explanation of game mechanics including encountering enemies, engaging in combat, leveling up, and using and equipping items.

After finishing the tutorial, the player will be presented with the map interface.

## Map navigation and display

The player will be presented with the map interface after beginning a new game and finishing the character creation and tutorial process, or after loading a saved game (and, if the latter, the state of the map and their position on it will be as recorded in the savegame file).

The map interface consists of a static 2D world map represented using ASCII art. Different symbols will be used to represent the player, different types of terrain, different monsters and any other points of interest. Those symbols will also be colour-coded using the colorize gem (https://rubygems.org/gems/colorize/versions/0.8.1) to provide greater visual distinction.

The player will be able to move their character (represented by an "@" symbol) around the map using arrow keys or "WASD" controls, as explained in the tutorial described above. Each time the player moves, the map will be updated to represent their new location. The display of the map, and receiving keypress input to navigate it, will be achieved using the Remedy gem (https://rubygems.org/gems/remedy/versions/0.3.0). 

The map itself will be represented as a 2D array of ASCII symbols, stored as an instance variable of a Map class. Each time the player attempts to move, methods of the Map class will process the movement by cross-referencing the symbol in the location the player is moving towards with a hash to determine whether the square they are trying to move to is blocked (and if so, prevent movement), open (in which case the player's location is updated in the map array and the displayed output), or occupied by a monster (in which case a combat encounter is triggered). 

The Map class method calls responsible for moving the player and updating the map will be wrapped in error handling blocks to catch errors that may arise, such as if:

- the player is attempting to move from or to a location outside the bounds of the map; or
- the player is attempting to move to a square which contains a symbol that is not included in the hash of symbols and their meanings.

The game logic should prevent these conditions from occurring in the ordinary course, but they could potentially arise if (for example) a corrupted or modified savegame file is loaded, so they should be handled. If the player is outside the bounds of the map, their position will be reset to a location within the map. If an invalid tile is found, it will be converted to an open terrain tile (or a border tile if on the border of the map). In either case, a message will be displayed to the user above the map describing what has occurred.

At all times, the player's name, current HP, max HP, current experience points and current level will be displayed in text above the map display.

## Options menu

From the map screen, the player can at any time push a hotkey to open the options menu. That hotkey will be described in the game tutorial and listed at all times above the map.

Pressing that hotkey opens a prompt menue (displayed using tty-prompt) which can be navigated using arrow keys and enter. It contains the options "Inventory", "Help", "Return to Game" and "Exit Game". 

If "Exit Game" is selected, the application saves the game state to a local file (discussed in more detail in "Saving and loading" below) and then exits the application, with a "goodbye" message to the user displayed as text.

Selecting "Help" replays the tutorial that was shown following character creation, after which the player is returned to the options menu screen.

Selecting "Return to Game", or pressing the same hotkey that was used to open the menu, will close the options menu and return the player to the map interface.

Selecting "Inventory" will take the player to another menu listing "Equipment", "Consumables" and "Back". Selecting "Back", or pressing the hotkey that opened the menu, returns the player to the main options menu. 

Selecting "Equipment" or "Consumables" takes the player to a list of equipment or consumable items in their inventory (respectively), which again can be navigated with arrow keys and enter. Pressing "enter" on an item prompts the player to confirm (with a yes / no selection prompt) if they want to equip or use (as applicable) the item. Again, this process for using items will be explained in the game tutorial.

At any level of the options menu, the player can press the same hotkey used to open the menu to move "up" one level (ie. from Equipment or Consumables to Items, from Items to the Options Menu, or from the Options Menu to exit back to the map screen). 

## Combat

When the player encounters a monster on the map, combat is triggered and the world map display is replaced by a combat interface. 

This interface consists of a menu (displayed using tty-prompt) which the player will navigate with the arrow keys and enter to select an action ("Attack", "Use Item" or "Flee"). Above this menu, the names of the player and enemy monster and their current and maximum HP values will be displayed as text. After the first round of combat, the last actions taken by the player and enemy will also be described here in text.

In each round of combat, the player selects one of the options referred to above. If the player selects "Attack", they will attack the monster, attempting to deal it damage. If they select "Use Item", they will be taken to a menu to select an item from their inventory, and (if they select and confirm use of an item) its effect will be applied (such as healing the player). If they select "Flee", they will attempt to flee (with a given probability of success or failure). In any case where the player's action does not result in combat ending, the monster will then attack the player. This sequence will repeat in a loop until combat ends.

Actions taken in combat will be handled by calling methods of the Player and Monster classes respectively, some of which will be factored out into a "Fightable" module included in both Player and Monster classes (for actions common to both, such as attacking or receiving damage). The amount of damage dealt and the probability of successfully fleeing combat will be determined using Ruby's rand() method, within a range (or based on a probability) determined by the relative statistics of the player and monster.

Combat ends when the player's or monster's HP reaches 0, or the player successfully flees. If the player flees, they are returned to the world map screen, and the monster remains on the map. Any loss of HP the player suffered in combat persists. If the player loses, they are returned to the world map screen. The monster remains on the map, and the player character's HP is restored to full, but they lose some experience points (discussed in Leveling below).

If the player wins a battle, messages are displayed showing the amount of experience points, and any items, the player received as a result of defeating the monster. After pressing "enter" to move past these messages, the player is returned to the map screen and the monster is removed from the map. Monsters are re-populated over time: each time the player moves on the map, if the total number of monsters is below a maximum threshold, there is a probability-based chance for a new monster to be placed on a random empty tile (with the probability increasing the fewer monsters are currently on the map).

The above combat mechanics will be explained to the player in simple terms in the game's tutorial.

## Leveling

When the player has earned enough experience points, they will level up. A check is performed at the end of combat to determine whether the player has leveled up, and if so, a message is displayed to the player indicating this before the player is returned to the map screen. Then, the player will be presented with a menu allowing them to allocate a number of stat points to their combat statistics. This menu will function in the same way as the interface for the initial allocation of stat points at character creation, and will have the same error raising and handling mechanisms to require the player to allocate all stat points before they can confirm their selection and return to the map screen.

This leveling system will be explained at a high level in the game's tutorial for players who may be unfamiliar with the concept.

## Saving and loading

The game will auto-save regularly, at minimum every time the player finishes combat and when they exit the game using the in-game options menu. Because the game autosaves regularly and on exit, there will be no option for the player to manually save the game. 

Saving the game will be accomplished by converting a hash which contains data representing all mutable aspects of the game state to YAML format, then writing that YAML data to a file in the local game directory, with a filename derived from the player's character name. Only one save game file will be maintained for each character name. As such, if a savegame file with the same name already exists, the application will attempt to overwrite it. If no such file exists, the game will attempt to create one and write to it.

When starting the game, the player can attempt to load a local save file by using command-line arguments or from the options menu (as described further above). Error handling that will be used when attempting to load a saved game file is also described above in the "Downloading and running the application" section. 

Additionally, error handling will be used when the game is saved. In particular:

- if a save fails because the character's name is not in a valid format (notwithstanding that this should not be possible unless game or save files have been modified), the player will be prompted to change their name to a valid format; and
- if a save fails because of insufficient write permissions or memory, this will be communicated to the player, with a suggestion that they address the error so that the game may save normally the next time an auto-save occurs.
