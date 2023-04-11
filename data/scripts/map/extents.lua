
function UpdateextentsForNode(extents, node)
	if node.data.position.x-node.data.size/2<extents.xmin then
		extents.xmin = node.data.position.x-node.data.size/2
	end
	if node.data.position.y-node.data.size/2<extents.ymin then
		extents.ymin = node.data.position.y-node.data.size/2
	end
	if node.data.position.x+node.data.size/2>extents.xmax then
		extents.xmax = node.data.position.x+node.data.size/2
	end
	if node.data.position.y+node.data.size/2>extents.ymax then
		extents.ymax = node.data.position.y+node.data.size/2
	end
end

function ResetextentsForNodes(nodes)
	local extents = {xmin=1000000,ymin=1000000,xmax=-1000000,ymax=-1000000}	
	for k,node in pairs(nodes) do
		Updateextents(extents, node)
	end
	
	return extents
end

-- radius, cx, cy = GetMinimumRadiusForNodes(sim, nodes)
function GetMinimumRadiusForNodes(nodes)
	local floats = {}
	for k,node in pairs(nodes) do
		table.insert(floats, node.data.position.x)
		table.insert(floats, node.data.position.y)
		
		local radius = node.data.size
		
		-- plus radius
		table.insert(floats, node.data.position.x+radius)
		table.insert(floats, node.data.position.y)
		table.insert(floats, node.data.position.x-radius)
		table.insert(floats, node.data.position.y)
		
		table.insert(floats, node.data.position.x)
		table.insert(floats, node.data.position.y+radius)
		table.insert(floats, node.data.position.x)
		table.insert(floats, node.data.position.y-radius)
		
	end

	return getminimumradius(floats) --sim:GetMinimumRadius(floats)
end
