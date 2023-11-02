#if defined _snowball_included
 #endinput
#endif
#define _snowball_included


/**
 * Called when a player hits other player with snowball (decoy)
 *
 * @param client		Client who hitted other player with snowball.
 * @param attacker		Player who got hitted by snowball.
 * @return				Plugin_Handled to block the actual server banning.
 *						
 */
forward void Snowball_HitPlayer(int client, int attacker);