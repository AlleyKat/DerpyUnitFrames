local W,M,L,V = unpack(select(2,...))
local unpack = unpack
local floor = floor
local mk_anim = (V['player'].lowmana == 0 and false) or true

--Flash lowmana
local mk_low_mana = function(self)
	if not(mk_anim) then return end
		local flashlow = CreateFrame("Frame",nil,self.Power)
		flashlow:SetBackdrop(M.bg_edge)
		flashlow:SetBackdropBorderColor(1,0,0,1)
		M.style(flashlow,true,3)
		flashlow.left:SetTexture(1,0,0)
		flashlow.right:SetTexture(1,0,0)
		flashlow.bottom:SetTexture(1,0,0)
		flashlow.top:SetTexture(1,0,0)
		flashlow:SetAllPoints(self.Power.glow)
		flashlow:SetAlpha(0)
		flashlow:SetFrameLevel(4)
		W.SetAnim(flashlow,.5,2,1)
		self.Power.flashlow = flashlow
end

local lowmanacc = V['player'].lowmana/100 -- need

local updatePower
do
	local lowmanacc = lowmanacc
	local UnitIsDead = UnitIsDead
	local UnitIsGhost = UnitIsGhost
	local UnitIsConnected = UnitIsConnected
	local UnitPowerType = UnitPowerType
	local UnitIsPlayer = UnitIsPlayer
	local colors = {
		["MANA"] = {.2, .4, 1},
		["RAGE"] = {.9, .1, .1},
		["FUEL"] = {0, 0.55, 0.5},
		["FOCUS"] = {.9, .9, .1},
		["ENERGY"] = {.9, .9, .1},
		["AMMOSLOT"] = {0.8, 0.6, 0},
		["RUNIC_POWER"] = {.1, .9, .9},
		["POWER_TYPE_STEAM"] = {0.55, 0.57, 0.61},
		["POWER_TYPE_PYRITE"] = {0.60, 0.09, 0.17}}

	-- Power Update
	updatePower = function(bar, unit, min, max)
		if UnitIsDead(unit) or UnitIsGhost(unit) or not(UnitIsConnected(unit)) then
			bar:SetValue(0)
			if bar.value then
				bar.value:SetText(" ")
			end
			if unit == "player" and mk_anim then
				if bar.flashlow.anim:IsPlaying() then
					bar.flashlow.anim:Finish()
					bar.flashlow:SetAlpha(0) 				
				end
			end	
		else
			bar:SetValue(min)
			if unit == "player" and bar.value then
				bar.value:SetText(min)
				if mk_anim then
					if min/max <= lowmanacc then
						if not bar.flashlow.anim:IsPlaying()  then
							bar.flashlow.anim:Play() 
						end
					else
						if bar.flashlow.anim:IsPlaying() then
							bar.flashlow.anim:Finish()
							bar.flashlow:SetAlpha(0) 
						end
					end			
				end
			elseif unit =="target" then
				local tclass = select(2, UnitClass(unit))
				if (not(UnitIsPlayer(unit)) and (tclass == "PALADIN")) or UnitIsPlayer(unit) then
					bar.value:SetText(min.." ")
				else
					bar.value:SetText(" ")
				end
			end
			local ptype = select(2, UnitPowerType(unit))
			if(colors[ptype]) then
				local r, g, b = unpack(colors[ptype])
				bar:SetStatusBarColor(r, g, b)
				if bar.value then
					bar.value:SetTextColor(r*.9, g*.9, b*.9)
				end
			end
		end
	end
end

local UpdateDruidMana
do
	local UnitPower = UnitPower
	local UnitPowerMax = UnitPowerMax
	local druid_anim = mk_anim
	local lowmanacc = lowmanacc
	
	-- Druid Mana Update
	UpdateDruidMana = function(self,t)
		self.timer = self.timer - t
		if self.timer > 0 then return end; self.timer = .2
		local num, str = UnitPowerType("player")
		if num ~= 0 then
			local min = UnitPower("player", 0)
			local max = UnitPowerMax("player", 0)
			mk_anim = false
			if min~=max then
				self.value:SetText(" "..min)
				self:SetAlpha(1)
			else
				self:SetAlpha(0)
			end
			if druid_anim then
				local flashlow = self.flashlow
				if min/max < lowmanacc then
					if not(flashlow.anim:IsPlaying()) then
						flashlow.anim:Play()
						flashlow:SetAlpha(1)
					end
				else
					if flashlow.anim:IsPlaying() then
						flashlow.anim:Finish()
						flashlow:SetAlpha(0)
					end
				end
			end
		else
			self:SetAlpha(0)
			mk_anim = druid_anim
		end
	end
end

-- DruidMana
W.druid = function(self,parent,h)
	if not(M.Class == "DRUID") then return end
	local druid = CreateFrame("Frame",nil,parent)
		druid.value = M.setfont(druid,h)
		druid.value:SetTextColor(.2,.4,1)
		druid.flashlow = self.Power.flashlow
		druid.timer = .2
		druid:SetScript("OnUpdate",UpdateDruidMana)
	return druid.value
end

W.Power = function(self,unit,var)
	if not var.power and unit~='player' and unit~='target' then return end
	local pp = CreateFrame("StatusBar",nil,self)
		pp:SetFrameLevel(3)
		pp:SetStatusBarTexture(M["media"].barv)
		pp.glow = M.frame(pp,2)
		pp.glow:SetPoint("TOPRIGHT",4,4)
		pp.glow:SetPoint("BOTTOMLEFT",-4,-4)
		pp.frequentUpdates = true
		pp.Smooth = true
		self.Power = pp
	if unit == "player" or unit == "target" then
		pp:SetSize(var.w-8,var.ph)
		if unit == "player" then mk_low_mana(self) end
		if var.isf_pos ~= "TOP" then
			pp:SetPoint("BOTTOM",self,"TOP",0,2)
			self.TopAuraUnchor:NewOffset(var.ph+6)
		else
			pp:SetPoint("TOP",self,"BOTTOM",0,-2)
			self.BottomAuraUnchor:NewOffset(var.ph+6)
		end
	else
		pp:SetOrientation("VERTICAL")
		pp:SetSize(var.pw,var.h-8)
		if var.power_pos ~= "RIGHT" then
			pp:SetPoint("RIGHT",self,"LEFT",-2,0)
			self._left_aura_offset = (6 + var.pw) * -1
		else
			pp:SetPoint("LEFT",self,"RIGHT",2,0)
			self._right_aura_offset = 6 + var.pw
		end
	end
	self.Power.PostUpdate = updatePower
end
