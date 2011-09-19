local W,M,L,V = unpack(select(2,...))
local unpack = unpack
local floor = floor

local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost
local UnitIsConnected = UnitIsConnected

local w_dead = "|cffFFFFFFDead|r"
local w_ghost = "|cffFFFFFFGhost|r"
local w_offline = "|cffFFFFFFOffline|r"

local u_dead = "|cffFFFFFFDEAD|r"
local u_ghost = "|cffFFFFFFGHOST|r"
local u_offline = "|cffFFFFFFOFF|r"

local bar_value = function(self,value)
	if not self.value then return end
	self.value:SetText(value)
end

local are_you_dead = function(self,unit,up)
	if UnitIsDead(unit) 		 then	bar_value(self,up and u_dead or w_dead) 		return true end
	if UnitIsGhost(unit) 		 then	bar_value(self,up and u_ghost or w_ghost) 		return true end
	if not UnitIsConnected(unit) then	bar_value(self,up and u_offline or w_offline) 	return true end
	return false
end

local health_color = function(per)
	if per <= .5 then 
		return 1,per*2,0
	else
		return 2*(1-per),1,0
	end
end

local stop_anim = function(self,bar,anim)
	if anim then
		bar.second.anim:Finish()
		bar.second:SetFrameLevel(5)
		bar:SetFrameLevel(6)
	end
end

local UnitIsPlayer = UnitIsPlayer
local UnitSelectionColor = UnitSelectionColor
local UnitClass = UnitClass
local color_class = W.oUF.colors.class

local for_target = function(value,unit,current,maxhp,value_percent)
	if not UnitIsPlayer(unit) then 
		value:SetTextColor(UnitSelectionColor(unit))		
	else
		value:SetTextColor(unpack(color_class[select(2, UnitClass(unit))]))		
	end
	value:SetText(current.." ")
	local perc = current/maxhp
	value_percent:SetText(floor(perc*100).." %")
	value_percent:SetTextColor(health_color(perc))
end

-- update function normal
local updateHealth = function(bar, unit, current, maxhp)  
	
	local second = bar.second
	local anim = second.anim:IsPlaying()
	
	if are_you_dead(bar,unit,bar.party) then
		bar:SetStatusBarColor(0,0,0,0)
		second:SetStatusBarColor(0.2, 0.2, 0.2, 0.68)
		second:SetMinMaxValues(0,maxhp)
		second:SetValue(maxhp)
		stop_anim(second,bar,anim)
		second:SetAlpha(1)
		if bar.value_percent then
			bar.value_percent:SetText("")
		end
	else
		if unit == "player" and bar.value then 
			bar.value:SetText(current)
			bar.value:SetTextColor(health_color(current/maxhp))
		elseif unit == "target" then
			for_target(bar.value,unit,current,maxhp,bar.value_percent)
		elseif bar.party then
			bar.value:SetText()
		end

		bar:SetValue(maxhp-current)
		second:SetMinMaxValues(0,maxhp)
		second:SetValue(maxhp-current)
		
		if current == maxhp then
			bar:SetStatusBarColor(0, 0, 0, 0)
			second:SetStatusBarColor(0.5, 0, 0, 0.6)
			stop_anim(second,bar,anim)
			second:SetAlpha(1)
		else
			if (current/maxhp) <= bar.lowhealthcc then
				if not bar.second.anim:IsPlaying() then
					bar.second.anim:Play()
					bar:SetFrameLevel(5)
					bar.second:SetFrameLevel(6)	
				end
				bar.second:SetStatusBarColor(1, 0, 0, .95)
				bar:SetStatusBarColor(0.09, 0, 0, 0.7)
			else
				stop_anim(second,bar,anim)
				second:SetAlpha(1)
				bar:SetStatusBarColor(0.1, 0, 0, 0.666)
				second:SetStatusBarColor(0.5, 0, 0, 0.6)
			end
		end
	end
end

W.Health = function(self,unit,var,party)
	local hp = CreateFrame("StatusBar", nil, self)
	hp:SetStatusBarTexture(M["media"].barv)
	hp:SetAllPoints(self.Portrait)
	hp:SetFrameLevel(6)
	hp:SetStatusBarColor(0,0,0,0)
	hp.Smooth = var.hsmooth
	hp.second = CreateFrame("StatusBar",nil,hp)
	hp.second:SetFrameLevel(5)
	hp.second:SetAllPoints(self.Portrait)
	hp.second:SetStatusBarTexture(M["media"].blank)
	hp.second:SetStatusBarColor(0,0,0,0)
	if unit ~= "target" and unit ~= "player" then
		hp:SetOrientation("VERTICAL")
		hp.second:SetOrientation("VERTICAL")
	end
	W.SetAnim(hp.second,.3,1,2)
	self.Health = hp
	self.Health.party = party
	self.Health.lowhealthcc = var.lowhealth/100
	self.Health.PostUpdate = updateHealth
end