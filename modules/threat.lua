--oUF_threat by Wurmfood
local ns,M,L,V = unpack(select(2,...))
local W = ns
local oUF = ns.oUF or oUF
local unpack = unpack
local InCombatLockdown = InCombatLockdown
local UnitIsPlayer = UnitIsPlayer

local aggroColors = {
	[1] = {0, 1, 0},
	[2] = {1, 1, 0},
	[3] = {1, 0, 0},
}

local updateth = function(self)
	if InCombatLockdown() then
		local _, _, threatpct = UnitDetailedThreatSituation(self.unit, self.tar)
		
		threatval = threatpct or 0
		
		self:SetValue(threatval)
		self.Text:SetFormattedText("%3.1f", threatval)
		
		if( threatval < 30 ) then
			self:SetStatusBarColor(unpack(self.Colors[1]))
		elseif( threatval >= 30 and threatval < 70 ) then
			self:SetStatusBarColor(unpack(self.Colors[2]))
		else
			self:SetStatusBarColor(unpack(self.Colors[3]))
		end
	end
end


local function update(self,t)
	self.n = self.n - t
	if self.n > 0 then return end
	self.n = .2
	self:updateth()
end

local show_if_npc = function(self)
	if not UnitIsPlayer("target") then
		self:Show()
	else
		self:Hide()
	end
end

local _on_event = function(self,event)
	if event == "PLAYER_REGEN_ENABLED" then
		self:Hide()
	elseif event == "PLAYER_REGEN_DISABLED" then
		self:show_if_npc()
	else
		if InCombatLockdown() then
			self:show_if_npc()
		else
			self:Hide()
		end
	end
end

local function enable(self)
	local bar = self.W_ThreatBar
	if( bar ) then
		bar:Hide()
		bar:SetMinMaxValues(0, 100)
		bar:SetValue(0)
		bar:RegisterEvent("PLAYER_REGEN_ENABLED")
		bar:RegisterEvent("PLAYER_REGEN_DISABLED")
		bar:RegisterEvent("PLAYER_TARGET_CHANGED")
		
		bar:SetScript("OnEvent",_on_event)
		bar:SetScript("OnUpdate",update)
		bar:SetScript("OnShow",function(self) self:updateth() end)
		bar:SetScript("OnHide",function(self) self:SetValue(0) end)
		
		bar.Colors = aggroColors
		bar.unit = "player"
		bar.show_if_npc = show_if_npc
		bar.n = 0
		bar.updateth = updateth
		bar.Smooth = true
		bar.tar = "playertarget"

		return true
	end
end

local function disable(self)
	local bar = self.W_ThreatBar
	if( bar ) then
		bar:UnregisterEvent("PLAYER_REGEN_ENABLED")
		bar:UnregisterEvent("PLAYER_REGEN_DISABLED")
		bar:UnregisterEvent("PLAYER_TARGET_CHANGED")
		
		bar:Hide()
		bar:SetScript("OnEvent", nil)
		bar:SetScript("OnUpdate",nil)
		bar:SetScript("OnShow",nil)
		bar:SetScript("OnHide",nil)
	end
end

oUF:AddElement("W_ThreatBar", function() return end, enable, disable)

local backcolor1 = function(self,r,g,b,ag)
	self:SetBackdropBorderColor(r,g,b,ag or 1)
	if ag then r,g,b = 0,0,0 end
	self.top:SetTexture(r,g,b)
	self.bottom:SetTexture(r,g,b)
	self.left:SetTexture(r,g,b)
	self.right:SetTexture(r,g,b)
end

local function UpdateThreat(self, event, unit)
	if (self.unit ~= unit) then return end
	local threat = UnitThreatSituation(self.unit)
	if (threat == 3) then
		self:backcolor1(1,0,0)
	elseif (threat == 2) then
		self:backcolor1(1,1,0)
	elseif (threat == 1) then
		self:backcolor1(0,1,0)
	else
		self:backcolor1(unpack(M["media"].shadow))
	end 
end

W.Threat = function(self,var,unit)
	if unit == "focustarget" or unit == "targettarget" then return end
	self.backcolor1 = backcolor1
	tinsert(self.__elements, UpdateThreat)
	self:RegisterEvent('PLAYER_TARGET_CHANGED', UpdateThreat)
	self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', UpdateThreat)
	self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', UpdateThreat)
end

W.ThreatBar = function(self,var,unit)
	if unit ~= "target" then return end
	local trtr = CreateFrame("StatusBar",self:GetName()..'_ThreatBar',self)
	trtr:SetStatusBarTexture(M["media"].barv)
	trtr:SetBackdrop({bgFile = M["media"].blank})
	trtr:SetBackdropColor(unpack(M["media"].color))
	M.style(trtr,nil,-1)
	trtr.Text = M.setfont(trtr,13)
	trtr:SetFrameLevel(10)
	trtr.Text:SetPoint("TOPLEFT",self.level_,5,-3)
	trtr:SetAllPoints(self.Power)
	self.W_ThreatBar = trtr
	return trtr
end
