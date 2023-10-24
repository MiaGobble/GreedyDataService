local dataType = {}

type allowedType = string | number | boolean | table

type dataType = {
    valueName : string,
    defaultValue : allowedType,
    dataType : "string" | "number" | "boolean" | "table",
    scope : "public" | "private",
}

local allowedTypes = {"string", "number", "boolean", "table"} :: {allowedType}

local function new(defaultValue : allowedType, isPublic : boolean) : (string) -> dataType
    if not table.find(allowedTypes, typeof(defaultValue)) then
        error("Invalid type for default value")
    end

    return function(valueName : string) : dataType
        return {
            valueName = valueName,
            defaultValue = defaultValue,
            dataType = typeof(defaultValue),
            scope = isPublic and "public" or "private",
        } :: dataType
    end
end

function dataType.public(defaultValue : allowedType) : (string) -> dataType
    return new(defaultValue, true)
end

function dataType.private(defaultValue : allowedType) : (string) -> dataType
    return new(defaultValue, false)
end

return dataType