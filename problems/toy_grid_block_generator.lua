JSON = require "json.luajson"

local path = "./problems/toy_grid_block_" .. arg[1] .. "x" .. arg[2] .. ".json"

local ROWS = tonumber(arg[1])
local COLS = tonumber(arg[2])

local BLOCK_ROWS = 2
local BLOCK_COLS = 2

local MAX_DIST = (ROWS - 1) + (COLS - 1)

local start = string.byte('a')

local problem = {
    rows = ROWS,
    cols = COLS,

    graph = {
        pts = {},
        edges = {}
    }
}

function getidx(col, row) 
    return row * COLS + col
end

function get_rowcol(idx)
    return idx // COLS, idx % COLS
end

function dist(r1, c1, r2, c2)
    return math.abs(r1 - r2) + math.abs(c1 - c2)
end

function is_block(idx)
    local r, c = get_rowcol(idx)

    return r < BLOCK_ROWS and c < BLOCK_COLS
end

for idx = 0, ROWS * COLS - 1 do
    local key = (idx) .. ''

    local r1, c1 = get_rowcol(idx)

    -- print(idx, r1, c1)

    table.insert(problem.graph.pts, key)

    for jdx = idx + 1, ROWS * COLS - 1 do
        local dest = (jdx) .. ''

        local r2, c2 = get_rowcol(jdx)

        local weight = 0

        if is_block(idx) and is_block(jdx) and dist(r1, c1, r2, c2) == 1 then
            weight = MAX_DIST
        end

        -- if weight == 1 then
        --     weight = MAX_DIST * MAX_DIST
        -- else
        --     weight = 1
        -- end

        local edge = {
            pt1 = key,
            pt2 = dest,
            weight = weight
        }

        table.insert(problem.graph.edges, edge)
    end
end

problem.solution = "{\'" .. table.concat( problem.graph.pts, "\', \'") .. "\'}"

local str = JSON.encode(problem, true)

local file = io.open(path, "w")
file:write(str)

-- print("{\'" .. table.concat( problem.graph.pts, "\', \'") .. "\'}")