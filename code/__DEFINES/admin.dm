//A set of constants used to determine which type of mute an admin wishes to apply:
//Please read and understand the muting/automuting stuff before changing these. MUTE_IC_AUTO etc = (MUTE_IC << 1)
//Therefore there needs to be a gap between the flags for the automute flags
#define MUTE_IC (1<<0)
#define MUTE_OOC (1<<1)
#define MUTE_PRAY (1<<2)
#define MUTE_ADMINHELP (1<<3)
#define MUTE_DEADCHAT (1<<4)
#define MUTE_ALL (~0)

//Some constants for DB_Ban
#define BANTYPE_PERMA		1
#define BANTYPE_TEMP		2
#define BANTYPE_JOB_PERMA	3
#define BANTYPE_JOB_TEMP	4
#define BANTYPE_ANY_FULLBAN	5 //used to locate stuff to unban.

#define BANTYPE_ADMIN_PERMA	7
#define BANTYPE_ADMIN_TEMP	8
#define BANTYPE_ANY_JOB		9 //used to remove jobbans

//Admin Permissions
#define R_BUILDMODE		(1<<0)
#define R_ADMIN			(1<<1)
#define R_BAN			(1<<2)
#define R_FUN			(1<<3)
#define R_SERVER		(1<<4)
#define R_DEBUG			(1<<5)
#define R_POSSESS		(1<<6)
#define R_PERMISSIONS	(1<<7)
#define R_STEALTH		(1<<8)
#define R_POLL			(1<<9)
#define R_VAREDIT		(1<<10)
#define R_SOUNDS		(1<<11)
#define R_SPAWN			(1<<12)
#define R_AUTOLOGIN		(1<<13)
#define R_DBRANKS		(1<<14)

#define R_DEFAULT R_AUTOLOGIN

#define R_EVERYTHING ALL //the sum of all other rank permissions, used for +EVERYTHING

#define ADMIN_QUE(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];adminmoreinfo=[REF(user)]'>?</a>)"
#define ADMIN_FLW(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];adminplayerobservefollow=[REF(user)]'>FLW</a>)"
#define ADMIN_PP(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];adminplayeropts=[REF(user)]'>PP</a>)"
#define ADMIN_VV(atom) "(<a href='byond://?_src_=vars;[HrefToken(TRUE)];Vars=[REF(atom)]'>VV</a>)"
#define ADMIN_SM(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];subtlemessage=[REF(user)]'>SM</a>)"
#define ADMIN_TP(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];traitor=[REF(user)]'>TP</a>)"
#define ADMIN_KICK(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];boot2=[REF(user)]'>KICK</a>)"
#define ADMIN_CENTCOM_REPLY(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];CentComReply=[REF(user)]'>RPLY</a>)"
#define ADMIN_SYNDICATE_REPLY(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];SyndicateReply=[REF(user)]'>RPLY</a>)"
#define ADMIN_SC(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];adminspawncookie=[REF(user)]'>SC</a>)"
#define ADMIN_SMITE(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];adminsmite=[REF(user)]'>SMITE</a>)"
#define ADMIN_LOOKUP(user) "[key_name_admin(user)][ADMIN_QUE(user)]"
#define ADMIN_LOOKUPFLW(user) "[key_name_admin(user)][ADMIN_QUE(user)] [ADMIN_FLW(user)]"
#define ADMIN_SET_SD_CODE "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];set_selfdestruct_code=1'>SETCODE</a>)"
#define ADMIN_FULLMONTY_NONAME(user) "[ADMIN_QUE(user)] [ADMIN_PP(user)] [ADMIN_VV(user)] [ADMIN_SM(user)] [ADMIN_FLW(user)] [ADMIN_TP(user)] [ADMIN_INDIVIDUALLOG(user)] [ADMIN_SMITE(user)]"
#define ADMIN_FULLMONTY(user) "[key_name_admin(user)] [ADMIN_FULLMONTY_NONAME(user)]"
#define ADMIN_TPMONTY_NONAME(user) "[ADMIN_QUE(user)] [ADMIN_JMP(user)] [ADMIN_FLW(user)]"
#define ADMIN_TPMONTY(user) "[key_name_admin(user)] [ADMIN_TPMONTY_NONAME(user)]"
#define ADMIN_JMP(src) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)"
#define COORD(src) "[src ? "([src.x],[src.y],[src.z])" : "nonexistent location"]"
#define AREACOORD(src) "[src ? "[get_area_name(src, TRUE)] ([src.x], [src.y], [src.z])" : "nonexistent location"]"
#define ADMIN_COORDJMP(src) "[src ? "[COORD(src)] [ADMIN_JMP(src)]" : "nonexistent location"]"
#define ADMIN_VERBOSEJMP(src) "[src ? "[AREACOORD(src)] [ADMIN_JMP(src)]" : "nonexistent location"]"
#define ADMIN_INDIVIDUALLOG(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];individuallog=[REF(user)]'>LOGS</a>)"
#define ADMIN_JMP_MSGTERMINAL(src) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];adminplayerobservecoodjump=1;X=[69];Y=[77];Z=[1]'>JMP</a>)"

#define ADMIN_PUNISHMENT_LIGHTNING "Lightning bolt"
#define ADMIN_PUNISHMENT_BRAINDAMAGE "Brain damage"
#define ADMIN_PUNISHMENT_GIB "Gib"
#define ADMIN_PUNISHMENT_BSA "Bluespace Artillery Device"
#define ADMIN_PUNISHMENT_FIREBALL "Fireball"
#define ADMIN_PUNISHMENT_ROD "Immovable Rod"
#define ADMIN_PUNISHMENT_SUPPLYPOD_QUICK "Supply Pod (Quick)"
#define ADMIN_PUNISHMENT_SUPPLYPOD "Supply Pod"
#define ADMIN_PUNISHMENT_MAZING "Puzzle"
#define ADMIN_PUNISHMENT_PIE "Cream Pie"
#define ADMIN_PUNISHMENT_CUSTOM_PIE "Custom Cream Pie"
#define ADMIN_PUNISHMENT_SHOES "Knot Shoes"
#define ADMIN_PUNISHMENT_CRACK ":B:oneless"
#define ADMIN_PUNISHMENT_BLEED ":B:loodless"
#define ADMIN_PUNISHMENT_SCARIFY "Scarify"
#define ADMIN_PUNISHMENT_PICKLE "Pickle-ify"
#define ADMIN_PUNISHMENT_FRY "Fry"
#define ADMIN_PUNISHMENT_PERFORATE ":B:erforate"

#define AHELP_ACTIVE 1
#define AHELP_CLOSED 2
#define AHELP_RESOLVED 3

#define ROUNDSTART_LOGOUT_REPORT_TIME	6000 //Amount of time (in deciseconds) after the rounds starts, that the player disconnect report is issued.

#define SPAM_TRIGGER_WARNING	5	//Number of identical messages required before the spam-prevention will warn you to stfu
#define SPAM_TRIGGER_AUTOMUTE	10	//Number of identical messages required before the spam-prevention will automute you
