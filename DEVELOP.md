# CTW Development Guide


## Setup

1. Create a new singlenode map
2. `/grantme creative`
3. Ensure following nodes exist for each team:
	* Team Billboard
	* Experiment
	* Central Server
4. General purpose `^npc:.*` spawner nodes
5. Do a map backup for later restore
6. TODO: Define the bookshelf locations somehow

Alternatively:

1. Download a demo map such as [this one](https://krock-works.uk.to/u/ctw_dummy.tar.gz) (symlink-capable filesystem only).
2. Change `world.mt` to change between read-only and the writeable map.
	* Map backups will be rather superfluous.

## Game start

1. `/join red` to join team red
2. ??


## Soft Gameplay reset

1. Reset the current team using `// wipe .`
2. Pray that all callbacks were run properly (maybe rejoin?)

To go back (or forward) to to the state of 1983:

1. Run `// year . 1983`
2. Rejoin, just to make sure.

## Hard Gameplay reset

1. Remove the directory `??/worlds/WORLDNAME/mod_storage`
2. Restore the map backup
3. Re-join the team