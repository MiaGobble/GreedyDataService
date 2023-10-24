-- Define the class
local dataValue = {}
dataValue.__index = dataValue

local PREFIX = "%d/%s"
local LEADERSTATS_INSTANCE_TYPE_REMAP = {
    string = "StringValue",
    number = "NumberValue",
    boolean = "BoolValue",
    table = "StringValue",
}

type possibleDataTypes = "string" | "number" | "boolean" | "table"

type dataType = {
    valueName : string,
    defaultValue : string | number | boolean | table,
    dataType : possibleDataTypes,
    scope : "public" | "private",
}

local httpService = game:GetService("HttpService")

local heatup = require(script.Parent.Parent.packages.heatup)
local datastore = heatup.new("greedyDataService")

local function getEncodedAsValue(value : any) : any
    if typeof(value) ~= "string" then
        return value
    elseif (value:sub(1, 1) == `[` or value:sub(1, 1) == "{") and (value:sub(value:len(), value:len()) == `]` or value:sub(value:len(), value:len()) == "}") then
        return httpService:JSONDecode(value)
    else
        return value
    end
end

local function getValueAsEncoded(value : any) : any
    if typeof(value) == "table" then
        return httpService:JSONEncode(value)
    else
        return value
    end
end

-- Constructor
function dataValue.new(dataType : dataType, userId : number)
    local self = setmetatable({}, dataValue)
   
    self.valueName = dataType.valueName
    self.defaultValue = dataType.defaultValue
    self.dataType = dataType.dataType
    self.scope = dataType.scope
    self.userId = userId

    self.leaderstatsValueInstance = nil
    self.currentValue = nil

    self:init()

    return self
end

function dataValue:init()
    local encodedValue = datastore:Get(PREFIX:format(self.userId, self.valueName), self.defaultValue)
    self.currentValue = getEncodedAsValue(encodedValue)
end

function dataValue:getLeaderstatsValueInstance() : StringValue | NumberValue | BoolValue
    if self.leaderstatsValueInstance then
        return self.leaderstatsValueInstance
    end

    local valueInstance = Instance.new(LEADERSTATS_INSTANCE_TYPE_REMAP[self.dataType]) :: StringValue | NumberValue | BoolValue
    local value = getValueAsEncoded(self.currentValue)

    valueInstance.Name = self.valueName
    valueInstance.Value = value
    self.leaderstatsValueInstance = valueInstance

    valueInstance:GetPropertyChangedSignal("Value"):Connect(function()
        print("change")
        if valueInstance.Value ~= getValueAsEncoded(self:get()) then
            print("update")
            self:set(valueInstance.Value)
        end
    end)

    return valueInstance
end

function dataValue:get()
    return self.currentValue
end

function dataValue:set(newValue : possibleDataTypes)
    if typeof(newValue) ~= self.dataType then
        error("Invalid type for new value")
    end

    local encodedValue = getValueAsEncoded(newValue)

    self.currentValue = newValue
    datastore:Set(PREFIX:format(self.userId, self.valueName), encodedValue)
end

function dataValue:update(transformer : (any?) -> any?)
    local newValue = transformer(self.currentValue)

    if newValue == nil then
        return
    end

    self:set(newValue)
end

-- Return the class
return dataValue