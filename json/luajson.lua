local Luajson = {}
Luajson.__index = Luajson

Luajson.type_key = Luajson
Luajson.array = 1
Luajson.object = 2

function Luajson.decode(data)
    data = string.gsub(data, "%s+", "")
    data = string.gsub(data, "%[", "{")
    data = string.gsub(data, "%]", "}")
    data = "return " .. string.gsub(data, '("[^"]-"):', '[%1]=')
    return load(data)()
end

local function pencode(ttable, depth, pretty)
    local list = {}
    local prefix = pretty and string.rep("\t", depth) or ""

    -- TODO: Test the performance of this scheme (an additional function call) rather than inserting this code where the call is.
    local function concat_elem(list, val, depth)
        local t = type(val)
    
        if t == "number" then
            list[#list] = list[#list] .. tostring(val)
        elseif t == "string" then
            list[#list] = list[#list] .. '"' .. val .. '"'
        elseif t == "boolean" then
            list[#list] = list[#list] .. tostring(val)
        elseif t == "table" then
            local temptab = {
                list[#list], 
                "{", 
                (pretty and "\n" or ""),
                pencode(val, depth + 1, pretty), 
                (pretty and "\n" or ""), 
                prefix,
                "}"
            }

            if val[1] ~= nil then   -- is an array
                temptab[2], temptab[7] = "[", "]"
            end

            list[#list] = table.concat(temptab)
        end
    end

    -- if an object and not an array
    if ttable[1] == nil then
        for key, val in pairs(ttable) do
            list[#list + 1] = prefix .. '"' .. key .. '":' .. (pretty and " " or "") 
            concat_elem(list, val, depth)
        end
    -- else if is an array and not an object
    else
        for _, val in ipairs(ttable) do
            list[#list + 1] = prefix
            concat_elem(list, val, depth)
        end
    end

    local div = "," .. (pretty and "\n" or "")

    return table.concat(list, div)
end

function Luajson.encode(ttable, pretty)
    pretty = pretty or false

    local str = {}
    str[#str + 1] = "{" .. (pretty and "\n" or "")
    str[#str + 1] = pencode(ttable, 1, pretty)
    str[#str + 1] = (pretty and "\n" or "") .. "}"

    return table.concat(str)
end

local function read_all(file)
    local f = assert(io.open(file, "rb"))
    local content = f:read("*all")
    f:close()
    return content
end

-- local str = read_all("./toy.json")
-- local t = Luajson.decode(str)

-- print(table.unpack(t.edges))

return Luajson