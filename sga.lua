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

    -- for determining when to execute another restart of population
    self.stagnation_threshold = args.stagnation_threshold

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

    local sum_fit = 0

    for i, v in ipairs(pop) do
        if pop[i].fitness == nil then
            pop[i].fitness = self:fit(v.chromosome)
        end

        sum_fit = sum_fit + pop[i].fitness

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

    return elite, sum_fit / #pop
end

function Evolve:run(initial_population_generator, termination_conditions, logdata)
    local maxtime = termination_conditions.maxtime
    local maxiter = termination_conditions.maxiter

    local solution = termination_conditions.ideal

    local stagnation_counter = 0

    local true_elite = nil
    local local_elite = {}

    local log = nil
    if logdata then
        log = {
            best_fitness = {},
            mutation = {},
            average_fitness = {},
            true_elite_fitness = {},
            time = 0,
            generations = 0
        }
    end

    local population    = initial_population_generator()
    local popsize       = #population

    local last_elite = {
        fitness       = 0,
        chromosome    = nil
    }

    local elite = {
        fitness       = self.minimize and math.huge or -math.huge,
        chromosome    = nil
    }

    local stime = os.time()

    local iterations = 1

    local restarts = 0

    -- repeat for at most maxiter generations
    for iter = 1, maxiter do
        iterations = iter
        
        local average_fitness = 0
        -- calculate fitness related values
        last_elite = elite
        elite, average_fitness = self:calc_fitness(population, elite)

        -- adaptive mutation
        if last_elite.fitness == elite.fitness then
            local rate = self.mutation.rate + 0.001
            self.mutation.rate = math.min(rate, self.mutation.max_rate)

            stagnation_counter = stagnation_counter + 1
        else
            local rate = self.mutation.rate - 0.05
            self.mutation.rate = math.max(rate, self.mutation.min_rate)

            stagnation_counter = 0
        end

        if stagnation_counter > self.stagnation_threshold then
            break
        end

        -- if true_elite == nil then
        --     true_elite = elite
        --     restarts = 0
        -- else   
        --     if self.minimize and elite.fitness < true_elite.fitness then
        --         true_elite = elite
        --         restarts = 0
        --     elseif not self.minimize and elite.fitness > true_elite.fitness then
        --         true_elite = elite
        --         restarts = 0
        --     end 
        -- end

        -- if stagnation_counter > self.stagnation_threshold then
        --     if restarts < 3 then
        --         print("RESTART!")
        --         restarts = restarts + 1

        --         if restarts == 3 then
        --             print("RESTART LIMIT REACHED!")
        --             break
        --         end

        --         table.insert(local_elite, elite)
            
        --         elite = {
        --             fitness       = self.minimize and math.huge or -math.huge,
        --             chromosome    = nil
        --         }
                
        --         population = initial_population_generator()
        --         last_elite = elite
        --         elite, average_fitness = self:calc_fitness(population, elite)

        --         stagnation_counter = 0
        --     else

        --     end
        -- end

        if logdata then
            -- local true_best_fit = true_elite.fitness
            local true_best_fit = elite.fitness

            local fit =         {iter, elite.fitness}
            local mut =         {iter, self.mutation.rate}
            local avg_fit =     {iter, average_fitness}
            local true_fit =    {iter, true_best_fit}

            table.insert(log.best_fitness, fit)
            table.insert(log.average_fitness, avg_fit)
            table.insert(log.mutation, mut)
            table.insert(log.true_elite_fitness, true_fit)
        end

        -- check if enough time has elapsed (exit condition)
        if maxtime < os.time() - stime then
            break
        end

        if solution and elite.fitness == solution then
            break
        end

        if iter % 100 == 0 then
            local true_best = true_elite and true_elite.fitness or elite.fitness
            local s = string.format( "%d\t%.2f\t%d\t%.2f\t%.3f\t%d\t%.2f", iter, average_fitness, os.time() - stime, elite.fitness, self.mutation.rate, stagnation_counter, true_best)
            print(s)
        end

        -- select the parents from the population
        local parents  = self.selection(population, popsize)
        local children = {}

        local num_children = 1

        -- if elite.fitness == true_elite.fitness and #local_elite > 0 then
        --     -- print("Local Elite Dump!")
        --     for _, v in pairs(local_elite) do
        --         table.insert(children, v)
        --         num_children = num_children + 1
        --     end
        -- end

        repeat
            -- uniformly select parents for crossover
            local p1 = Util.draw(parents)
            local p2 = Util.draw(parents)

            -- produce schildren from crossover
            local offspring = self.crossover(p1.chromosome, p2.chromosome)

            -- mutate (or not) each child and add it to the children table
            for _, child in pairs(offspring) do
                local cfit = self:fit(child.chromosome)

                if math.random() > self.mutation.rate then
                    child.fitness = cfit
                    table.insert(children, child)
                else
                    local mutant = self.mutation.fn(child.chromosome)
                    mutant.fitness = self:fit(mutant.chromosome)
                    table.insert(children, mutant)

                    -- if mutant.fitness < cfit then
                    --     child.fitness = cfit
                    --     table.insert(children, child)
                    -- end
                end

                num_children = num_children + 1
            end
        until num_children >= popsize

        -- if too many children were created, kill the excess
        for i = 1, num_children - popsize do
            children[num_children + i] = nil
        end

        -- elitism -- the best of the best continues through each generation
        table.insert(children, elite)

        -- local elite_mutant = self.mutation.fn(elite.chromosome)
        -- table.insert(children, elite_mutant)
        
        -- set the next generation
        population = children
    end

    -- print(iterations)

    if logdata then
        log.time = os.time() - stime
        log.generations = iterations
    end

    if true_elite == nil then true_elite = elite end

    return true_elite, log
end

return Evolve