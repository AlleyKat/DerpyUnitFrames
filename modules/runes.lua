local W,M,L,V = unpack(select(2,...))
local pClass = M.class
if pClass ~= "DEATHKNIGHT" or V.player.runes ~= true then W.Runes = M.null return end

local __new_value = function(self,value)
	self:___SetValue(value)
	if value == 1 then
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

W.Runes = function(self,var,unit)
	if unit~="player" then return end
	local runes = CreateFrame("Frame",nil,self)
	for i = 1, 6 do
		runes[i] = CreateFrame('StatusBar', nil, runes)
		local rune = runes[i]
		rune:SetStatusBarTexture(M["media"].barv)
		rune:SetWidth((var.w-5*6-8)/6)
		rune:SetHeight(var.ph)
		if i == 1 then 
			if var.isf_pos == "TOP" then
				rune:SetPoint('TOPLEFT', self.Power, 'BOTTOMLEFT', 0, -6)
				self.BottomAuraUnchor:NewOffset(var.ph+6)
			else
				rune:SetPoint('BOTTOMLEFT', self.Power, 'TOPLEFT', 0, 6)
				self.TopAuraUnchor:NewOffset(var.ph+6)
			end
		else	
			rune:SetPoint('LEFT', runes[i-1], 'RIGHT', 6, 0)
		end
		rune.glow = CreateFrame ("Frame",nil,rune)
		M.setbackdrop(rune.glow)
		M.style(rune.glow)
		rune.glow:SetPoint("TOPLEFT",-4,4)
		rune.glow:SetPoint("BOTTOMRIGHT",4,-4)
		rune.glow:SetFrameLevel(0)
		W.make_mask(rune)
		rune.SetValue = __new_value
	end
	self.Runes = runes
end
