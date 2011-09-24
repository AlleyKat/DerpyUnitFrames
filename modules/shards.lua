local W,M,L,V = unpack(select(2,...))
local pClass = M.class
if (pClass ~= "WARLOCK" and pClass ~= "PALADIN") or V.player.shards ~= true then W.Shards = M.null return end

local UIFrameFadeIn = UIFrameFadeIn
local UIFrameFadeOut = UIFrameFadeOut

local _update = function(self,t)
	self.currency = self.currency + t*self.direct*1.4
	self:SetValue(self.currency)
	if self.currency <= 0 or self.currency >= 1 then 
		self:SetScript("OnUpdate",nil)
		if self.currency <= 0 then
			self.currency = 0
			self:SetValue(0)
		else
			self.currency = 1
			self:SetValue(1)
		end
	end
end

local _setalpha = function(self,value)
	if value == 0 then
		if self.direct == -1 then return end
		self.direct = -1
		UIFrameFadeOut(self.mask,.35,self.mask:GetAlpha(),0)
	elseif value == 1 then
		if self.direct == 1 then return end
		self.direct = 1
		UIFrameFadeIn(self.mask,.35,self.mask:GetAlpha(),1)
	end
	self:SetScript("OnUpdate",_update)
end

W.Shards = function(self,var,unit)
	if unit ~= "player" then return end
	local shards = {}
	for i = 1,3 do
		local shard = CreateFrame("StatusBar",nil,self)
		shards[i] = shard
		shard:SetSize((var.w-2*6-8)/3,var.ph)
		local glow = M.frame(shard,0,shard:GetFrameStrata())
		glow:SetPoint("TOPLEFT",shard,-4,4)
		glow:SetPoint("BOTTOMRIGHT",shard,4,-4)
		shard.glow = glow
		local mask = CreateFrame("Frame",nil,glow)
		mask:SetAllPoints()
		mask:SetFrameLevel(2)
		M.style(mask,true)
		mask:SetBackdrop(M.bg_edge)
		shard:SetStatusBarTexture(M.media.barv)
		if pClass == "WARLOCK" then
			shard:SetStatusBarColor(.86,.44,.8)
			M.backcolor(mask,.86,.44,.8,.888)
		else
			shard:SetStatusBarColor(1,.95,.33)
			M.backcolor(mask,1,.95,.33,.888)
		end
		if i==1 then
			if var.isf_pos == "TOP" then
				shard:SetPoint('TOPLEFT', self.Power, 'BOTTOMLEFT', 0, -6)
				self.BottomAuraUnchor:NewOffset(var.ph+6)
			else
				shard:SetPoint('BOTTOMLEFT', self.Power, 'TOPLEFT', 0, 6)
				self.TopAuraUnchor:NewOffset(var.ph+6)
			end
		else
			shard:SetPoint("LEFT",shards[i-1],"RIGHT",6,0)
		end
		mask:SetAlpha(0)
		shard.mask = mask
		shard:SetMinMaxValues(0,1)
		shard.currency = 0
		shard.direct = -1
		shard:SetValue(0)
		shard.SetAlpha = _setalpha
	end
	if pClass == "WARLOCK" then
		self.SoulShards = shards
	else
		self.HolyPower = shards
	end
end
