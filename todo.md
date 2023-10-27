# TO-DO
*This is my personal to-do, but I commit it so you can see what's coming.*

All of these changes will release over time.

## Summary
I'll strike-through bullets in this list as they are completed! Some things I need to do:
* Module restructure (3)
* Remove HeatUp and replace with strict datastore stuff (1)
* GDPR compliance (1)
* Saving restructure (1)
* Force saving (1)
* Force session release (3)
* Ability to override behavior when a session is locked, ended, or failed (3)
* Ability to turn off reconcile (3)
* Leaderboards, made with a "publicOrdered" or "privateOrdered" tag (1, 2)
* Version control and rollback (1)
* Ability to have independent data sets with custom keys/scopes without need for player (1)
* Mocking (1)
* Config for a callback function to be called when data is saved or save is failed by using a success state and save data in parameter as dictionary (2)
* Increment function (1)
* Config to optionally replace the default save behavior, so that, for example, people can use something like external clouds (2)
* Spend as currency function (decreases a value if it can be afforded, otherwise returns unsuccessful state) (1)
* Earn as currency function (1)
* Inventory/collectible system (1)
* Built-in statistics and metadata (1)
* API to connect purchases to collectibles or data changes (1)
* Value tags (1)
* Badge system (1)
* Set which keys save in private servers (with option for this, defaults to save all in private servers) (2)
* Rename resource to something new instead of "GreedyDataService" (3)

## 1: Data saving methods and structure
I first will start by removing HeatUp and using a custom solution.

Keys will now have the prefix "User_%d" for automatic GDPR compliance.

There will be one primary datastore, named "PlayerSaveData".

Structure of "PlayerSaveData":
* User_%d
    * Metadata
        * Save key names and types
        * Earned badge IDs
        * Owned gamepass IDs
        * Purchased dev product IDs
        * GUID
        * History of usernames
        * History of display names
        * Player tags
        * If this player is disqualified from leaderboards
    * Statistics
        * Number of joins
        * Average session time (in seconds)
        * Total session time (in seconds)
        * Total Robux spent
        * Robux spent on game passes
        * Robux spent on dev products
        * Total badges earned
        * Last time played (via time())
        * Daily streak
        * Total currency spent
        * Total currency earned
        * Total collectibles earned
        * Total collectibles removed
        * Total session time as premium player
        * Mouse position heatmap (ordered quadrants of where the player mouse is usually located, with quadrants being 10x10 by scale, totalling in 100 quadrants, ordered left-right & top-down, with top-left being 1, and bottom-right being 100)
    * Save
        * [Save Key Name]
            * Value
            * Tags
            * Leaderboard name (is it exists, if not it defaults to "")
        * ...

### New Methods & Properties
* `:Get(string)` and `Save.data.[string]`
* `:Set(string, any)` and `Save.data.[string] = any`
* `:Update(string, (any)->any)` and `Save.data.[string]((any)->any)`
* `:Increment(string, number)` and `Save.data.[string] += number`
* `:SpendAsCurrency(string, number, (string, number))->boolean`
* `:EarnAsCurrency(string, number)`
* `:OnNewDailyStreak((number))`
* `:ForceDataSave()->boolean`
* `:AddTag(string)`
* `:RemoveTag(string)`
* `:HasTag(string)->boolean`
* `:GetTags()->{string}` and `Save.tags.[string]`
* `:GetStatistic(string)->any` and `Player.stats.[string]`
* `:GetKeyIndexesByTag()->{string}`
* `:GetAllTagsUsed()->{string}` and `Player.meta.tags`
* `:AwardBadge(number)->boolean`
* `:OnNewBadgeEarned(number, (number))`
* `:GetEarnedBadges()->{number}`
* `:OnDevProductPurchase(number, ())`
* `:OnGamepassPurchase(number, ())`
* `:AssociateDevProductWithCurrency(number, number)`
* `:AssociateDevProductWithNumberValue(number, number)`
* `:AssociateDevProductWithCollectible(number, string, number)`
* `:AssociateGamepassWithCallback(number, (boolean))`
* `:SetStudioAsMock()`
* `:Rollback(version)`
* `:GetVersion(version)`
* `:DeleteEverything()`
* `:GetPlaceInLeaderboard(string, string)`
* `:GetTopPlayersInLeaderboard(string, number)`
* `:DisqualifyFromLeaderboards()`
* `:RequalifyFromLeaderboards()`

### Ordered Leaderboards
There will also be ordered leaderboards created for each value declared as ordered. Each ordered leaderboard will have the prefix "Leaderboard_%s" and structured like so:
* User_%d
    * Value as number

### Misc data sets
Lastly, you can save data sets that are not associated with a player. These are saved in a separate "GlobalSaveData"

## 2: Added configurations
To start, there will be a separate config module for callbacks. These include:
* OnValueSaved(({Key:string, Value:any, Successful:boolean}))
* SaveOverride(({meta:{}, stats:{}, data:{}})->boolean)
* LoadOverride(()->{meta:{}, stats:{}, data:{}}, boolean)

There are also added settings:
* KeysUnsavedInPrivateServers : {string}
* ShouldCountStatsInPrivateServers : boolean

Lastly, there are two new data types: `publicLeaderboard` and `privateLeaderboard`. These work just like `public` and `private`, except they save in leaderboards.

## 3: Misc
Here are some last things I want to mention.

### New Name
"GreedyDataService" is a sucky name. Thus, it will soon be renamed to "RichDataService".

### New Module Structure
This is how the module will be structured now:
* RichDataService
    * bin
        * playerSession
            * playerStatsHandler
                * clientConnection (automatically moved to starter player scripts as local script, fires remote made in runtime)
                * mouseHeatmapParser
        * dataSet
        * dataValue
            * valueParser
            * datastoreManager
                * leaderboardManager
        * badgeHandler
        * economyHandler
    * config
        * dataTemplate
        * settings
        * callbacks
    * ~~packages~~ packages are being removed since there are no longer any

### Other New Methods
* `:ForceSessionRelease()`
* `:GetGlobalDataSet(string)`
* `:OverrideSessionLockBehavior(())`
* `:OverrideSessionEndedBehavior(())`
* `:OverrideSessionFailBehavior(())`