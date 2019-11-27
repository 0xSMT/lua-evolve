local PPP = require '/problems/ppp'
local SGA = require 'sga'

local mutation  = require 'mutations/tbe'
local selection = require 'selections/roulette'
local crossover = require 'crossovers/order1'

-- local problem = PPP.parse("problems/toy.json")
local problem = PPP.create_problem(4, 4, 4, 4, 0.0, 5.0)

math.randomseed(os.time())

local evo = SGA.new(PPP.start(problem, mutation, crossover, selection))

local termination_conditions = {
    ["maxtime"] = 60,
    ["maxiter"] = 5000000,
    ["minintv"]  = 1.0
}

local ipop = PPP.init_population(50, problem) 

-- print(table.unpack(ipop))

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end

local elite = evo:run(ipop, termination_conditions)

print(dump(elite))