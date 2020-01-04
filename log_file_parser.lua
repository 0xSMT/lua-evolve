local selections = {"tournament", "roulette"}
local mutations = {"tbe", "pairwise"}
local crossovers = {"order2", "order1"}

local prefix = "./output_old/"
local prob_suffix = ".json_log.txt"

local problems = {"block_12x12", "4x4", "5x5", "5x6"}

local repetitions = 5


local db = {}
for _, prob in ipairs(problems) do
    print(prob)

    for _, mut in ipairs(mutations) do
        for _, sel in ipairs(selections) do
            for _, crx in ipairs(crossovers) do
                local log = {}

                local sum_time = 0
                local sum_fit = 0
                local sum_iter = 0

                local sum_explored = 0
                local state_space = nil

                local num_ideal = 0

                local best = math.huge
                local ideal = 0

                for rep = 1, repetitions do
                    local file_name = prefix .. mut .. "_" .. sel .. "_" .. crx .. "_" .. prob .. "_" .. tostring(rep) .. prob_suffix
                    -- local file = io.open(file_name, "r")
                    local tab = {}

                    for line in io.lines(file_name) do
                        local t = {}

                        for w in line:gmatch("%S+") do
                            table.insert(t, w)
                            -- print(w)
                        end

                        tab[t[1]] = t[#t]
                    end

                    tab["FINAL"] = tonumber(tab["FINAL"])
                    tab["IDEAL"] = tonumber(tab["IDEAL"])
                    tab["ITERS"] = tonumber(tab["ITERS"])
                    tab["TIME"] = tonumber(tab["TIME"])

                    local frac = {}
                    for w in tab["MAX"]:gmatch("([^/]*)/?") do
                        table.insert(frac, w)
                    end

                    tab["EXPLORED"] = tonumber(frac[1])
                    tab["STATE"] = frac[2]

                    ideal = tab["IDEAL"]

                    if tab["FINAL"] < best then
                        best = tab["FINAL"]
                    end

                    sum_time = sum_time + tab["TIME"]
                    sum_fit = sum_fit + tab["FINAL"]
                    sum_iter = sum_iter + tab["ITERS"]

                    sum_explored = sum_explored + tab["EXPLORED"]
                    state_space = tab["STATE"]

                    if tab["FINAL"] == tab["IDEAL"] then
                        num_ideal = num_ideal + 1
                    end

                    table.insert(log, tab)
                end

                sum_time = sum_time / repetitions
                sum_fit = sum_fit / repetitions
                sum_iter = sum_iter / repetitions

                sum_explored = sum_explored / repetitions

                print(mut .. "-" .. sel .. "-" .. crx..":\t"..best..", "..sum_iter..", "..sum_fit..", "..sum_explored.."/"..state_space..", "..ideal)

                db[mut .. "_" .. sel .. "_" .. crx .. "_" .. prob] = log
            end
        end
    end
end