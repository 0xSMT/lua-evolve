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
    -- self.chromosome     = args.chromosome

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
        [fitness]       = best,
        [chromosome]    = nil
    }

    for i, v in ipairs(pop) do
        if pop[i].fitness == nil then
            pop[i].fitness = self.fit(v)
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
        [fitness]       = self.minimize and math.huge or -math.huge,
        [chromosome]    = nil
    }

    local stime = os.time()

    -- repeat for at most maxiter generations
    for iter = 1, maxiter do
        -- calculate fitness related values
        local elite = self.calc_fitness(population, elite.fitness)
        local range = Util.range(population, "fitness")

        -- check if the population has converged sufficiently (exit condition)
        if range < self.minintv then
            break
        end

        -- check if enough time has elapsed (exit condition)
        if maxtime > os.time() - stime then
            break
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
            local offspring = self.crossover(p1, p2)

            -- mutate (or not) each child and add it to the children table
            for _, child in pairs(offspring) do
                if math.random() > self.mutation.rate then
                    table.insert(children, child)
                else
                    local mutant = self.mutation.fn(child)
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

    return elite
end

return Evolve