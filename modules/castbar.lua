local W,M,L,V = unpack(select(2,...))

local fadecast_events = {
	["UNIT_SPELLCAST_START"] = function(self)
		self.fails = nil
		self.isokey = nil
		self.ischanneling = nil
		self:SetAlpha(0)
		if self.anim:IsPlaying() then
			self.anim:Stop()
		end	
	end,
	["UNIT_SPELLCAST_CHANNEL_START"] = function(self)
		self.iscasting = nil
		self.fails = nil
		self.isokey = nil
		self:SetAlpha(0)
		self.dublicate:SetAlpha(0)
		if self.anim:IsPlaying() then
			self.anim:Stop()
		end
	end,
	["UNIT_SPELLCAST_SUCCEEDED"] = function(self)
		self.fails = nil
		self.isokey = true
		self.fails_a = nil
		self.dublicate:SetAlpha(0)
	end,
	["UNIT_SPELLCAST_FAILED"] = function(self) --["UNIT_SPELLCAST_FAILED_QUIET"]
		self.fails = true
		self.isokey = nil
		self.fails_a = nil
		self.dublicate:SetAlpha(0)
	end,
	["UNIT_SPELLCAST_INTERRUPTED"] = function(self)
		self.fails = nil
		self.isokey = nil
		self.fails_a = true
		self.dublicate:SetAlpha(0)
	end,
	["UNIT_SPELLCAST_STOP"] = function(self)
		if self.fails or self.fails_a then
			self:backcolor(1,0,0,.5)
			self:SetBackdropColor(1,0,0)
		elseif self.isokey then
			self:backcolor(0,1,0,.5)
			self:SetBackdropColor(0,1,0)
		end
		self.dublicate:SetAlpha(0)
		if not self.anim:IsPlaying() then
			self.anim:Play()
		end
	end,
	["UNIT_SPELLCAST_CHANNEL_STOP"] = function(self)
		self:SetAlpha(0)
		self.dublicate:SetAlpha(0)
		if self.fails_a then
			self:backcolor(1,0,0,.5)
			self:SetBackdropColor(1,0,0)
			if not self.anim:IsPlaying() then
				self.anim:Play()
			end	
		end
	end,
}

local reg_events = function(self)
	for t,p in pairs(fadecast_events) do
		self[t] = p	
		self:RegisterEvent(t)
	end
	self["UNIT_SPELLCAST_FAILED_QUIET"] = fadecast_events["UNIT_SPELLCAST_FAILED"]
	self:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET")
end

local PlayerCastbarFade = function(self,event,arg1)
	if arg1 ~= self.unit then return end
	self[event](self)
end

local set_fadecast = function(self,unit,dublicate)
	local fade = CreateFrame("Frame",nil,self)
	fade:SetFrameLevel(8)
	fade:SetBackdrop(M.bg)
	fade.backcolor = M.backcolor
	M.style(fade,true)
	fade:SetPoint("TOPLEFT",self.isf)
	fade:SetPoint("BOTTOMRIGHT",self.isf)
	fade:SetAlpha(0)
	reg_events(fade)
	fade.anim = fade:CreateAnimationGroup("Flash")
	fade.anim.fadein = fade.anim:CreateAnimation("ALPHA", "FadeIn")
	fade.anim.fadein:SetChange(1)
	fade.anim.fadein:SetOrder(1)
	fade.anim.fadeout1 = fade.anim:CreateAnimation("ALPHA", "FadeOut")
	fade.anim.fadeout1:SetChange(-.25)
	fade.anim.fadeout1:SetOrder(2)
	fade.anim.fadeout2 = fade.anim:CreateAnimation("ALPHA", "FadeOut")
	fade.anim.fadeout2:SetChange(-.75)
	fade.anim.fadeout2:SetOrder(3)
	fade.anim.fadein:SetDuration(0)
	fade.anim.fadeout1:SetDuration(.8)
	fade.anim.fadeout2:SetDuration(.4)
	fade.unit = unit
	fade:SetScript("OnEvent",PlayerCastbarFade)
	fade.dublicate = dublicate
end

local isf_hook_show = function(self)
	self:GetParent().isf:SetAlpha(0)
	self.dublicate:SetAlpha(0)
end

local isf_hook_hide = function(self)
	self:GetParent().isf:SetAlpha(1)
end

local __SetValue_color = function(self,value)
	self:TehSetValue(value)
	if value == 0 then return end
	if self.maximum == 0 then return end
	local max_modifi = value/self.maximum
	if max_modifi > .1 and self.al__p ~= 1 then
		self.dublicate:SetAlpha(1) 
		self.al__p = 1
	elseif (self.al__p == 1 and max_modifi < .9) or max_modifi == 1 then
		self.dublicate:SetAlpha(0) 
		self.al__p = 0
	end
	self:SetStatusBarColor(1-max_modifi,max_modifi-.2,0)
end

