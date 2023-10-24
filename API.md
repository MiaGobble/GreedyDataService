# greedyDataService
### `greedyDataService:loadPlayer(player : Player) : leaderstatsSession?`
* Takes a `Player` object
* Returns `leaderstatsSession?`

This initializes a player session. If `settings.addLeaderstatsFolder` is true, then it will also create a *leaderstats* folder under the player object with all `public` values exposed.

This method will return `nil` if the player is assumed to have left the game before they finished loading. If they are not a descendant of `Players`, then the function will yield for `settings.loadingTimeout` seconds or until they load in. In most cases this will not happen.

This will automatically clean up when the player leaves the server.

Example usage:
```lua
local greedyDataService = require(script.Parent.GreedyDataService)

local function playerAdded(player : Player)
    greedyDataService:loadPlayer(player)
end

for _, player in playersService:GetPlayers() do
    playerAdded(player)
end

playersService.PlayerAdded:Connect(playerAdded)
```

### `greedyDataService:getPlayerSession(player : Player) : leaderstatsSession?`
* Takes a `Player` object
* Returns `leaderstatsSession?`

This retrieves a `leaderstatsSession` if the player is in the game. If the player is no longer in the server, it will return `nil`.

### `greedyDataService:setValueForPlayer(player : Player, valueName : string, value : any) : boolean`
* Takes a `Player`, `ValueName : string`, and `Value : any`
* Returns a `boolean` state value

Sets a data save value for the given player with the given index and value. If the value type does not match the existing value type, this will throw an error. Returns `true` if the data was successfully saved, and `false` if not.

The player must be in the server for this to work.

### `greedyDataService:getValueFromPlayer(player : Player, valueName : string) : any, boolean`
* Takes a `Player` and `ValueName : string`
* Returns the data `value` and `boolean` state value

Gets a data save value for the given player with the given index. If the player does not exist, it will return `nil, false`. Otherwise, it returns `value, true`.

The player must be in the server for this to work.

### `greedyDataService:updateValueForPlayer(player : Player, valueName : string, transformer : (any?) -> any?) : any, boolean`
* Takes a `Player` and `Transformer : function`
* Returns the `boolean` state value

Transforms a data save value for the given player with the given index and transformer function. If the player does not exist, it will return `false`. Otherwise, it returns `true`.

The player must be in the server for this to work.

### `greedyDataService:getMemoryFromUserId(userId : number) : leaderstatsSession`
* Takes a `UserId : number`
* Returns a `leaderstatsSession`

Get a `leaderstatsSession` with a given user id. Does not require that the player is present in the server. Avoid calling this if the player *is* in the server.

# leaderstatsSession
### `leaderstatsSession:get(valueName : string) : any`
* Takes a `valueName : string`
* Returns a `value`

Call this to get the value of a `leaderstatsSession`.

Alternatively, you can index leaderstatsSession.data. So, for example, instead of doing:
```lua
local x = leaderstatsSession:get("myValue")
```

You can do
```lua
local x = leaderstatsSession.data.myValue
```

### `leaderstatsSession:set(valueName : string, value : any) : any`
* Takes a `valueName : string` and `value : any`
* Returns a `value`

Sets a data save value with the given index and value parameters. If the value type does not match the existing value type, this will throw an error.

Alternatively, you can index leaderstatsSession.data. So, for example, instead of doing:
```lua
leaderstatsSession:set("myValue", 10)
```

You can do
```lua
leaderstatsSession.data.myValue = 10
```

### `leaderstatsSession:update(valueName : string, transformer : (any) -> any)`
Transforms a data save value with the given index and transformer function. The transformer function has an existing `value` in the parameter, and returns the updated value.

Alternatively, you can index leaderstatsSession.data. So, for example, instead of doing:
```lua
leaderstatsSession:update("myValue", function(oldValue)
    return oldValue + 1
end)
```

You can do
```lua
leaderstatsSession.data("myValue", function(oldValue)
    return oldValue + 1
end)
```

# dataTemplate
The dataTemplate is how you lay out the data to be saved.

Values can be `public` or `private`. If `addLeaderstatsFolder` is equal to `true`, then all `public` values are replicated in the player's *leaderstats* folder. Otherwise, all `public` values are made `private` in functionality.

This must return an array of values.

> ⚠️ DO NOT USE "[", "]", "{", OR "}" AT THE BEGINNING OR END OF A STRING VALUE! This will cause errors!

> ☝️ You may use strings, numbers, booleans, and tables as value types.

### Example
```lua
return {
    public(0) "Money", -- Defaults to 0, named "Money". Will appear in leaderstats
    public(0) "XP", -- Defaults to 0, named "XP". Will appear in leaderstats
    private(0) "Joins", -- Defaults to 0, named "Joins". Will not appear in leaderstats
    private("new") "Status" -- Defaults to "new", named "Status". Will not appear in leaderstats
}
```

In this example, four datastore values are created, and of them "Money" and "XP" are declared public and thus replicated in the *leaderstats* folder.

Here is an example of a script using this structure:

```lua
local greedyDataService = require(script.Parent.GreedyDataService)

local function playerAdded(player : Player)
    local leaderstatsSession = greedyDataService:loadPlayer(player)

    leaderstatsSession.data.Money = 1000 -- Sets "Money" to 1000
    leaderstatsSession:set("XP", 500) -- Sets "XP" to 500
    -- leaderstatsSession.data.whatever = value is the
    -- same as leaderstatsSession:set("whatever", value)

    -- For the rest of this, instead of using methods, I'll index .data

    leaderstatsSession.data("Joins", function(lastNumberOfJoins)
		return lastNumberOfJoins + 1
	end) -- Increments "Joins" by 1

    -- You can also do leaderstatsSession.data.Joins += 1

    if leaderstatsSession.data.Status == "new" then
        -- If a player is new, then say they are a rookie
        leaderstatsSession.data.Status = "rookie"

    elseif leaderstatsSession.data.Joins > 10 then
        -- If they joined more than 10 times, they are a visitor!
        leaderstatsSession.data.Status = "visitor"

    elseif leaderstatsSession.data.Joins > 100 then
        -- Wow, over 100 visits! They are now a regular.
        leaderstatsSession.data.Status = "regular"
    end

    print(leaderstatsSession:get("Status"))
    -- Prints "rookie", "visitor", or "regular"

    print(leaderstatsSession.data.Status)
    -- Should print the same thing again!
end

for _, player in playersService:GetPlayers() do
    playerAdded(player)
end

playersService.PlayerAdded:Connect(playerAdded)
```

### `public(defaultValue : any) -> (valueName : string) -> value`
Declares a `public` value given a default value and value name. See the above example to see how this is used.

### `private(defaultValue : any) -> (valueName : string) -> value`
Declares a `private` value given a default value and value name. See the above example to see how this is used.