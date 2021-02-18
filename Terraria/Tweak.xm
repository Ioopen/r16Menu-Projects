#import "Menu.h"

struct Vector2 {
    float x;
    float y;
};

struct p_players {
	Vector2 newPos;
	bool canSpawn = true;
	bool canOpenBossBag = true;
	bool canDie = true;
	bool shouldBuff = true;
	bool shouldTP = true;
	bool shouldTP1 = true;
};

void *(*CreateString)(void *player, const char *str);
void (*Player_KillMe) (void *player, double dmg, int hitDirection, bool pvp);
void (*Player_AddBuff) (void *player, int type, int time1, bool quiet);
void (*Player_Teleport)(void *player, Vector2 newPos, int Style, int extraInfo);
void (*Player_OpenBossBag) (void *player, int type);
void (*Player_QuickSpawnItem)(void *player, int item, int stack);

void (*_Player_Update) (void *player, int i);
void Player_Update (void *player, int i){
	if(player != NULL) {
		if([menu getSwitchOnForSwitch:@"Treasure Bag:"]){
			int bagID = [menu getInt:@"Treasure Bag:"];
			if(canOpenBossBag){
				Player_OpenBossBag(player, bagID); 
				p_players::canOpenBossBag = false;
			}
		} else {
			p_players::canOpenBossBag = true;
		}

		int item = [menu getInt:@"Spawn Item:"];
		if([menu getSwitchOnForSwitch:@"Spawn Item:"]) {
			int stack = [menu getInt:@"Item Amount:"];

			if([menu getSwitchOnForSwitch:@"Item Amount:"]){
				if(canSpawn){
					Player_QuickSpawnItem(player, item, stack); 
					p_players::canSpawn = false;
				}
			} else {
				if(canSpawn){
					Player_QuickSpawnItem(player, item, 1); 
					p_players::canSpawn = false;
				}
			}
		} else {
			p_players::canSpawn = true;
		}

		if([menu getSwitchOnForSwitch:@"Buff ID:"]){
			int buffID = [menu getInt:@"Buff ID:"];
			int time1 = [menu getInt:@"Buff Time:"];

			if([menu getSwitchOnForSwitch:@"Buff Time:"]){
				if(shouldBuff){
					Player_AddBuff(player, buffID, time1, true); 
					p_players::shouldBuff = false;
				}
			}
		} else {
			p_players::shouldBuff = true;
		}

		if([menu getSwitchOnForSwitch:@"Suicide"]){
			if(canDie) {
				Player_KillMe(player, /*CreateString(NULL, "Killed by [c/0DA6FF:Red16] [c/2FF511:Server]")*/ 600, 0, false);
				p_players::canDie = false;
			}
		} else {
			p_players::canDie = true;
		}

		Vector2 DeathPos = *(Vector2*)[UIKeyPatch address:[APISession serverAddressAtIndex:33] ptr:player];
		if([menu getSwitchOnForSwitch:@"LastDeathPosition"]){
			if(shouldTP){
				Player_Teleport(player, DeathPos, 0, 0); 
				p_players::shouldTP = false;
			}
		} else {
			p_players::shouldTP = true;
		}

		if([menu getSwitchOnForSwitch:@"Change Y:"]){
			p_players::newPos.y = [menu getInt:@"Change Y:"];
 
			if([menu getSwitchOnForSwitch:@"Change X:"]){
				if(shouldTP1){
					p_players::newPos.x = [menu getInt:@"Change X:"];
					Player_Teleport(player, p_players::newPos, 0, 0); 
					p_players::shouldTP1 = false;
				}
			}
		} else {
			p_players::shouldTP1 = true;
		}

		if([menu getSwitchOnForSwitch:@"Inf-Fly"]){
			*(float*)[UIKeyPatch address:[APISession serverAddressAtIndex:24] ptr:player] = 999999999.0f;
		}

		if([menu getSwitchOnForSwitch:@"Ghost Mode"]){
			*(bool*)[UIKeyPatch address:[APISession serverAddressAtIndex:23] ptr:player] = true;
		} else {
			*(bool*)[UIKeyPatch address:[APISession serverAddressAtIndex:23] ptr:player] = false;
		}

		if([menu getSwitchOnForSwitch:@"Insta Revive"]){
			*(float*)[UIKeyPatch address:[APISession serverAddressAtIndex:22] ptr:player] = 0.0f;
		}

		if([menu getSwitchOnForSwitch:@"Spaz"]){
			*(int*)[UIKeyPatch address:[APISession serverAddressAtIndex:21] ptr:player] = 0.0f;
		}

		if([menu getSwitchOnForSwitch:@"Set_Mana"]){
			*(int*)[UIKeyPatch address:[APISession serverAddressAtIndex:25] ptr:player] = [menu getInt:@"Set_Mana"];
			*(int*)[UIKeyPatch address:[APISession serverAddressAtIndex:26] ptr:player] = [menu getInt:@"Set_Mana"];
		}

		if([menu getSwitchOnForSwitch:@"Set_Health"]){
			*(int*)[UIKeyPatch address:[APISession serverAddressAtIndex:27] ptr:player] = [menu getInt:@"Set_Health"];
			*(int*)[UIKeyPatch address:[APISession serverAddressAtIndex:28] ptr:player] = [menu getInt:@"Set_Health"];
		}

		if([menu getSwitchOnForSwitch:@"Godmode"]){
			*(int*)[UIKeyPatch address:[APISession serverAddressAtIndex:20] ptr:player] = [menu getInt:@"Set_Health"];
		}
	}
	_Player_Update(player, i);
}


