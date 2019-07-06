# World

Places a schematic as the world. Use world.mts in schematics/

## API

area:

```lua
{
    from = { x=0, y=0, z=0 },
    to = { x=0, y=0, z=0 },
}
```

* world.get_location(name) -> pos
* world.get_team_location(team_name, name) -> pos
  * Team-dependent position on map.
  * name:
    * base
* world.get_area(name) -> area
* world.get_team_area(name) -> area
* world.load_locations(conf_path)
  * Load locations from configuration path.
* world.place(map_def)
  * Async
  * map_def: Table
    * pos1: pos table
    * pos2: pos table, optional
    * schematic: path, absolute

## World schematics and configuration

A world consists of 2 files:

* world.mts
* world.conf

The world.conf file can contain a list of locations like so:

```
reception = 0,0,0
spawn = 2,2,2
red.base = 3,3,3
blue.base = -3,-3,-3
```

and areas like so:

```
red.base_1 = 1,1,1
red.base_2 = 4,4,4
```

## How to import schematics from Tinkercad

Refer to tutorials:

* https://forum.minetest.net/viewtopic.php?id=6007
* https://wikifab.org/wiki/Minetest_and_3D_scanning/en
* https://dev.minetest.net/minetest.place_schematic
