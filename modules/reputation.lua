local W,M,L,V = unpack(select(2,...))

if UnitLevel("player") ~= MAX_PLAYER_LEVEL or V.player.rep ~= true then W.Reputation = M.null return end

W.Reputation = function(self,var)
	if var.rep ~= true then return end
	local XP = CreateFrame('StatusBar', nil, self)
		XP:SetPoint('TOPLEFT',self.isf,4,-4)
		XP:SetPoint('BOTTOMRIGHT',self.isf,-4,4)
		XP:SetStatusBarTexture(M['media'].barv)
		XP:SetStatusBarColor(.07,.27,.5)
		XP:SetFrameStrata(self:GetFrameStrata())
		XP:SetFrameLevel(self.isf:GetFrameLevel()+2)
		XP.Tooltip = true
		M.style(XP,nil,-1)
		XP:SetBackdrop({bgFile = M["media"].blank})
		XP:SetBackdropColor(unpack(M["media"].color))
	local Text = M.setfont(XP,var.isf_height,nil,nil,"CENTER")
		Text:SetPoint('CENTER',XP,1.3,.3)
		XP.Text = Text
		XP.Text:SetWidth(var.w-16)
		XP:SetScript('OnEnter', function(self) UIFrameFadeIn(self,.1,0,1) end)
		XP:SetScript('OnLeave', function(self) UIFrameFadeOut(self,.2,1,0) end)
		XP:SetAlpha(0)
		
	self.Reputation = XP
end

if IsAddOnLoaded("oUF_Reputation") then return end
--[[

	Elements handled:
	 .Reputation [statusbar]
	 .Reputation.Text [fontstring] (optional)

	Booleans:
	 - Tooltip

	Functions that can be overridden from within a layout:
	 - PostUpdate(self, event, unit, bar, min, max, value, name, id)
	 - OverrideText(bar, min, max, value, name, id)

--]]

local ___x = V.player.isf_pos
local GetWatchedFactionInfo = GetWatchedFactionInfo
local sform = string.format

local function tooltip(self)
	local name, id, min, max, value = GetWatchedFactionInfo()
	if ___x == "TOP" then
		GameTooltip:SetOwner(self,'ANCHOR_TOP',0,2)
	else
		GameTooltip:SetOwner(self,'ANCHOR_BOTTOM',0,-2)
	end
	GameTooltip:AddLine(sform('%s (%s)', name, _G['FACTION_STANDING_LABEL'..id]))
	GameTooltip:AddLine(sform('%d / %d (%d%%)', value - min, max - min, (value - min) / (max - min) * 100))
	GameTooltip:Show()
end

local function update(self, event, unit)
	local bar = self.Reputation
	if(not GetWatchedFactionInfo()) then return bar:Hide() end

	local name, id, min, max, value = GetWatchedFactionInfo()
	bar:SetMinMaxValues(min, max)
	bar:SetValue(value)
	bar:Show()
	bar.Text:SetFormattedText('%d / %d - %s', value - min, max - min, name)

	if(bar.PostUpdate) then bar.PostUpdate(self, event, unit, bar, min, max, value, name, id) end
end

local function enable(self, unit)
	local bar = self.Reputation
	if(bar and unit == 'player') then

		self:RegisterEvent('UPDATE_FACTION', update)

		bar:EnableMouse()
		bar:HookScript('OnLeave', GameTooltip_Hide)
		bar:HookScript('OnEnter', tooltip)

		return true
	end
end

local function disable(self)
	if(self.Reputation) then
		self:UnregisterEvent('UPDATE_FACTION', update)
	end
end

W.oUF:AddElement('Reputation', update, enable, disable)