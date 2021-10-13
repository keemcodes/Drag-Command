// This is made for NGG by Yisui Chaos.
// This script is dedicated for NGG. NGG staff may use my work HOWEVER they please.

// Forward this at the top of the script...
forward Dragging(copid, crimid);
// Done.

// Set the variables below.
new DragTimer[MAX_PLAYERS]; // This variable is set for the criminal being dragged, it basically just teleports the criminal to the LEO everyone set amount of seconds.
enum CopDrag // Group variables for copdrag.
{
	Cop, // If this group variable is set to 1 that means the cop is dragging someone.
	Crim, // If this group variable is set it means the criminal is being dragged.
	CopPlayer[MAX_PLAYERS], // This is sets a variable on the cop to the id of the player they are dragging.
	CrimPlayer[MAX_PLAYERS] // This sets a variable on the criminal to the id of the cop that is dragging them.
}
new Drag[MAX_PLAYERS][CopDrag];
// Done.

// A function that starts the drag.
DragStart(copid, crimid)
{
	Drag[copid][Cop] = 1;
	Drag[crimid][Crim] = 1;
	Drag[copid][CopPlayer] = crimid;
	Drag[crimid][CrimPlayer] = copid;
	DragTimer[crimid] = SetTimerEx("Dragging", 1000, 1, "dd", copid,crimid);
}
//Done.

// A function that stops the drag.
DragStop(copid, crimid)
{
	Drag[copid][Cop] = 0;
	Drag[crimid][Crim] = 0;
	Drag[copid][CopPlayer] = 696991;
	Drag[crimid][CrimPlayer] = 696991;
	KillTimer(DragTimer[crimid]);
}
// Done.

// Add this under "OnPlayerConnect"
Drag[playerid][Cop] = 0;
Drag[playerid][Crim] = 0;
Drag[playerid][CopPlayer] = 696991;
Drag[playerid][CrimPlayer] = 696991;
// This sets it to an ID that will not be used by SAMP in any kind of way no time soon. Better than the classic 999 that people thought samp would never get to.
// Done.

// Add this under "OnPlayerDisconnect"
if(Drag[playerid][Cop] == 1)
{
	if(IsPlayerConnected(Drag[playerid][CopPlayer]))
	{
		SendClientMessageEx(Drag[playerid][CopPlayer], COLOR_YELLOW, "The cop dragging you has left the server.");
		DragStop(playerid, Drag[playerid][CopPlayer]);
	}
}
if(Drag[playerid][Crim] == 1)
{
	if(IsPlayerConnected(Drag[playerid][CrimPlayer]))
	{
		SendClientMessageEx(Drag[playerid][CrimPlayer], COLOR_YELLOW, "The person you were dragging has left the server.");
		DragStop(Drag[playerid][CrimPlayer], playerid);
	}
}
// This basically just stops the drag if the cop or criminal logs out.
// Done.


// Please add this to some of your admin commands. Like /prison.
DragStop(Drag[giveplayerid][CrimPlayer], giveplayerid);
// This is really important to do with some admin commands like /jail and /prison. Maybe /gethere and others.
// Basically just stops the drag if an admin uses a command on a player.
// Done.

