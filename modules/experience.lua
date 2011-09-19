local W,M,L,V = unpack(select(2,...))

if UnitLevel("player") == MAX_PLAYER_LEVEL or V.player.exp ~= true then W.Experience = M.null return end

W.Experience = function(self,var)
	if var.exp ~= true then return end

	local XP = CreateFrame('StatusBar', nil, self)
		XP:SetPoint('TOPLEFT',self.isf,4,-4)
		XP:SetPoint('BOTTOMRIGHT',self.isf,-4,4)
		XP:SetStatusBarTexture(M['media'].barv)
		XP:SetStatusBarColor(.07,.5,.07)
		XP:SetFrameStrata(self:GetFrameStrata())
		XP:SetFrameLevel(self.isf:GetFrameLevel()+2)
	local Rested = CreateFrame('StatusBar', nil, XP)
		Rested:SetAllPoints(XP)
		Rested:SetStatusBarTexture(M['media'].barv)
		Rested:SetStatusBarColor(.07,.07,.5,1)
		XP.Rested = Rested
	local Text = M.setfont(XP,var.isf_height)
		Text:SetPoint('CENTER',XP,1.3,.3)
		self:Tag(Text,'[curxp] / [maxxp] - [perxp] %')
		M.style(XP.Rested,nil,-1)
		XP.Rested:SetBackdrop({bgFile = M['media'].barv})
		XP.Rested:SetBackdropColor(unpack(M['media'].color))
		XP:SetScript('OnEnter', function(self) UIFrameFadeIn(self,.1,0,1) end)
		XP:SetScript('OnLeave', function(self) UIFrameFadeOut(self,.2,1,0) end)
		XP:SetAlpha(0)
		
	self.Experience = XP
end

local floor = floor
local oUF = W.oUF
local UnitXP = UnitXP
local UnitXPMax = UnitXPMax
local GetXPExhaustion = GetXPExhaustion

for tag, func in pairs({
	['curxp'] = function(unit)
		return UnitXP(unit)
	end,
	['maxxp'] = function(unit)
		return UnitXPMax(unit)
	end,
	['perxp'] = function(unit)
		return floor(UnitXP(unit) / UnitXPMax(unit) * 100 + 0.5)
	end,
}) do
	oUF.Tags[tag] = func
	oUF.TagEvents[tag] = 'PLAYER_XP_UPDATE PLAYER_LEVEL_UP'
end

local function Unbeneficial(self, unit)
	if(UnitLevel(unit) == MAX_PLAYER_LEVEL) then return true end
end

local function Update(self, event, unit)
	if(self.unit ~= unit) then return end

	local experience = self.Experience
	if(experience.PreUpdate) then experience:PreUpdate(unit) end

	if(Unbeneficial(self, unit)) then
		return experience:Hide()
	else
		experience:Show()
	end

	local min, max = UnitXP(unit), UnitXPMax(unit)

	experience:SetMinMaxValues(0, max)
	experience:SetValue(min)

	local exhaustion = GetXPExhaustion() or 0
	experience.Rested:SetMinMaxValues(0, max)
	experience.Rested:SetValue(math.min(min + exhaustion, max))

	if(experience.PostUpdate) then
		return experience:PostUpdate(unit, min, max)
	end
end

local function Path(self, ...)
	return (self.Experience.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local experience = self.Experience
	if(experience) then
		experience.__owner = self
		experience.ForceUpdate = ForceUpdate

		self:RegisterEvent('PLAYER_XP_UPDATE', Path)
		self:RegisterEvent('PLAYER_LEVEL_UP', Path)
		self:RegisterEvent('UNIT_PET_EXPERIENCE', Path)

		self:RegisterEvent('UPDATE_EXHAUSTION', Path)
		experience.Rested:SetFrameLevel(experience:GetFrameLevel() - 1)

		return true
	end
end

local function Disable(self)
	local experience = self.Experience
	if(experience) then
		self:UnregisterEvent('PLAYER_XP_UPDATE', Path)
		self:UnregisterEvent('PLAYER_LEVEL_UP', Path)
		self:UnregisterEvent('UNIT_PET_EXPERIENCE', Path)
		self:UnregisterEvent('UPDATE_EXHAUSTION', Path)
	end
end

oUF:AddElement('Experience', Path, Enable, Disable)