void (*_ItemCheck) (void *item, int i);
void ItemCheck (void *item, int i){

	if([menu getSwitchOnForSwitch:@"Inf-Mana"]){
		*(float*)[UIKeyPatch address:[APISession serverAddressAtIndex:18] ptr:item] = 0.0f; // manaCost
	}
	if([menu getSwitchOnForSwitch:@"Set_MaxMinions"]){
		*(int*)[UIKeyPatch address:[APISession serverAddressAtIndex:19] ptr:item] = [menu getInt:@"Set_MaxMinions"];// maxMinions
	}
	_ItemCheck(item, i);
}


double (*_StrikeNPC)(void *npc, int Damage, float knockBack, int hitDirection, bool crit, bool noEffect, bool fromNet);
double StrikeNPC(void *npc, int Damage, float knockBack, int hitDirection, bool crit, bool noEffect, bool fromNet)
{
	bool townNPC = *(bool*)((uint64_t)npc + 0x1D4);
	bool friendly = *(bool*)((uint64_t)npc + 0x1EC);

	if(friendly && townNPC) {
		if([menu getSwitchOnForSwitch:@"One-Hit Kill"]){
			return _StrikeNPC(npc, 999999999, knockBack, hitDirection, crit, noEffect, fromNet);
		}
	}
      return _StrikeNPC(npc, Damage, knockBack, hitDirection, crit, noEffect, fromNet);
}