// The actual command. I made it in a toggle format. To begin or stop the drag just do /drag (id). Please switch the texts to whatever you guys like.
CMD:drag(playerid, params[])
{
	if(IsACop(playerid) || PlayerInfo[playerid][pMember] == 4 && PlayerInfo[playerid][pDivision] == 2 || PlayerInfo[playerid][pMember] == 4 && PlayerInfo[playerid][pRank] >= 5 || (PlayerInfo[playerid][pMember] == 12 && PlayerInfo[playerid][pDivision] == 2))
	{
		if(GetPVarInt(playerid, "Injured") == 1)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You can't do this right now.");
			return 1;
		}

		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_WHITE, "USAGE: /drag [playerid]");

		if(IsPlayerConnected(giveplayerid))
		{
			if (ProxDetectorS(8.0, playerid, giveplayerid))
			{
				if(giveplayerid == playerid) { SendClientMessageEx(playerid, COLOR_GREY, "You cannot drag yourself!"); return 1; }
				if(PlayerCuffed[giveplayerid] == 1)
				{ SendClientMessageEx(playerid, COLOR_GREY, "That player isn't cuffed!"); return 1; }
				if(Drag[giveplayerid][CrimPlayer] != playerid && Drag[giveplayerid][CrimPlayer] != 696991)
				{ SendClientMessageEx(playerid, COLOR_GREY, "This player is being dragged by a different cop!"); return 1; }
				if(Drag[playerid][CopPlayer] != giveplayerid && Drag[playerid][CopPlayer] != 696991)
				{ SendClientMessageEx(playerid, COLOR_GREY, "So you rambo? You wanna drag two at once?"); return 1; }
				if(Drag[giveplayerid][Crim] == 0)
				{
					format(string, sizeof(string), "* You are being dragged by %s.", GetPlayerNameEx(playerid));
					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, string);
					format(string, sizeof(string), "* You are dragging %s.", GetPlayerNameEx(giveplayerid));
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, string);
					format(string, sizeof(string), "* %s grabs %s with a tight grip and begins to forcefully drag him.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					GameTextForPlayer(giveplayerid, "~r~Dragging", 2500, 3);
					TogglePlayerControllable(giveplayerid, 0);
					DragStart(playerid, giveplayerid);
					//Dragger[playerid] = 1;
					//Dragged[giveplayerid] = 1;
				}
				else
				{
					format(string, sizeof(string), "* %s stopped dragging you.", GetPlayerNameEx(playerid));
					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, string);
					format(string, sizeof(string), "* You stopped dragging %s.", GetPlayerNameEx(giveplayerid));
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, string);
					format(string, sizeof(string), "* %s loosens his grasp on %s, letting him stand freely.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					TogglePlayerControllable(giveplayerid, 0);
					DragStop(playerid, giveplayerid);
					//Dragger[playerid] = 0;
					//Dragged[giveplayerid] = 0;
				}
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "That player isn't near you.");
				return 1;
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Invalid player specified.");
			return 1;
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GREY, "You're not a law enforcement officer.");
	}
	return 1;
}
// Done.




// Add this to "OnPlayerEnterVehicle".
if(Drag[playerid][Cop] == 1)
{
	SendClientMessageEx(playerid, COLOR_GREY, "* You can't enter a car while dragging a player.");
	RemovePlayerFromVehicle(playerid);
	new Float:slx, Float:sly, Float:slz;
	GetPlayerPos(playerid, slx, sly, slz);
	SetPlayerPos(playerid, slx, sly, slz);
}
// This keeps the cop from entering a vehicle while dragging.
// Done.


// Public function for dragging.
public Dragging(copid, crimid)
{
	new Float:dX, Float:dY, Float:dZ;
	GetPlayerPos(copid, dX, dY, dZ);
	SetPlayerPos(crimid, dX+1, dY, dZ);
	if(GetPlayerInterior(copid) != GetPlayerInterior(crimid))
	{
		SetPlayerVirtualWorld(crimid, GetPlayerVirtualWorld(copid));
		SetPlayerInterior(crimid, GetPlayerInterior(copid));
		PlayerInfo[crimid][pInt] = GetPlayerInterior(copid);
		PlayerInfo[crimid][pLocal] = GetPlayerVirtualWorld(copid);
		PlayerInfo[crimid][pVW] = GetPlayerVirtualWorld(copid);
	}
	if(GetPlayerVirtualWorld(copid) != GetPlayerVirtualWorld(crimid))
	{
		SetPlayerVirtualWorld(crimid, GetPlayerVirtualWorld(copid));
		SetPlayerInterior(crimid, GetPlayerInterior(copid));
		PlayerInfo[crimid][pInt] = GetPlayerInterior(copid);
		PlayerInfo[crimid][pLocal] = GetPlayerVirtualWorld(copid);
		PlayerInfo[crimid][pVW] = GetPlayerVirtualWorld(copid);
	}
}
// This is the actual drag action.
// Done.



// Thank you for reviewing my work. I hope this works well if implemented. If you have any questions to ask me...
// feel free to email me at refuser101@gmail.com - I respond almost instantly.
