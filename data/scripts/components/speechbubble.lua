local SpeechBubble = Class(function(self, inst)
	self.inst = inst
    self.inst.entity:AddUIRender()
end)

function SpeechBubble:SetImage(bg_filename, image_filename)
	self.bg = bg_filename
	self.img = image_filename
end

function SpeechBubble:Show()
    local render = self.inst.UIRender

	render:SetImageNode("bg", self.bg, true)
    render:SetImageNode("speechimg", self.img, true)

	render:SetNodePos("bg", 0, 0, 0)
    render:SetNodePos("speechimg", 0, 0, 0)

	render:SetImageOffset("bg", 128, 128, 0)
	render:SetImageOffset("speechimg", 128, 128, 0)
end

function SpeechBubble:Hide()
    local render = self.inst.UIRender
	render:KillNode( "bg" )
	render:KillNode( "speechimg" )
end

return SpeechBubble