void setUp() {

    Player_OpenBossBag = (void (*) (void *, int))[UIKeyPatch getRealOffset:[APISession serverAddressAtIndex:34]];
    Player_Teleport = (void (*)(void *, Vector2, int, int))[UIKeyPatch getRealOffset:[APISession serverAddressAtIndex:32]];
    CreateString = (void *(*)(void *, const char *))[UIKeyPatch getRealOffset:[APISession serverAddressAtIndex:17]];
    Player_KillMe = (void (*) (void *, double, int, bool))[UIKeyPatch getRealOffset:[APISession serverAddressAtIndex:16]];
    Player_AddBuff = (void (*) (void *, int, int, bool))[UIKeyPatch getRealOffset:[APISession serverAddressAtIndex:31]];
	Player_QuickSpawnItem = (void (*)(void *, int, int))[UIKeyPatch getRealOffset:[APISession serverAddressAtIndex:3]];

	[r16Hook hook:[APISession serverAddressAtIndex:2]
				with:(void *)Player_Update 
				original:(void **)&_Player_Update];
				
	[r16Hook hook:[APISession serverAddressAtIndex:8]
				with:(void *)ItemCheck 
				original:(void **)&_ItemCheck];

	[r16Hook hook:[APISession serverAddressAtIndex:5]
				with:(void *)StrikeNPC 
				original:(void **)&_StrikeNPC];
	
	[menu addPatch:r16Encrypt("Godmode")
		  description:r16Encrypt("")
             offsets:@[[APISession serverAddressAtIndex:6]]
             hexPatches:@[[APISession serverAddressAtIndex:7]]];
			 
	[menu addSwitch:r16Encrypt("Inf-Mana")
		  description:r16Encrypt("Leave this on infinite mp")];

	[menu addSwitch:r16Encrypt("One-Hit Kill")
	      description:r16Encrypt("")];

	[menu addSwitch:r16Encrypt("Inf-Fly")
	      description:r16Encrypt("")];

	[menu addPatch:r16Encrypt("No Drown")
          description:r16Encrypt("") 
             offsets:@[[APISession serverAddressAtIndex:9]]
             hexPatches:@[[APISession serverAddressAtIndex:10]]];
	
	[menu addTextfieldRight:r16Encrypt("Spawn Item:") 
		  description:r16Encrypt("")];
		
	[menu addTextfieldRight:r16Encrypt("Item Amount:") 
	      description:r16Encrypt("")];
		
	[menu addTextfieldRight:r16Encrypt("Set_MaxMinions") 
	      description:r16Encrypt("Use this to surpass max minions limit")];

	[menu addSwitch:@"Spaz"
          description:@""];

	[menu addSwitch:@"Suicide"
          description:@""];

	[menu addSwitch:@"Ghost Mode"
          description:@""];

	[menu addSwitch:@"Insta Revive"
          description:@""];

	[menu addSwitch:@"No Dash-Delay"
          description:@""];

	[menu addSwitch:@"LastDeathPosition"
          description:@""];

	[menu addTextfieldRight:@"Buff ID:" 
          description:@"(ID)"];

	[menu addTextfieldRight:@"Buff Time:" 
          description:@"(number)"];

	[menu addTextfieldRight:@"Set_Health" 
          description:@"(number)"];

	[menu addTextfieldRight:@"Set_Mana" 
          description:@"(number)"];

	[menu addTextfieldRight:@"Treasure Bag:"
          description:@"(ID)"];

	[menu addTextfieldRight:@"Change Y:" 
		  description:@"(number)"];

	[menu addTextfieldRight:@"Change X:" 
          description:@"(number)"];
}

void startAuthentication() {
//initiate r16Authorization
[APISession inittializeAddressFromServer:^{

	#import "r16Logo.h"

     menu.socialShareMessage = r16Encrypt("Im using Terraria Cheats by Rednick16_");
     menu.sharingIconBorderColor = rgba(0xffffff, 1.0);

     r16Theme.baseColor = rgba(0x1c2f4f, 0.9);

     //r16Theme.headerBackground = rgba(0x5f04cf, 1.0);
     //r16Theme.footerBackground = rgba(0x5f04cf, 1.0);
     //r16Theme.menuBackground = rgba(0x7300ff, 0.9);
     //r16Theme.keyOnColor = rgba(0x8423fa,1.0);
     //r16Theme.keyOffColor = rgba(0x7b00ff,0.9);
     r16Theme.menuShadowColor = rgba(0x1c2f4f, 0.3);

    [menu closeTaps:1 width:270 
          maxVisableToggles:5
          title:r16Encrypt("Terraria Modmenu") 
          credits:r16Encrypt("Made by Red16")];
    setUp();
  }];
}


void removeLaunchEvent(void);
static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
    timer(0.1){
        startAuthentication();
    });
}

void launchEvent() {
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), Observer, &didFinishLaunching, (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorDrop);
}

__attribute__((constructor)) static void initialize() {
    launchEvent();
}