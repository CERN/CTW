# CHEATENGINE


If you happen to have the "server" privilege, this mod allows you to modify
several values in the game to simulate progress in the game.


## Available Commands

The command format is `// key arg arg ...`, whereas following keys exist.
The full stop `.` is a special character which may stand for a team- or player
name, depending on the context

### dp (Modify DPs)

	Team  Modifier&Number
	.     +420             Add 420 DPs
	.     -420             Remove 420 DPs
	.      420             Set DPs to 420
	green  0               Reset DPs of team "green"

### idea (Modify idea state)
Outputs all registered IDs if there is an invalid entry.

	Team  Modifier&Idea_ID
	.     +idea_id         Next idea state
	.     -idea_id         Previous idea state
	green +idea_id         Apply for team "green"

### team (Change the team)

	Player  Team
	.       green   Switch to team "green"
	Ninja   green   Apply for player "Ninja"

### tech (Modify tech state)
Processes all given IDs. Outputs all registered IDs if there are invalid entries.

	Team  Modifier&Tech_ID
	.     +tech_id         Technology = gained
	.     -tech_id         Technology = undiscovered
	green +tech_id         Apply for team "green"
	red   +id1 -id2 ..     Bulk update

### wipe (Delete team data)
Deletes any team data

    Team
	.    Current team
	all  All teams


### year (Set year number)
Resets any technologies and idea states after this year and sets all preceding
states to completed.

    Team  Year
	.     1980 Back to the start
	red   1984 Ready for tokenring, cerndoc, tangle
