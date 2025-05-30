-- data.lua

-- data file containing nodes and edges for graph representation


local nodes = {
	[1] = {id = 1, x = 437.48, y = 239.61},
	[2] = {id = 2, x = 442.07, y = 340.61},
	[3] = {id = 3, x = 347.12, y = 338.37},
	[4] = {id = 4, x = 349.00, y = 247.96},
	[5] = {id = 5, x = 317.52, y = 221.93},
	[6] = {id = 6, x = 325.55, y = 361.68},
	[7] = {id = 7, x = 313.15, y = 363.66},
	[8] = {id = 8, x = 251.12, y = 329.34},
	[9] = {id = 9, x = 257.21, y = 249.30},
	[10] = {id = 10, x = 532.81, y = 283.50},
	[11] = {id = 11, x = 502.55, y = 344.89},
	[12] = {id = 12, x = 454.33, y = 353.00},
--	[13] = {id = 13, x = 438.45, y = 238.69},
	[14] = {id = 14, x = 501.02, y = 241.70},
	[15] = {id = 15, x = 437.03, y = 165.87},
	[16] = {id = 16, x = 300, y = 160},
	[17] = {id = 17, x = 376.91, y = 127.74},
	[18] = {id = 18, x = 350, y = 410},
	[19] = {id = 19, x = 440.98, y = 433.14},
	[20] = {id = 20, x = 400, y = 450},
	[21] = {id = 21, x = 270.13, y = 145.03},
	[22] = {id = 22, x = 212.74, y = 230.36},
	[23] = {id = 23, x = 195.16, y = 156.87},
	[24] = {id = 24, x = 226.88, y = 338.94},
	[25] = {id = 25, x = 271.01, y = 434.52},
	[26] = {id = 26, x = 219.36, y = 435.64},
	[27] = {id = 27, x = 198.98, y = 403.73},
	[28] = {id = 28, x = 306.32, y = 487.47},
	[29] = {id = 29, x = 546.54, y = 377.28},
	[30] = {id = 30, x = 541.38, y = 431.47},
	[31] = {id = 31, x = 481.32, y = 453.71},
	[32] = {id = 32, x = 583.28, y = 283.50},
	[33] = {id = 33, x = 616.49, y = 343.28},
	[34] = {id = 34, x = 614.09, y = 351.11},
	[35] = {id = 35, x = 487.31, y = 133.82},
	[36] = {id = 36, x = 547.67, y = 160},
--	[37] = {id = 37, x = 547.69, y = 180.09},
	[37] = {id = 37, x = 547.69, y = 200},
	[38] = {id = 38, x = 365.09, y = 50.00},
	[39] = {id = 39, x = 497.07, y = 50.00},
	[40] = {id = 40, x = 544.69, y = 50.00},
	[41] = {id = 41, x = 586.42, y = 127.50},
	[42] = {id = 42, x = 600, y = 227.99},
	[43] = {id = 43, x = 400, y = 500.00},
	[44] = {id = 44, x = 300, y = 560.00},
	[45] = {id = 45, x = 239.10, y = 550.00},
	[46] = {id = 46, x = 201.20, y = 475.23},
	[47] = {id = 47, x = 151.28, y = 304.39},
	[48] = {id = 48, x = 149.18, y = 269.79},
	[49] = {id = 49, x = 291.97, y = 50.00},
	[50] = {id = 50, x = 654.93, y = 166.15},
	[51] = {id = 51, x = 625.61, y = 224.79},
	[52] = {id = 52, x = 627.65, y = 127.50},
	[53] = {id = 53, x = 682.15, y = 311.25},
	[54] = {id = 54, x = 683.78, y = 260.00},
	[55] = {id = 55, x = 571.50, y = 550.00},
	[56] = {id = 56, x = 505.98, y = 550.00},
	[57] = {id = 57, x = 591.96, y = 468.88},
	[58] = {id = 58, x = 750.00, y = 357.63},
	[59] = {id = 59, x = 750.00, y = 368.66},
	[60] = {id = 60, x = 650.36, y = 427.02},
	[61] = {id = 61, x = 750.00, y = 157.30},
	[62] = {id = 62, x = 750.00, y = 219.77},
	[63] = {id = 63, x = 191.74, y = 50.00},
	[64] = {id = 64, x = 176.23, y = 141.41},
	[65] = {id = 65, x = 101.40, y = 233.12},
	[66] = {id = 66, x = 151.90, y = 148.07},
	[67] = {id = 67, x = 154.25, y = 397.87},
	[68] = {id = 68, x = 123.61, y = 340.85},
	[69] = {id = 69, x = 144.73, y = 484.15},
	[70] = {id = 70, x = 116.78, y = 441.59},
	[71] = {id = 71, x = 118.06, y = 550.00},
	[72] = {id = 72, x = 750.00, y = 475.01},
	[73] = {id = 73, x = 670.50, y = 463.49},
	[74] = {id = 74, x = 647.84, y = 439.27},
	[75] = {id = 75, x = 675.59, y = 550.00},
	[76] = {id = 76, x = 50.00, y = 433.60},
	[77] = {id = 77, x = 50.00, y = 352.74},
	[78] = {id = 78, x = 50.00, y = 232.29},
	[79] = {id = 79, x = 50.00, y = 100},
--	[80] = {id = 80, x = 50.00, y = 50.00},
--	[81] = {id = 81, x = 50.00, y = 550.00},
	[82] = {id = 82, x = 667.54, y = 50.00},
--	[83] = {id = 83, x = 750.00, y = 50.00},
--	[84] = {id = 84, x = 750.00, y = 550.00},
}

