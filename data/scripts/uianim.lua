require "widget"

UIAnim = Class(Widget, function(self)
    Widget._ctor(self, "UIAnim")
    self.inst.entity:AddAnimState()
end)

function UIAnim:GetAnimState()
    return self.inst.AnimState
end
