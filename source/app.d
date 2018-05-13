import vibe.vibe;

import std.process;

//version = WebFreak;

void main()
{
	auto settings = new HTTPServerSettings;
	settings.port = 3000;
	settings.bindAddresses = ["::1", "192.168.178.80"];
	// Enables sessions which are stored in memory
	// RedisSessionStore can also be used when connected with a Redis database.

	// Additional Session Stores: (third party)
	// MongoDB Session Store - available via the dependency `mongostore`
	settings.sessionStore = new MemorySessionStore;

	auto router = new URLRouter;
	// calls index function when / is accessed
	router.get("/", &index);
	router.post("/key", &postKey);
	router.post("/text", &postText);
	router.post("/shutdown", &postShutdown);
	// Serves files out of public folder
	router.get("*", serveStaticFiles("./public/"));

	listenHTTP(settings, router);

	runApplication();
}

void index(HTTPServerRequest req, HTTPServerResponse res)
{
	res.render!("index.dt");
}

void postKey(HTTPServerRequest req, HTTPServerResponse res)
{
	logInfo("xdotool key %s", req.query.get("key"));
	auto ret = execute(["xdotool", "key", req.query.get("key")]);
	res.writeBody(ret.output);
}

void postText(HTTPServerRequest req, HTTPServerResponse res)
{
	logInfo("xdotool type %s", req.query.get("text"));
	auto ret = execute(["xdotool", "type", req.query.get("text")]);
	res.writeBody(ret.output);
}

void postShutdown(HTTPServerRequest req, HTTPServerResponse res)
{
	version (WebFreak)
	{
		executeShell("killall hexchat chrome thunar telegram-desktop DiscordCanary Discord");
		executeShell("killall DiscordCanary Discord");
		execute(["fish", "-c", "synchome; and systemctl poweroff"]);
	}
	else
	{
		execute(["systemctl", "poweroff"]);
	}
}
