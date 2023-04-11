require "widget"

MapWidget = Class(Widget, function(self, owner)
    Widget._ctor(self, "MapWidget")
	self.owner = owner

    self.bg = self:AddChild(Image("data/images/hud.xml", "map.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.bg.inst.ImageWidget:SetBlendMode( BLENDMODE.Premultiplied )
    
    self.minimap = self.owner.HUD.minimap.MiniMap
    
    self.img = self:AddChild(Image())
    self.img:SetHAnchor(ANCHOR_MIDDLE)
    self.img:SetVAnchor(ANCHOR_MIDDLE)
    self.img.inst.ImageWidget:SetBlendMode( BLENDMODE.Additive )    

    self.inputhandlers = {}
    table.insert(self.inputhandlers, TheInput:AddMouseButtonHandler(MOUSEBUTTON_SCROLLUP, true, function() self:OnScrollUp() end))
    table.insert(self.inputhandlers, TheInput:AddMouseButtonHandler(MOUSEBUTTON_SCROLLDOWN, true, function() self:OnScrollDown() end))
    table.insert(self.inputhandlers, TheInput:AddMouseMoveHandler(function(x, y) self:OnMouseMove(x, y) end))
    
	self.lastpos = nil
end)


function MapWidget:OnRemoveEntity()
    for k,v in pairs(self.inputhandlers) do
        v:Remove()
    end
end


function MapWidget:SetTextureHandle(handle)
	self.img.inst.ImageWidget:SetTextureHandle( handle )
end

function MapWidget:OnScrollUp( )
	if self.shown then
		self.minimap:Zoom( -1 )
	end
end

function MapWidget:OnScrollDown( )
	if self.shown then
		self.minimap:Zoom( 1 )
	end
end

function MapWidget:Update()
	local handle = self.minimap:GetTextureHandle()
	self:SetTextureHandle( handle )
end

function MapWidget:OnMouseDown( data )
	if self.shown then
		self.lastpos = data
	end
end


function MapWidget:OnMouseMove( x, y )
	if self.shown and self.lastpos then
		if TheInput:IsMouseDown(MOUSEBUTTON_LEFT) then
			local scale = 0.5
			if self.lastpos then
				local dx = scale * ( x - self.lastpos.x )
				local dy = scale * ( y - self.lastpos.y )
				self.minimap:Offset( dx, dy )
			end
		end
		self.lastpos = {x=x, y=y}
	end
end

function MapWidget:OnShow()
	self.minimap:ResetOffset()
end

function MapWidget:OnHide()
	self.lastpos = nil
end
