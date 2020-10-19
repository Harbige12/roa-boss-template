# roa-boss-template
A guide and code repository on how to make bosses for Rivals of Aether.

By Harbige12.

# Introduction
So you've deceded to make a boss for Rivals of Aether, huh? This guide should make it easier to create the boss of your dreams, all using stage scripting.

Start by downloading the boss template, and put it in your Rivals of Aether app data folder, under the "stages/" folder.

# Getting Started
When you open this stage in the stage editor, it will be blank. You can set up its properties and such here.
The stage creation process is similar to normal stage development. Once completed, you may add the following:

1. Markers
..* These tell the game where to add the boss. Place a marker where you want to spawn the boss.

2. Articles
..* You can also tell the game to spawn the boss with an article spawn point, but I don't recommend it.

# Important Files
These files are needed for the code to work. You can download them from this repository.

**init.gml**: The main stage init.
**update.gml**: The main stage update.
**other_init.gml**: Sets up player lives
**player_death.gml**: Player death handling
**draw_hud.gml**: HUD Draw calls

**article6**: The main enemy parent object.
**article16**: The boss death object (optional, but helps to have)

# Local files
These files can be added to the boss template and work if the above files are in the scripts folder.
Some template files are included in this repository.

**load.gml** Sets up sprite offsets
**user_event1.gml** Called when the stage is started
**user_event2.gml** Called when the stage updates every frame.
**user_event6.gml** Called when an enemy is updated every frame.
