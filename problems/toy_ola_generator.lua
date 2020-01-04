JSON = require "json.luajson"

local path = "./problems/toy_ola_big_linear.json"

local LIM = 26
local start = string.byte('a')

local problem = {
    rows = 1,
    cols = LIM,
    graph = {
        pts = {},
        edges = {}
    }
}

for i = 0, LIM - 1 do
    local key = string.char(start + i)

    table.insert(problem.graph.pts, key)

    for j = i + 1, LIM - 1 do
        local dest = string.char(start + j)

        local edge = {
            pt1 = key,
            pt2 = dest,
            weight = LIM - (j - i)
        }

        table.insert(problem.graph.edges, edge)
    end
end

local str = JSON.encode(problem, true)

local file = io.open(path, "w")
file:write(str)

print("{\'" .. table.concat( problem.graph.pts, "\', \'") .. "\'}")