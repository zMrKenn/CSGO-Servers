#if defined _marquee_included_
  #endinput
#endif
#define _marquee_included_

SharedPlugin:__pl_marquee = 
{
	name = "Marquee",
	file = "marquee.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

/**
 * Starts a marquee on a list of clients.
 *
 * @param clients    	An array of clients to send to.
 * @param numClients    Number of players in the array.
 * @param message    	The message to display.
 * @param intercept    	Stop any currently running marquee and start this one.
 * @return        		True if started, false otherwise.
 */
native bool Marquee_Start(const clients[], numClients, const char[] message, bool intercept=true);
 
/**
 * Starts a marquee on a client.
 *
 * @param client    	The client to send the panel to.
 * @param message    	The message to display.
 * @param intercept    	Stop any currently running marquee and start this one.
 * @return        		True if started, false otherwise.
 */
native bool Marquee_StartOne(client, const char[] message, bool intercept=true);

/**
 * Starts a marquee on all clients.
 *
 * @param message    	The message to display.
 * @param intercept    	Stop any currently running marquee and start this one.
 * @return        		True if started, false otherwise.
 */
native bool Marquee_StartAll(const char[] message, bool intercept=true);

/**
 * Stops the marquee currently running on a client.
 *
 * @param client    	The client to stop the marquee from.
 * @noreturn
 */
native Marquee_Stop(client);

/**
 * Checks, whether a client is currently watching a marquee.
 *
 * @param client    	The client to check.
 * @return				True if he's watching a marquee, false otherwise.
 */
native bool Marquee_IsRunning(client);

/**
 * Called when a marquee message is about to start on a client.
 *
 * @param client			Client index of player to send to.
 * @param sMessage			Message to send.
 * @return					Action to handle the message.
 */
forward Action Marquee_OnStart(client, const char[] sMessage);