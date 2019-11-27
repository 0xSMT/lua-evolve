local Util = require 'util'
local Luajson = require 'json/luajson'

local ppp = {}
ppp.__index = ppp

ppp.fitness = function(problem_specs)
    local fns = {}

    fns.feasible = function(chromosome)
        local locations = {}

        local dist = function(pt1, pt2)
            return math.abs(pt1.x - pt2.x) + math.abs(pt1.y - pt2.y)
        end

        for row = 1, chromosome.rows do
            for col = 1, chromosome.cols do
                local val = chromosome.data[(row - 1) * chromosome.cols + col]
                locations[val] = {x = col, y = row}
            end
        end

        local sum = 0.0

        for _, edge in pairs(problem_specs.graph.edges) do
            sum = sum + edge.weight * dist(locations[edge.pt1], locations[edge.pt2])
        end

        return sum
    end

    fns.infeasible = function(chromosome)
        return 0.0
    end

    return fns
end

ppp.is_feasible = function(chromosome)
    return true
end

ppp.generate = function(problem_specs)
    return function()
        local len = problem_specs.rows * problem_specs.cols

        local permutation = Util.shuffle(problem_specs.graph.pts)

        return permutation
    end
end

ppp.chromosome = function(problem_specs)
    return function(permutation)
        local unit = {chromosome = {}}

        unit.chromosome.data     = permutation
        unit.chromosome.rows     = problem_specs.rows
        unit.chromosome.cols     = problem_specs.cols
        unit.chromosome.graph    = problem_specs.graph

        -- ASSUMPTION: The grid is assumed to be full
        assert(#unit.chromosome.data == unit.chromosome.rows * unit.chromosome.cols)

        return unit
    end
end

ppp.parse = function(file)
    local f = assert(io.open(file, "rb"))
    
    local content = f:read("*all")
    f:close()

    return Luajson.decode(content)
end

ppp.init_population = function(popsize, problem_specs)
    local population = {}
    local generator = ppp.generate(problem_specs)
    local chromosome = ppp.chromosome(problem_specs)
    
    for i = 1, popsize do
        local unit = generator()
        table.insert(population, chromosome(unit))
    end

    return population
end

ppp.start = function(problem_specs, mutation, crossover, selection)
    -- local problem_specs = ppp.parse(jsonfile)
    
    return {
        mutation    = {rate = 0.20, fn = mutation(ppp.chromosome(problem_specs))},
        crossover   = crossover(ppp.chromosome(problem_specs)),
        selection   = selection(true),
        is_feasible = ppp.is_feasible,
        fitness     = ppp.fitness(problem_specs),
        chromosome  = ppp.chromosome(problem_specs),
        minimize    = true,
    }
end

ppp.create_problem = function(min_rows, max_rows, min_cols, max_cols, min_weight, max_weight)
    min_rows = min_rows or 2
    max_rows = max_rows or 25

    min_cols = min_cols or 2
    max_cols = max_cols or 25

    min_weight = min_weight or 0.0
    max_weight = max_weight or 50.0
    
    local problem = {}

    problem.rows = min_rows + math.random(max_rows - min_rows + 1)
    problem.cols = min_cols + math.random(max_cols - min_cols + 1)

    problem.graph = {}
    problem.graph.pts = {}
    problem.graph.edges = {}

    for i = 1, problem.rows * problem.cols do
        table.insert(problem.graph.pts, i)

        for j = i + 1, problem.rows * problem.cols do
            local edge = {}
            edge.pt1 = i
            edge.pt2 = j
            edge.weight = min_weight + math.random() * (max_weight - min_weight)

            table.insert(problem.graph.edges, edge)
        end
    end

    print("generated problem!")
    return problem
end

return ppp