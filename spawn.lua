local W,M,L,V = unpack(select(2,...))
local _G = _G
local upper = string.upper
local gsub = gsub
local InCombatLockdown = InCombatLockdown

local menu = function(self)
	local unit = self.unit:gsub("(.)", upper, 1)
	if unit == "targettarget" or unit == "focustarget" or unit == "pettarget" then return end
	if _G[unit.."FrameDropDown"] then
		ToggleDropDownMenu(1, nil, _G[unit.."FrameDropDown"], "cursor")
	elseif (self.unit:match("party")) then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor")
	else
		FriendsDropDown.unit = self.unit
		FriendsDropDown.id = self.id
		FriendsDropDown.initialize = RaidFrameDropDown_Initialize
		ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor")
	end
end

local smooth_show = function(self,u)
	local x = self:Spawn(u)
	if x.check_alpha_and_run then
		x:SetAlpha(0)
		x:HookScript("OnHide",function(self) self:SetAlpha(0) end)
	end
	return x
end

local level = function(self)
	self.level_ = CreateFrame("Frame",nil,self)
	self.level_:SetFrameLevel(self:GetFrameLevel()+12)
	self.level_:SetFrameStrata(self:GetFrameStrata())
	self.level_:SetAllPoints(self)
end

local spawn = function(self,unit)
	local var = V[unit]
	self.disallowVehicleSwap = true
	self:RegisterForClicks("AnyDown")
	self:SetSize(var.w,var.h)
	self.menu = menu
	self:SetAttribute("*type2","menu")
	self:SetFrameStrata("LOW")
	self:SetFrameLevel(0)
	level(self)
	W.Portrait(self,unit,var)
	W.Health(self,unit,var)
	W.Power(self,unit,var)
	W.Info(self,unit,var)
	W.Feed(self,var)
	W.SpellRange(self,var)
	W.Experience(self,var)
	W.Reputation(self,var)
	W.Totems(self,var,unit)
	W.Runes(self,var,unit)
	W.Shards(self,var,unit)
	W.ThreatBar(self,var,unit)
	W.Threat(self,var,unit)
	W.Castbar(self,var,unit)
	W.SniperOn(self,unit)
	W.SniperOff(self,unit)
	return self
end

W.oUF:RegisterStyle("Alley",spawn)
W.oUF:Factory(function(self)
	self:SetActiveStyle"Alley"
	self:Spawn"player":SetPoint("BOTTOM", UIParent, "BOTTOM", -338, 153)
	self:Spawn"pet":SetPoint("TOPRIGHT",self.units.player, "TOPLEFT", 2, 12)
	smooth_show(self,"target"):SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 100)
	smooth_show(self,"targettarget"):SetPoint("LEFT",self.units.target, "RIGHT", -2, -6)
	smooth_show(self,"focus"):SetPoint("RIGHT",self.units.target, "LEFT", 2, -6)
	if M.move_focus_target_up then
		smooth_show(self,"focustarget"):SetPoint("BOTTOMRIGHT",self.units.focus,"TOPRIGHT", 0, 17)
	else
		smooth_show(self,"focustarget"):SetPoint("TOPRIGHT",self.units.focus,"BOTTOMRIGHT", 0, -17)
	end
end)