local edges = {
	[1] = {id = 1, nodes = {1, 2}},
	[2] = {id = 2, nodes = {2, 3}},
	[3] = {id = 3, nodes = {3, 4}},
	[4] = {id = 4, nodes = {4, 1}},
	[5] = {id = 5, nodes = {5, 4}},
	[6] = {id = 6, nodes = {3, 6}},
	[7] = {id = 7, nodes = {6, 7}},
	[8] = {id = 8, nodes = {7, 8}},
	[9] = {id = 9, nodes = {8, 9}},
	[10] = {id = 10, nodes = {9, 5}},
	[11] = {id = 11, nodes = {10, 11}},
	[12] = {id = 12, nodes = {11, 12}},
	[13] = {id = 13, nodes = {12, 2}},
--	[14] = {id = 14, nodes = {1, 13}},
--	[15] = {id = 15, nodes = {13, 14}},
	[15] = {id = 15, nodes = {1, 14}},
	[16] = {id = 16, nodes = {14, 10}},
--	[17] = {id = 17, nodes = {15, 13}},
	[17] = {id = 17, nodes = {15, 1}},
	[18] = {id = 18, nodes = {5, 16}},
	[19] = {id = 19, nodes = {16, 17}},
	[20] = {id = 20, nodes = {17, 15}},
	[21] = {id = 21, nodes = {18, 6}},
	[22] = {id = 22, nodes = {12, 19}},
--	[23] = {id = 23, nodes = {19, 20}},
	[24] = {id = 24, nodes = {18, 20, 19}},
	[25] = {id = 25, nodes = {21, 16}},
--	[26] = {id = 26, nodes = {9, 22}},
	[27] = {id = 27, nodes = {22, 23}},
	[28] = {id = 28, nodes = {23, 21}},
	[29] = {id = 29, nodes = {24, 8}},
	[30] = {id = 30, nodes = {7, 25}},
	[31] = {id = 31, nodes = {25, 26}},
	[32] = {id = 32, nodes = {26, 27}},
	[33] = {id = 33, nodes = {27, 24}},
	[34] = {id = 34, nodes = {18, 28}},
	[35] = {id = 35, nodes = {28, 25}},
	[36] = {id = 36, nodes = {11, 29}},
	[37] = {id = 37, nodes = {29, 30}},
	[38] = {id = 38, nodes = {30, 31}},
	[39] = {id = 39, nodes = {31, 19}},
	[40] = {id = 40, nodes = {10, 32}},
	[41] = {id = 41, nodes = {32, 33}},
	[42] = {id = 42, nodes = {33, 34}},
	[43] = {id = 43, nodes = {34, 29}},
	[44] = {id = 44, nodes = {15, 35}},
	[45] = {id = 45, nodes = {35, 36}},
	[46] = {id = 46, nodes = {36, 37}},
	[47] = {id = 47, nodes = {37, 14}},
	[48] = {id = 48, nodes = {38, 39}},
	[49] = {id = 49, nodes = {39, 35}},
	[50] = {id = 50, nodes = {17, 38}},
	[51] = {id = 51, nodes = {39, 40}},
	[52] = {id = 52, nodes = {40, 41}},
	[53] = {id = 53, nodes = {41, 36}},
	[54] = {id = 54, nodes = {37, 42}},
	[55] = {id = 55, nodes = {42, 32}},
	[56] = {id = 56, nodes = {44, 43, 56}},
	[57] = {id = 57, nodes = {44, 28}},
--	[58] = {id = 58, nodes = {20, 43}},
	[59] = {id = 59, nodes = {44, 45}},
	[60] = {id = 60, nodes = {45, 46}},
	[61] = {id = 61, nodes = {46, 26}},
	[62] = {id = 62, nodes = {24, 47}},
	[63] = {id = 63, nodes = {47, 48}},
	[64] = {id = 64, nodes = {48, 22}},
	[65] = {id = 65, nodes = {49, 38}},
	[66] = {id = 66, nodes = {21, 49}},
	[67] = {id = 67, nodes = {50, 51}},
	[68] = {id = 68, nodes = {51, 42}},
	[69] = {id = 69, nodes = {41, 52}},
	[70] = {id = 70, nodes = {52, 50}},
	[71] = {id = 71, nodes = {53, 33}},
	[72] = {id = 72, nodes = {51, 54}},
	[73] = {id = 73, nodes = {54, 53}},
	[74] = {id = 74, nodes = {55, 56}},
	[75] = {id = 75, nodes = {56, 31}},
	[76] = {id = 76, nodes = {30, 57}},
	[77] = {id = 77, nodes = {57, 55}},
	[78] = {id = 78, nodes = {58, 59}},
	[79] = {id = 79, nodes = {59, 60}},
	[80] = {id = 80, nodes = {60, 34}},
	[81] = {id = 81, nodes = {53, 58}},
	[82] = {id = 82, nodes = {61, 62}},
	[83] = {id = 83, nodes = {62, 54}},
	[84] = {id = 84, nodes = {50, 61}},
	[85] = {id = 85, nodes = {63, 49}},
	[86] = {id = 86, nodes = {23, 64}},
	[87] = {id = 87, nodes = {64, 63}},
	[88] = {id = 88, nodes = {48, 65}},
	[89] = {id = 89, nodes = {65, 66}},
	[90] = {id = 90, nodes = {66, 64}},
	[91] = {id = 91, nodes = {27, 67}},
	[92] = {id = 92, nodes = {67, 68}},
	[93] = {id = 93, nodes = {68, 47}},
	[94] = {id = 94, nodes = {46, 69}},
	[95] = {id = 95, nodes = {69, 70}},
	[96] = {id = 96, nodes = {70, 67}},
	[97] = {id = 97, nodes = {45, 71}},
	[98] = {id = 98, nodes = {71, 69}},
	[99] = {id = 99, nodes = {59, 72}},
	[100] = {id = 100, nodes = {72, 73}},
	[101] = {id = 101, nodes = {73, 74}},
	[102] = {id = 102, nodes = {74, 60}},
	[103] = {id = 103, nodes = {74, 57}},
	[104] = {id = 104, nodes = {75, 55}},
	[105] = {id = 105, nodes = {73, 75}},
--	[106] = {id = 106, nodes = {76, 77}},
	[107] = {id = 107, nodes = {77, 68}},
	[108] = {id = 108, nodes = {70, 76}},
--	[109] = {id = 109, nodes = {77, 78}},
	[110] = {id = 110, nodes = {78, 65}},
--	[111] = {id = 111, nodes = {78, 79}},
	[112] = {id = 112, nodes = {79, 66}},
--	[113] = {id = 113, nodes = {80, 63}},
--	[114] = {id = 114, nodes = {79, 80}},
--	[115] = {id = 115, nodes = {71, 81}},
--	[116] = {id = 116, nodes = {81, 76}},
	[117] = {id = 117, nodes = {40, 82}},
	[118] = {id = 118, nodes = {82, 52}},
--	[119] = {id = 119, nodes = {82, 83}},
--	[120] = {id = 120, nodes = {83, 61}},
	[121] = {id = 121, nodes = {62, 58}},
--	[122] = {id = 122, nodes = {72, 84}},
--	[123] = {id = 123, nodes = {84, 75}},
--	[124] = {id = 124, nodes = {56, 43}},
}


