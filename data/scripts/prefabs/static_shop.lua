local function makeassetlist()
    return {
		Asset("ANIM", "data/anim/shop_basic.zip"),
    }
end

--local ITEMS_DB_RECORDS = {"cokwr","d2mkx","cssly","dtbek","e7d2q","ebks1", "eleqw", "emtbd"}
local function makefn(name, frame, description)
    local function fn(Sim)
		local inst = CreateEntity()
		local trans = inst.entity:AddTransform()
		local anim = inst.entity:AddAnimState()
		local minimap = inst.entity:AddMiniMapEntity()

		minimap:SetPriority( 5 )

		--inst:AddComponent( "discoverable" )
		--inst.components.discoverable:SetIcons( "treasure.png", "shop.png" )
		minimap:SetIcon( "shop.png" )
		minimap:SetPriority( 1 )

		anim:SetBank("shop")
		anim:SetBuild("shop_basic")
		
		anim:PlayAnimation(frame, true)

        inst:AddComponent("inspectable")
        inst.components.inspectable:SetDescription( function() return description end)
        
	    inst:AddComponent("shop")

	    inst.components.shop:SetStartTab("Recipes")
	    inst.components.shop:SetTitle( name .. " Research Station" )

       	return inst
	end
    return fn
end

local function Shop(name, frame, description)
    return Prefab( "common/objects/shop/" .. name .. "_shop", makefn(name, frame, description), makeassetlist())
end

return Shop( "basic", "idle", "This fancy place looks like he is open for business") 

