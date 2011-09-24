--[[

	License:

	 Copyright (c) 2009 Arthur Guerard

	 Permission is hereby granted, free of charge, to any person obtaining a copy
	 of this software and associated documentation files (the "Software"), to deal
	 in the Software without restriction, including without limitation the rights
	 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	 copies of the Software, and to permit persons to whom the Software is
	 furnished to do so, subject to the following conditions:

	 The above copyright notice and this permission notice shall be included in
	 all copies or substantial portions of the Software.

	 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	 THE SOFTWARE.


	Documentation:
	
		Element handled:
			.TotemBar (must be a table with statusbar inside)
		
		.TotemBar only:
			.delay : The interval for updates (Default: 0.1)
			.colors : The colors for the statusbar, depending on the totem
			.Name : The totem name
			.Destroy (boolean): Enables/Disable the totem destruction on right click
			
			NOT YET IMPLEMENTED
			.Icon (boolean): If true an icon will be added to the left or right of the bar
			.IconSize : If the Icon is enabled then changed the IconSize (default: 8)
			.IconJustify : any anchor like "TOPLEFT", "BOTTOMRIGHT", "TOP", etc
			
		.TotemBar.bg only:
			.multiplier : Sets the multiplier for the text or the background (can be two differents multipliers)

--]]

local W,M,L,V = unpack(select(2,...))
local floor = floor
local pClass = M.class
if pClass ~= "SHAMAN" or V.player.totem ~= true then W.Totems = M.null return end
local make_mask = W.make_mask

W.Totems = function(self,var,unit)
	if unit ~= "player" then return end
	local lol_totem = {}
	for i = 1, 4 do
		lol_totem[i] = CreateFrame("StatusBar", nil, self)
		local lol_tot = lol_totem[i]
		lol_tot:SetHeight(var.ph)
		lol_tot:SetWidth((var.w-3*6-8)/4)
		lol_tot:SetStatusBarTexture(M["media"].barv)
		lol_tot:SetMinMaxValues(0, 1)
		lol_tot.total = 0
		lol_tot.Destroy = true
		if i ~= 1 then
			lol_tot:SetPoint("LEFT",lol_totem[i-1],"RIGHT",6,0)
		end
		lol_tot.bg = lol_tot:CreateTexture(nil, "BORDER")
		lol_tot.glow = M.frame(lol_tot,0)
		lol_tot.glow:SetPoint("TOPLEFT", lol_tot, "TOPLEFT", -4, 4)
		lol_tot.glow:SetPoint("BOTTOMRIGHT", lol_tot, "BOTTOMRIGHT", 4, -4)
		local cd = M.setcdfont(lol_tot,14,"OUTLINE")
		cd:SetPoint("RIGHT",lol_tot,-.1,-.1)
		lol_tot.cd = cd
		lol_tot:EnableMouse(true)
		make_mask(lol_tot)
	end
	if var.isf_pos == "TOP" then
		lol_totem[1]:SetPoint('TOPLEFT', self.Power, 'BOTTOMLEFT', 0, -6)
		self.BottomAuraUnchor:NewOffset(var.ph+6)
	else
		lol_totem[1]:SetPoint('BOTTOMLEFT', self.Power, 'TOPLEFT', 0, 6)
		self.TopAuraUnchor:NewOffset(var.ph+6)
	end
	self.TotemBar = lol_totem
end

local ns = W
local oUF = ns.oUF
local unpack = unpack
local delay = 0.1

-- In the order, fire, earth, water, air
local colors = {
	[1] = {0.752,0.172,0.02},
	[2] = {0.741,0.580,0.04},		
	[3] = {0,0.443,0.631},
	[4] = {0.6,1,0.945},	
}

local GetTotemInfo, SetValue, GetTime = GetTotemInfo, SetValue, GetTime
	
local function TotemOnClick(self,...)
	local id = self.ID
	local mouse = ...
		if IsShiftKeyDown() then
			for j = 1,4 do 
				DestroyTotem(j)
			end 
		else 
			DestroyTotem(id) 
		end
end
	
local function InitDestroy(self)
	local totem = self.TotemBar
	for i = 1 , 4 do
		local Destroy = CreateFrame("Button",nil, totem[i])
		Destroy:SetAllPoints(totem[i])
		Destroy:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		Destroy.ID = i
		Destroy:SetScript("OnClick", TotemOnClick)
	end
end	

local function totem_update(self,t)
	self.total = self.total + t
	if self.total >= delay then
		self.total = 0
		local _, _, startTime, duration = GetTotemInfo(self.ID)
		local x  = GetTime() - startTime
		local minus = duration - x
		if minus < 0 then
			self:SetValue(0)
			self.cd:SetText("")
			self:SetScript("OnUpdate",nil)
		else
			self:SetValue(1 - (x / duration))
			if minus <= 30 then
				self.cd:SetText(floor(duration - x +.5))
			else
				self.cd:SetText("")
			end
		end
	end
end
	
local function UpdateSlot(self, slot)
	local totem = self.TotemBar
	local haveTotem, name, startTime, duration = GetTotemInfo(slot)
	totem[slot]:SetStatusBarColor(unpack(totem.colors[slot]))
	totem[slot]:SetValue(0)	
	totem[slot].ID = slot
	-- If we have a totem then set his value 
	if(haveTotem) then
		if totem[slot].Name then
			totem[slot].Name:SetText(Abbrev(name))
		end					
		if(duration >= 0) then	
			totem[slot]:SetValue(1 - ((GetTime() - startTime) / duration))	
			-- Status bar update
			totem[slot]:SetScript("OnUpdate",totem_update)					
		else
			-- There's no need to update because it doesn't have any duration
			totem[slot]:SetScript("OnUpdate",nil)
			totem[slot]:SetValue(0)
		end 
	else
		-- No totem = no time 
		if totem[slot].Name then
			totem[slot].Name:SetText(" ")
		end
		totem[slot]:SetValue(0)
	end

end

local function Update(self, unit)
	-- Update every slot on login, still have issues with it
	for i = 1, 4 do 
		UpdateSlot(self, i)
	end
end

local function Event(self,event,...)
	if event == "PLAYER_TOTEM_UPDATE" then
		UpdateSlot(self, ...)
	end
end

local function Enable(self, unit)
	local totem = self.TotemBar
	if(totem) then
		self:RegisterEvent("PLAYER_TOTEM_UPDATE" ,Event)
		totem.colors = setmetatable(totem.colors or {}, {__index = colors})
		delay = totem.delay or delay
		InitDestroy(self)
		TotemFrame:UnregisterAllEvents()		
		return true
	end	
end

local function Disable(self,unit)
	local totem = self.TotemBar
	if(totem) then
		self:UnregisterEvent("PLAYER_TOTEM_UPDATE", Event)
		TotemFrame:Show()
	end
end
			
oUF:AddElement("TotemBar",Update,Enable,Disable)