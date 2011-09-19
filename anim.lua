local W,M,L,V = unpack(select(2,...))

W.SetAnim = function(self,duration,a,b)
	self.anim = self:CreateAnimationGroup("Flash")
	self.anim.fadein = self.anim:CreateAnimation("ALPHA", "FadeIn")
	self.anim.fadein:SetChange(1)
	self.anim.fadein:SetOrder(b)
	self.anim.fadeout = self.anim:CreateAnimation("ALPHA", "FadeOut")
	self.anim.fadeout:SetChange(-1)
	self.anim.fadeout:SetOrder(a)
	self.anim.fadein:SetDuration(duration)
	self.anim.fadeout:SetDuration(duration)
	self.anim:SetLooping("REPEAT")
end

local UIFrameFadeIn = UIFrameFadeIn
local UIFrameFadeOut = UIFrameFadeOut

local __new_value = function(self,value)
	self:___SetValue(value)
	if value ~=0 then
		if not self.full then
			self.full = true
			UIFrameFadeIn(self.mask,.2,self.mask:GetAlpha(),1)
		end
	else
		if self.full then
			self.full = false
			UIFrameFadeOut(self.mask,.2,self.mask:GetAlpha(),0)
		end
	end
end

local __new_settexturecolor = function(self,r,g,b)
	self:___SetTextureColor(r,g,b)
	self.mask:backcolor(r,g,b,.888)
end

W.make_mask = function(self,num,anum)
	local mask = CreateFrame("Frame",nil,self)
	mask:SetAllPoints(self.glow)
	mask:SetFrameLevel(self.glow:GetFrameLevel()+1)
	mask:SetBackdrop(M.bg_edge)
	mask.backcolor = M.backcolor
	M.style(mask,true)
	self.___SetValue = self.SetValue
	self.SetValue = __new_value
	self.___SetTextureColor = self.SetStatusBarColor
	self.SetStatusBarColor = __new_settexturecolor
	self.mask = mask
	mask:SetAlpha(0)
end