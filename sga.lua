local Evolve = {}
Evolve.__index = Evolve

Util = require "util"

-- TODO: Can the distinction between minimzaiton and maximizaiton problems be accounted for simply by negating the fitness function?

function Evolve.new(args)
    local self = {}
    -- contains data about mutation rate and mutation operation (function)
    self.mutation       = args.mutation

    -- predicate for determining feasibility
    self.is_feasible    = args.is_feasible

    -- a funciton for fitness (for both feasibles and infeasibles)
    self.fitness        = args.fitness

    -- the crossover function (takes two parents and returns two children) -- also has crossover rate
    self.crossover      = args.crossover

    -- -- function for mapping onto a chromosomal representation (takes raw population member, )
    self.chromosome     = args.chromosome

    -- procedure for selecting from the population (a function that takes a fitness function as argument)
    self.selection      = args.selection

    -- is maxi or mini
    self.minimize       = args.minimize or false 

    setmetatable(self, Evolve)
    return self
end

function Evolve:fit(chromosome)
    if self.is_feasible(chromosome) then
        return self.fitness.feasible(chromosome)
    else
        return self.fitness.infeasible(chromosome)
    end
end

-- calculate the fitness
function Evolve:calc_fitness(pop, best)
    local elite = {
        fitness       = best.fitness,
        chromosome    = best.chromosome
    }

    for i, v in ipairs(pop) do
        if pop[i].fitness == nil then
            pop[i].fitness = self:fit(v.chromosome)
        end

        if self.minimize then
            if pop[i].fitness < elite.fitness then
                elite = v
                -- elite.fitness = pop[i].fitness
            end
        else
            if pop[i].fitness > elite.fitness then
                elite = v
                -- elite.fitness = pop[i].fitness
            end
        end
    end

    return elite
end

function Evolve:run(initial_population, termination_conditions)
    local maxtime = termination_conditions.maxtime
    local maxiter = termination_conditions.maxiter
    local minintv = termination_conditions.minintv

    local population    = initial_population
    local popsize       = #population

    local elite = {
        fitness       = self.minimize and math.huge or -math.huge,
        chromosome    = nil
    }

    local stime = os.time()

    local iterations = 1

    -- repeat for at most maxiter generations
    for iter = 1, maxiter do
        iterations = iter
        
        -- calculate fitness related values
        elite = self:calc_fitness(population, elite)

        -- function dump(o)
        --     if type(o) == 'table' then
        --        local s = '{ '
        --        for k,v in pairs(o) do
        --           if type(k) ~= 'number' then k = '"'..k..'"' end
        --           s = s .. '['..k..'] = ' .. dump(v) .. ','
        --        end
        --        return s .. '} '
        --     else
        --        return tostring(o)
        --     end
        --  end

        -- -- for k, v in pairs(population) do
        -- --     print(dump(v))
        -- -- end

        local range = Util.range(population, "fitness")

        -- check if the population has converged sufficiently (exit condition)
        if range <= minintv then
            print("BREAK -- Range: " .. range .. " < " .. minintv)
            break
        end

        -- check if enough time has elapsed (exit condition)
        if maxtime < os.time() - stime then
            break
        end

        if iter % 10 == 0 then
            print(iter, range, os.time() - stime, elite.fitness)
        end

        -- select the parents from the population
        local parents  = {}
        for i = 1, popsize do
            table.insert(parents, self.selection(population))
        end

        local children = {}

        -- elitism -- the best of the best continues through each generation
        table.insert(children, elite)

        local num_children = 1

        repeat
            -- uniformly select parents for crossover
            local p1 = Util.draw(parents)
            local p2 = Util.draw(parents)

            -- produce schildren from crossover
            local offspring = self.crossover(p1.chromosome, p2.chromosome)

            -- mutate (or not) each child and add it to the children table
            for _, child in pairs(offspring) do
                dump(child)
                if math.random() > self.mutation.rate then
                    local new = child
                    table.insert(children, new)
                else
                    local mutant = self.mutation.fn(child.chromosome)
                    table.insert(children, mutant)
                end

                num_children = num_children + 1
            end
        until num_children >= popsize

        -- if too many children were created, kill the excess
        for i = 1, num_children - popsize do
            children[num_children + i] = nil
        end
        
        -- set the next generation
        population = children
    end

    print(iterations)

    return elite
end

return Evolve