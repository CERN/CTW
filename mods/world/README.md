# World

Places a schematic as the world. Use world.mts in schematics/

## API

* world.get_location(name) -> pos
* world.get_team_location(team_name, name) -> pos
  * Team-dependent position on map.
  * name:
    * base
* world.load_locations(conf_path)
  * Load locations from configuration path.
* world.place(map_def)
  * Async
  * map_def: Table
    * pos1: pos table
    * pos2: pos table, optional
    * schematic: path, absolute

## How to import schematics from Tinkercad

Refer to tutorials :
* https://forum.minetest.net/viewtopic.php?id=6007
* https://wikifab.org/wiki/Minetest_and_3D_scanning/en
* https://dev.minetest.net/minetest.place_schematic
