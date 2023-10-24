local dataTypes = require(script.dataType)
local public = dataTypes.public
local private = dataTypes.private

-- NOTE: DO NOT USE "[", "]", "{", OR "}" AT THE BEGINNING OR END OF A STRING VALUE

return {
    public(0) "Money",
    public(0) "XP",
    private(0) "Joins",
    private("new") "Status",
    public(true) "TestBool",
    private({}) "Inventory",
}