local Evolve = {}
Evolve.__index = Evolve

Util = require "util"

function Evolve.new(args)
    local self = {}
    -- contains data about mutation rate and mutation operation (function)
    self.mutation       = args.mutation

    -- predicated for determining feasibility
    self.is_feasible    = args.is_feasible

    -- a funciton for fitness (for both feasibles and infeasibles)
    self.fitness        = args.fitness

    -- the crossover function (takes two parents and returns two children) -- also has crossover rate
    self.crossover      = args.crossover

    -- function for mapping onto a chromosomal representation (takes raw population member, )
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
    local fitness_vals = {}
    local elite = {
        [fitness]       = best,
        [chromosome]    = nil
    }

    for i, v in ipairs(pop) do
        fitness_vals[i] = self.fit(v)

        if self.minimize then
            if fitness_vals[i] < elite.fitness then
                elite.chromosome = v
            end
        else
            if fitness_vals[i] > elite.fitness then
                elite.chromosome = v
            end
        end
    end

    return fitness_vals, elite
end

function Evolve:run(initial_population, termination_conditions)
    local maxtime = termination_conditions.maxtime
    local maxiter = termination_conditions.maxiter
    local minintv = termination_conditions.minintv

    local population    = initial_population
    local popsize       = #population

    local elite = {
        [fitness]       = self.minimize and math.maxinteger or math.mininteger,
        [chromosome]    = nil
    }

    local stime = os.time()

    -- repeat for at most maxiter generations
    for iter = 1, maxiter do
        -- calculate fitness related values
        local fitness_vals, elite = self.calc_fitness(population, elite.fitness)
        local range = Util.range(fitness_vals)

        -- check if the population has converged sufficiently (exit condition)
        if range < self.minintv then
            break
        end

        -- check if enough time has elapsed (exit condition)
        if maxtime > os.time() - stime then
            break
        end

        -- select the parents from the population
        local parents = self.selection(population, fitness_vals)
        local children = {}
        local num_children = 0

        repeat
            -- uniformly select parents for crossover
            local p1 = Util.draw(parents)
            local p2 = Util.draw(parents)

            -- produce schildren from crossover
            local offspring = self.crossover(p1, p2)

            -- mutate (or not) each child and add it to the children table
            for _, child in pairs(offspring) do
                if math.random() >= self.mutation.rate then
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