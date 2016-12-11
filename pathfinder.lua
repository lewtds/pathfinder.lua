local function table_get_default(table, key, default)
  return table[key] or default
end


-- FIXME: very naive and sloooow implementation lol
local PriorityQueue = {}

function PriorityQueue.new(compare_nodes)
  return {
    compare_nodes = compare_nodes
  }
end

function PriorityQueue.add(queue, node)
  table.insert(queue, node)
  table.sort(queue, queue.compare_nodes)
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
  local fscore = {[start] = 0}
  local gscore = {[start] = 0}

  local to_search = PriorityQueue.new(function (n1, n2)
    return table_get_default(fscore, n1, math.huge) > table_get_default(fscore, n2, math.huge)
  end)

  local prev = nil
  local current = start
  while current and current ~= dest do
    for i,node in ipairs(neighbors(current)) do
      if not come_from[node] then
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

    prev = current
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