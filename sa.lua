local SimulatedAnnealing = {}
SimulatedAnnealing.__index = SimulatedAnnealing

Util = require "util"

function SimulatedAnnealing.new(args)
    local self = {}
    -- contains data about mutation rate and mutation operation (function)
    self.mutation       = args.mutation

    -- predicate for determining feasibility
    self.is_feasible    = args.is_feasible

    -- a funciton for fitness (for both feasibles and infeasibles)
    self.fitness        = args.fitness

    -- -- function for mapping onto a chromosomal representation (takes raw population member, )
    self.chromosome     = args.chromosome

    -- is maxi or mini
    self.minimize       = args.minimize or false 

    setmetatable(self, SimulatedAnnealing)
    return self
end

function SimulatedAnnealing:fit(state)
    if self.is_feasible(state.chromosome) then
        return self.fitness.feasible(state.chromosome)
    else
        return self.fitness.infeasible(state.chromosome)
    end
end

-- arguments for simulated annealing: alpha, beta, t0, i0
function SimulatedAnnealing:run(initial_generator, sa_args, foolish, max_time, logdata)
    local maxtime = maxtime or 5 * 60
    
    local log = nil
    if logdata then
        log = {
            best_fitness = {},
            curr_fitness = {},
            time = 0,
            iterations = 0,
            temperature = {}
        }
    end

    local total_iterations = 0
    
    -- initial state (randomly chosen)
    local state = initial_generator()
    state.fitness = self:fit(state)
    -- initial temperature
    local temperature = sa_args.t0
    -- initial iteratiors 
    local iterations = sa_args.i0

    local elite = {
        fitness       = state.fitness,
        chromosome    = state.chromosome
    }

    -- start time of algorithm
    local stime = os.time()

    repeat
        local i = iterations
        repeat 
            local new_state = self.mutation.fn(state.chromosome)

            local h_news    = self:fit(new_state)
            local h_s       = self:fit(state)

            if (h_news < h_s) or (not foolish and (math.random() < math.exp((h_s - h_news) / temperature)))  then
                state = new_state
                state.fitness = h_news
            end
            
            i = i - 1
            total_iterations = total_iterations + 1

            if state.fitness < elite.fitness then
                elite = state
            end

            if logdata then
                local best_fitness  = {total_iterations, elite.fitness}
                local curr_fitness  = {total_iterations, state.fitness}
                local temperature   = temperature

                table.insert(log.best_fitness, best_fitness)
                table.insert(log.curr_fitness, curr_fitness)
                table.insert(log.temperature, temperature)
            end

            if total_iterations % 100 == 0 then
                local s = string.format( "%d\t%.2f\t%d\t%.2f\t%.2f\t%.2f", total_iterations, state.fitness, os.time() - stime, elite.fitness, temperature, iterations)
                print(s)
            end

        until i <= 0
        
        temperature = sa_args.alpha * temperature
        iterations = sa_args.beta * iterations
    until os.time() - stime > maxtime or temperature < 0.5

    if logdata then
        log.time = os.time() - stime
        log.iterations = total_iterations
    end

    return elite, log
end

return SimulatedAnnealing