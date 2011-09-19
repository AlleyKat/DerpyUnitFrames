local W,M,L,V = unpack(select(2,...))
local unpack = unpack
local FadingFrame_Show = FadingFrame_Show

-- Stupid worgen models, credit by Hydra
local NewSetCameraFunction = function(self,mode)
	local model = self:GetModel()
	if not model then self:___SetCamera(mode) return end
	if not model.find then self:___SetCamera(mode) return end
	if not model:find("worgenmale") then self:___SetCamera(mode) return end
	self:___SetCamera(mode==0 and 1 or 0)
end
local fixworgen = function(self)
	self.___SetCamera = self.SetCamera
	self.SetCamera = NewSetCameraFunction
end

local UnitIsPVPFreeForAll = UnitIsPVPFreeForAll
local UnitIsPVP = UnitIsPVP

local smooth_change = function(self,t)
	if self.cur_r * self.dir_r < self.r * self.dir_r then
		self.cur_r = self.cur_r + self.dir_r * t
	else
		self.cur_r = self.r
	end
	if self.cur_g * self.dir_g < self.g * self.dir_g then
		self.cur_g = self.cur_g + self.dir_g * t
	else
		self.cur_g = self.g
	end
	if self.cur_b * self.dir_b < self.b * self.dir_b then
		self.cur_b = self.cur_b + self.dir_b * t
	else
		self.cur_b = self.b
	end
	if self.cur_r == self.r and self.cur_g == self.g and self.cur_b == self.b then
		self:SetScript("OnUpdate",nil)
		self:SetBackdropColor(self.r,self.g,self.b)
		return
	end
	self:SetBackdropColor(self.cur_r,self.cur_g,self.cur_b)
end

local prepare = function(self,r,g,b,nr,ng,nb)
	local nr,ng,nb = self:GetBackdropColor()
	self.when_color_is_changed:backcolor(r,g,b,.888)
	FadingFrame_Show(self.when_color_is_changed)
	self:SetScript("OnUpdate",nil)
	self.cur_r,self.cur_g,self.cur_b = nr,ng,nb
	self.r,self.g,self.b = r,g,b
	self.dir_r = (nr > r and -1) or 1
	self.dir_g = (ng > g and -1) or 1
	self.dir_b = (nb > b and -1) or 1	
	self:SetScript("OnUpdate",smooth_change)
end

-- Player PvP update
local pvp_update = function(self,unit)
	local r,g,b,mode
	if UnitIsPVPFreeForAll(self.unit or unit) then
		r,g,b,mode = .93,.93,.07,1
	elseif UnitIsPVP(self.unit or unit) then
		r,g,b,mode = .07,.93,.07,2
	else
		r,g,b,mode = .07,.07,.93,3
	end
	if not mode or self.mode == mode then return end
	self.mode = mode
	prepare(self,r,g,b,nr,ng,nb)
end

-- Update
local UnitIsPlayer = UnitIsPlayer
local UnitSelectionColor = UnitSelectionColor
local UnitClass = UnitClass
local color_class = W.oUF.colors.class

local PortraitPostUpdate = function(self,unit)
	local r,g,b
	if not UnitIsPlayer(unit) then 
		r,g,b = UnitSelectionColor(unit)
	else
		r,g,b = unpack(color_class[select(2, UnitClass(unit))])
	end
	if self.abs_r == r and self.abs_g == g and self.abs_b == b then return end
	self.abs_r = r 
	self.abs_g = g
	self.abs_b = b
	prepare(self,r,g,b)
end

local port_enter = function(self) 
	local port = self.Portrait
	port.mask.tex:SetGradientAlpha("VERTICAL",port.r,port.g,port.b,0,port.r,port.g,port.b,.4);
	UnitFrame_OnEnter(self)
end
local port_leave = function(self) self.Portrait.mask.tex:SetGradientAlpha("VERTICAL",0,0,0,0,0,0,0,.7); UnitFrame_OnLeave(self) end

local pvpflag = function(self,unit)
	if unit ~= "player" and unit ~= "pet" then return end
	self.unit = unit
	self:RegisterEvent("UNIT_FACTION")
	self:SetScript("OnEvent",pvp_update)
end

-- Create Portrait
W.Portrait = function(self,unit,var)
	local portrait = CreateFrame("PlayerModel",nil,self)

	portrait:SetPoint("TOPLEFT",4,-4)
	portrait:SetPoint("BOTTOMRIGHT",-4,4)
	portrait:SetFrameLevel(4)
	M.style(self,true)
	self:SetBackdrop(M.bg_edge)
	self:SetBackdropBorderColor(unpack(M["media"].shadow))
	if unit == "player" or unit == "pet" then 
		portrait.PostUpdate = pvp_update
	else
		portrait.PostUpdate = PortraitPostUpdate
	end
	if unit ~= "pet" then fixworgen(portrait) end
	portrait.r,portrait.b,portrait.g = 0,0,0	
	
	local scale = UIParent:GetScale()
	portrait:SetBackdrop({bgFile = M["media"].walltex, tile = true, 
		tileSize = max(80*scale,(var.h-8)*scale)
	})
		
	local mask = CreateFrame("Frame",nil,portrait)
	mask:SetFrameLevel(8)
	mask:SetPoint("TOPLEFT")
	mask:SetPoint("BOTTOMRIGHT")
	
	local when_color_is_changed = CreateFrame("Frame",nil,portrait)
	when_color_is_changed:SetAllPoints(self)
	when_color_is_changed:Hide()
	when_color_is_changed:SetBackdrop(M.bg_edge)
	when_color_is_changed.backcolor = M.backcolor
	when_color_is_changed:SetScript("OnUpdate", FadingFrame_OnUpdate)
	when_color_is_changed.fadeInTime = .2
	when_color_is_changed.fadeOutTime = .3
	when_color_is_changed.holdTime = .3
	M.style(when_color_is_changed,true)
	portrait.when_color_is_changed = when_color_is_changed
	
	
	local tex = mask:CreateTexture(nil,"Border")
	tex:SetAllPoints()
	tex:SetTexture(M['media'].blank)
	tex:SetGradientAlpha("VERTICAL",0,0,0,0,0,0,0,.7)
	tex:SetBlendMode("BLEND")

	portrait.mask = mask
	mask.tex = tex
	
	pvpflag(portrait,unit)
	
	self.Portrait = portrait
	self:SetScript('OnEnter',port_enter)
	self:SetScript('OnLeave',port_leave)
end