--[[ 
-- data.lua rest:

-- round the x and y coordinates of each node to the nearest integer
for i, node in pairs(nodes) do
	node.x = math.floor(node.x + 0.5)
	node.y = math.floor(node.y + 0.5)

	node.neighbors = {}
end

-- function to calculate the length of an edge
local function calculateEdgeLength(node1, node2)
	return math.sqrt((node1.x - node2.x)^2 + (node1.y - node2.y)^2)
end

local function newNeighbor (nodeId, length, edgeId)
	return {id = nodeId, length = length, edgeId = edgeId}
end

-- add length to each edge
for _, edge in pairs(edges) do
	local totalLength = 0
	edge.segments = {} -- store segments of the polyline edge

	local firstNode = nodes[edge.nodes[1] ]  -- get the first node of the edge
	edge.line = {firstNode.x, firstNode.y} -- initialize the line with the first node's coordinates

	-- iterate through all node pairs in the edge to calculate its length and build the line
	for i = 1, #edge.nodes-1 do
		local node1Id = edge.nodes[i]
		local node2Id = edge.nodes[i + 1]
		local node1 = nodes[node1Id]
		local node2 = nodes[node2Id]
		local segmentLength = calculateEdgeLength(node1, node2)

		table.insert(edge.segments, {
				from = node1Id,
				to = node2Id,
				length = segmentLength
			})
		
		totalLength = totalLength + segmentLength

		table.insert (edge.line, node2.x)
		table.insert (edge.line, node2.y)

		table.insert(nodes[node1Id].neighbors, newNeighbor (node2Id, segmentLength, edge.id))
		table.insert(nodes[node2Id].neighbors, newNeighbor (node1Id, segmentLength, edge.id))
	end

	edge.length = totalLength
	edge.dynamicCost = 0

	edge.x = (nodes[edge.nodes[1] ].x + (nodes[edge.nodes[2] ].x))/2
	edge.y = (nodes[edge.nodes[1] ].y + (nodes[edge.nodes[2] ].y))/2
end



--for _, edge in pairs(edges) do
--	local node1Id = edge.nodes[1]
--	local node2Id = edge.nodes[#edge.nodes]
--	local length = edge.length
--	table.insert(nodes[node1Id].neighbors, newNeighbor (node2Id, length, edge.id))
--	table.insert(nodes[node2Id].neighbors, newNeighbor (node1Id, length, edge.id))

--end

--]]

return { -- require doesn't return multiple values
	nodes = nodes, 
	edges = edges,
}