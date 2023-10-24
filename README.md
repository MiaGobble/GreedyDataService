# GreedyDataService
*A datastore solution that simplifies the player data management workflow*

# About
GreedyDataService is a simple module that allows you to easily edit player data from any server scope without any substantial datastore cooldowns (this is thanks to [boatbomber's HeatUp module](https://github.com/boatbomber/HeatUp)).

Highlighted features:
* Simplicity; ability to easily get and edit user data, even if they are not in the server
* Almost no cooldown; your saving limits are bound to MemoryService, not DataStoreService
* Scalability; use in both your personal and professional projects
* Automation for leaderstats; it can easily create leaderstat values for you, and updating the leaderstats value objects will thus update the values internally and still save (for those who use this workflow!)
* Readability; the API is readable and easily understandable, allowing the developer(s) to quickly adjust to it

### So, why should I use this over other data solutions?
I want to emphasize the ease of use for this resource. It's simplicity is unrivaled, you will not find an easier data management system.

Many data management modules require more setup, meaning *you* become the one responsibile for managing datastore limits, setup structure, sanity checking, etc. With GreedyDataService, all of that friction is lifted; simply intialize a player's data session with one line of code, which, if you want, also manages the public leaderstats values you see in the player list.

I made this resource because it feels like a huge waste of time setting up data management code with other resources. This module satisfies my needs and speeds up development!

# Installation
There are currently two ways to install this: Wally and Roblox File

### Wally
Under `[server-dependencies]`, put `greedyDataService = "igottic/greedyDataService@1.0.0"`.

### Roblox File
You can download the Roblox file by going to [releases](https://github.com/MiaGobble/GreedyDataService/releases).

# More Info
> ⚠️ This is a new resource and may be unstable. Let me know about any issues!

* Feel free to forward any suggestions or ideas to the replies section of the **[DevForum post]()**.
* Read the **[API Documentation](API.md)** to learn about how to use this.
* The **[License](LICENSE)** describes the permissions of this resource.

# Patreon
If you appreciate this resource, please consider subscribing to [my Patreon page](patreon.com/igottic) for $1 a month! Everything helps and I mega-appreciate it 💖