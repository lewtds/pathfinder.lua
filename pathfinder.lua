-- Copyright © 2016 Trung Ngo

-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the “Software”),
-- to deal in the Software without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

local function table_get_default(table, key, default)
  return table[key] or default
end


-- FIXME: very naive and sloooow implementation lol
local PriorityQueue = {}

function PriorityQueue.new(comparer)
  return {
    comparer = comparer
  }
end

function PriorityQueue.add(queue, node)
  table.insert(queue, node)
  table.sort(queue, queue.comparer)
end

function PriorityQueue.pop(queue)
  return table.remove(queue)
end




local Pathfinder = {}

local function constant_weight(n1, n2)
  return 1
end

-- neighbors:node => List<{node, weight}>
-- weight:node => node => number
-- heuristic:node => number
function Pathfinder.astar(start, dest, neighbors, weight, heuristic)
  weight = weight or constant_weight
  local come_from = {}
  local seen = {}
  local fscore = {[start] = 0}
  local gscore = {[start] = 0}

  local to_search = PriorityQueue.new(function (n1, n2)
    return table_get_default(fscore, n1, math.huge) > table_get_default(fscore, n2, math.huge)
  end)

  local current = start
  while current and current ~= dest do
    seen[current] = true

    for i,node in ipairs(neighbors(current)) do
      if not seen[node] then
        local tentative_gscore = table_get_default(gscore, current, math.huge) + weight(current, node)

        if gscore[node] == nil then
          PriorityQueue.add(to_search, node)

          if tentative_gscore < table_get_default(gscore, node, math.huge) then
            come_from[node] = current
            gscore[node] = tentative_gscore
            fscore[node] = tentative_gscore + heuristic(node, dest)
          end
        end
      end
    end

    current = PriorityQueue.pop(to_search)
  end

  return come_from
end


function Pathfinder.shortest_path(arg)
  local start, dest, neighbors, weight, heuristic = arg.start, arg.dest, arg.neighbors, arg.weight, arg.heuristic
  local come_from = Pathfinder.astar(start, dest, neighbors, weight, heuristic)

  local path = {}
  local current = dest
  while true do
    local prev = come_from[current]
    if prev == nil then break end

    table.insert(path, 1, current)
    current = prev
  end

  return path
end



function Pathfinder.weights_from_point(arg)
  local start, neighbors, weight, max_weight =
    arg.start,
    arg.neighbors,
    arg.weight or constant_weight,
    arg.max_weight or math.huge

  local weights = {[start] = 0}
  local to_search = {}

  local current = start
  while current do
    if weights[current] >= max_weight then
      break
    end

    for _,node in ipairs(neighbors(current)) do
      if not weights[node] then
        weights[node] = weights[current] + weight(current, node)
        table.insert(to_search, 1, node)
      end
    end

    current = table.remove(to_search)
  end

  return weights
end


return Pathfinder