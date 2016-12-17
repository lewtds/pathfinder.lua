local pf = require 'pathfinder'

local map = {}

function read_map()
	local f = assert(io.open("benchmarks/Aftershock.map", "r"))
	local count = 1
	while count < 517 do
		local line = f:read()
		if count > 4 then
			table.insert(map, line)
		end
		count = count + 1
	end
	f:close()
end

local map_width = 512
local map_height = 512
local map_cell_count = map_width * map_height


function map_feature(x, y)
	return string.sub(map[y], x, x)
end

function is_walkable_tile(feature)
	return feature == "." or feature == "G" or feature == "S"
end


function xytoindex(x, y)
	return (y - 1) * map_width + x
end

function indextoxy(index)
	return (index - 1) % map_width + 1, math.floor((index - 1) / map_width) + 1
end


function map_neighbors(index)
	local x, y = indextoxy(index)
	local neighbors = {}

	for i=-1,1 do
		for j=-1,1 do
			local newx, newy = x + i, y + j
			if i ~= j and is_legal_xy(newx, newy) and is_walkable_tile(map_feature(newx, newy)) then
				table.insert(neighbors, xytoindex(newx, newy))
			end
		end
	end
	

	return neighbors
end


function is_legal_xy(x, y)
	return x > 0 and y > 0 and x <= map_width and y <= map_height
end

read_map()


function distance_squared(node1, node2)
	local x1, y1 = indextoxy(node1)
	local x2, y2 = indextoxy(node2)
	local dx = x2 - x1
	local dy = y2 - y1
	return dx * dx + dy * dy
end


function parse_test_line(line)
	local test = {}

	local iter = string.gmatch(line, "%S+")
	test.bucket = iter()
	test.map = iter()
	test.map_width = iter()
	test.map_height = iter()
	test.start_x = iter()
	test.start_y = iter()
	test.dest_x = iter()
	test.dest_y = iter()
	test.optimal_len = iter()

	return test
end

local total_time = 0

local f = assert(io.open("benchmarks/Aftershock.map.scen", "r"))
f:read()
local count = 1
while count < 200 do
	local test_line = f:read()
	local test = parse_test_line(test_line)

	local start_time = os:clock()
	local path = pf.shortest_path{
		start = xytoindex(test.start_x + 1, test.start_y + 1),
		dest = xytoindex(test.dest_x + 1, test.dest_y + 1),
		neighbors = map_neighbors,
		heuristic = distance_squared,
	}

	total_time = total_time + os:clock() - start_time

	local deviation = #path - test.optimal_len
	print(string.format("test: #%s\tlength: %i\toptimal: %i\tdeviation: %f", count, #path, test.optimal_len, deviation))

	count = count + 1
end

print(("ran %s tests in %s, avg: %g ms/test"):format(count, total_time, total_time / count * 1000))