local minmax = function(self,value1,value2)
	self:TehSetMinMaxValues(value1,value2)
	self.maximum = value2
end

local insade_isf_not_pet = function(self,unit,var)
	if unit == "pet" then return end
	if not self.isf then return end
	local cast = CreateFrame("StatusBar", nil, self)
	cast:SetFrameLevel(2)
	if var.iconpos ~= "INSIDE" or var.icon ~= true then
		cast:SetPoint("TOP",self.isf,0,-4)
		cast:SetPoint("BOTTOM",self.isf,0,4)
		cast:SetPoint("LEFT",self.isf,4,0)
		cast:SetPoint("RIGHT",self.isf,-4,0)
		if var.icon then
			local icon = cast:CreateTexture(nil,"OVERLAY")
			icon:SetSize(var.iconsize,var.iconsize*.875)
			icon:SetPoint(var.iconside == "LEFT" and "TOPRIGHT" or "TOPLEFT",cast,"TOP"..var.iconside,var.iconside == "LEFT" and -6 or 6,0)
			cast.Icon = icon
			local bg = M.frame(cast,2,cast:GetFrameStrata(),true)
			bg:points(icon)
			icon:SetGradient("VERTICAL",.5,.5,.5,1,1,1)
			icon:SetTexCoord(3/32,1-3/32,5/32,1-5/32)
			cast.Iconbg = bg
		end
	elseif var.iconpos == "INSIDE" and var.icon then
		local x = floor( var.isf_height / .6 + .5 )
		cast:SetPoint("TOPLEFT",self.isf,var.iconside == "LEFT" and (x+5) or 4,-4)
		cast:SetPoint("BOTTOMRIGHT",self.isf,var.iconside == "RIGHT" and (-x-5) or -4,4)
		local icon = cast:CreateTexture(nil,"OVERLAY")
		icon:SetSize(x,var.isf_height)
		icon:SetPoint(var.iconside == "LEFT" and "RIGHT" or "LEFT",cast,var.iconside,var.iconside == "LEFT" and -1 or 1,0)
		icon:SetGradient("VERTICAL",.5,.5,.5,1,1,1)
		icon:SetTexCoord(.1,.9,.27,.73)
		local border = cast:CreateTexture(nil,"OVERLAY")
		border:SetTexture(0,0,0,1)
		border:SetSize(1,var.isf_height)
		border:SetPoint(var.iconside,cast,var.iconside == "LEFT" and -1 or 1,0)
		cast.Icon = icon
	end
	cast:HookScript("OnShow",isf_hook_show)
	cast:HookScript("OnHide",isf_hook_hide)
	cast:SetStatusBarTexture(M["media"].barv)
	local bg = M.frame(cast,1,cast:GetFrameStrata())
	bg:SetAllPoints(self.isf)
	cast.bg = bg
	local text_offset = var.isf_offset/10 - 2
	local Time = M.setfont(cast,var.isf_height,nil,nil,"RIGHT")
	Time:SetPoint("RIGHT",cast,-2,text_offset)
	cast.Time = Time
	local Text = M.setfont(cast,var.isf_height)
	Text:SetPoint("LEFT",cast,1.5,text_offset)
	Text:SetPoint("RIGHT",cast.Time,"LEFT", -1, 0)
	cast.Text = Text
	local Spark = cast:CreateTexture(nil, "OVERLAY")
	Spark:SetWidth(8)
	Spark:SetBlendMode("ADD")
	Spark:SetAlpha(.7)
	cast.Spark = Spark
	self.Castbar = cast
	if unit == "player" then
		cast.SafeZone = self.Castbar:CreateTexture(nil, "ARTWORK")
		cast.SafeZone:SetAllPoints(self.Castbar)
		cast.SafeZone:SetTexture(M["media"].barv)
		cast.SafeZone:SetVertexColor(.666,0,0,.444)
	end
	local dublicate = CreateFrame("Frame",nil,self.isf)
	dublicate:SetAlpha(0)
	cast.dublicate = dublicate
	dublicate:SetFrameLevel(4)
	local a = dublicate:CreateTexture(nil,"OVERLAY")
	a:SetTexture(0,1,0)
	a:SetPoint("TOPLEFT",self.isf,4,-4)
	a:SetPoint("BOTTOMRIGHT",self.isf,-4,4)
	set_fadecast(self,unit,dublicate)
	cast.maximum = 0
	cast.TehSetValue = cast.SetValue
	cast.SetValue = __SetValue_color
	cast.TehSetMinMaxValues = cast.SetMinMaxValues
	cast.SetMinMaxValues = minmax
	if unit == "target" then
		dublicate:RegisterEvent("PLAYER_TARGET_CHANGED")
		dublicate:SetScript("OnEvent",function(self) self:SetAlpha(0) end)
	end
end

W.Castbar = function(self,var,unit)
	if unit == "targettarget" or unit == "focustarget" then return end
	if not var.castbar then return end
	insade_isf_not_pet(self,unit,var)	
end