# Craft The Web
"Craft The Web" (CTW) is a collaborative gaming environment that lets players research the World Wide Web together.
In the process, players will learn about what makes the Web function,
as well as about the ideas and major inventions that assisted in its creation.

CTW aims to cater for different types of gameplay, ranging from exploration to achievements.

CTW is written for Minetest, an extensible open-source crafting game environment.

For development, see [DEVELOP.md](https://github.com/CERN/CTW/blob/develop/DEVELOP.md).

## Gameplay

### General
Goal: Research technologies and cooperate in the team to discover the World Wide Web.

1. Players start from their base
2. The Team Billboard shows up the research progress
3. Find and contact various researchers (NPCs) to get ideas
4. Publish the idea on the Team Billboard
5. Gain resources (knowledge) by looking for the right books
6. Let a researcher approve your idea
7. Return the approval letter to the Team Billboard
8. Start collecting Discovery Points

### Discovery Points (DPs)
These points are gained by transferring research data to the central server.
At any point in time, cassettes can be moved manually to the server to gain DPs.

After researching certain technologies it is possible to automate it:

* Place copper wires
* Improve the wire throughput by researching technologies
* Place fiber optic cables
* Connect multiple experiments using Mergers and Splitters

### Resources
Books are resources that can be found in slowly automatic refilling bookshelves.
Each book type has an unique color, and you might need the same book type twice.

After researching technologies there will be automatic shipments of tech goods to one of your pallets.

### Team interaction
If other teams fall behind, it will be difficult for yours to win.
Helping each other to find the required resources is important,
otherwise none of the teams will reach the goal within the time limit.

### Technology tree
The entire technology tree can be found in the Team Billboard.
It is generated from the game definitions. Here's a rather recent overview:

![Tech Tree](https://github.com/CERN/CTW/raw/develop/CTW-Tech-Tree.png)


## License

Everything: GPLv3+ (see LICENSE file)

This project is partially based on [minetest_game](https://github.com/minetest/minetest_game/) (MIT license).
