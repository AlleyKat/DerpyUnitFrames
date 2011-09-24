local W,M,L,V = unpack(select(2,...))
local setcdfont = M.setcdfont
local auraUpdateIcon
local _UPDATE_TIMER
local floor = floor

local new_vertex = function(self,r,g,b)
	self.parent.glow:backcolor(r,g,b,.6)
end

local __hide = function(self)
	self.parent.glow:backcolor(0,0,0)
end

local auraIcon = function(icons, button)
	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	
	button:SetHeight(floor(icons.size*.875+.5))
	
	button.icon:SetTexCoord(3/32,1-3/32,5/32,1-5/32)
	button.icon:SetGradient("VERTICAL",.5,.5,.5,1,1,1)
	button.icon:SetPoint("TOPLEFT", button,1,-1)
	button.icon:SetPoint("BOTTOMRIGHT", button,-1,1)
	
	button.cd:ClearAllPoints()
	button.cd:SetAllPoints(button.icon)
	button.cd:SetFrameLevel(button.cd:GetFrameLevel()-1)
	
	button.glow = M.frame(button,button:GetFrameLevel()-1,button:GetFrameStrata())
	button.glow:SetPoint("TOPLEFT",-3,3)
	button.glow:SetPoint("BOTTOMRIGHT",3,-3)
	button.glow:SetBackdrop(M.bg_edge)

	button.count:ClearAllPoints()
	button.count:SetPoint(icons.count_pos,button,icons.count_pos_x,icons.count_pos_y)
	button.count:SetFont(M['media'].font,icons.count_size,"OUTLINE")
	button.count:SetShadowOffset(1,-1)
	button.count:SetTextColor(1,1,1)
	
	button.overlay:SetTexture(nil)
	button.overlay:Hide()
	button.overlay.Show = M.null
	button.overlay.parent = button
	button.overlay.SetVertexColor = new_vertex
	button.overlay.Hide = __hide
	
	if icons.shownum_cd then
		button.UpdateNumTimer = _UPDATE_TIMER
		button.remaining = setcdfont(button,icons.num_cd_size,"OUTLINE")
		button.remaining:SetPoint(icons.num_cd_pos,icons.num_cd_pos_x,icons.num_cd_pos_y)
	else
		button.UpdateNumTimer = M.null
	end
	
end

do
	local huge = math.huge
	local UnitAura = UnitAura
	local CreateAuraTimer = M.CreateAuraTimer
	_UPDATE_TIMER = function(icon, unit, index)
		local _, _, _, _, _, duration, expirationTime = UnitAura(unit, index, icon.filter)
		if duration and duration > 0 then
			icon.remaining:Show()
			icon.timeLeft = expirationTime
			icon:SetScript("OnUpdate",CreateAuraTimer)
		else
			icon.remaining:Hide()
			icon.timeLeft = huge		
			icon:SetScript("OnUpdate",nil)
		end
		icon.first = true	
	end
end

local Update_aura = function(icons, unit, icon, index)
	icon:UpdateNumTimer(unit,index)
end

local nn_help = function(aura,prefix,var)
	if not(var[prefix.."_show_cd"]) then
		aura.disableCooldown =  true
	end
	local x = var[prefix.."pos"] == "TOP" and "BOTTOM" or "TOP"
	local y = var[prefix.."gr_x"] == "LEFT" and "RIGHT" or "LEFT"
	aura.initialAnchor= x..y
	aura["growth-x"] = 	var[prefix.."gr_x"]
	aura["growth-y"] = 	var[prefix.."pos"] == "TOP" and "UP" or "DOWN"
	aura.size = 		var[prefix.."_size"]
	aura.shownum_cd = 	var[prefix.."_show_numcd"]
	aura.num_cd_pos = 	var[prefix.."_num_cd_pos"]
	aura.num_cd_pos_x = var[prefix.."_num_cd_pos_x"]
	aura.num_cd_pos_y = var[prefix.."_num_cd_pos_y"]
	aura.num_cd_size =	var[prefix.."_num_cd_size"]
	aura.count_size = 	var[prefix.."_count_size"]
	aura.count_pos =	var[prefix.."_count_pos"]
	aura.count_pos_x =	var[prefix.."_count_pos_x"]
	aura.count_pos_y = 	var[prefix.."_count_pos_y"]
end

local _postion = function(aura,self,var)
	if var == "TOP" then
		aura:SetPoint("BOTTOMLEFT",self.TopAuraUnchor,"TOPLEFT",self._left_aura_offset,0)
		aura:SetPoint("BOTTOMRIGHT",self.TopAuraUnchor,"TOPRIGHT",self._right_aura_offset,0)
	else
		aura:SetPoint("TOPLEFT",self.BottomAuraUnchor,"BOTTOMLEFT",self._left_aura_offset,0)
		aura:SetPoint("TOPRIGHT",self.BottomAuraUnchor,"BOTTOMRIGHT",self._right_aura_offset,0)
	end
end

local _aura_init = function(self)
	local aura = CreateFrame("Frame",nil,self)
	aura:SetFrameLevel(2)
	aura['spacing-x'] = 4 -- don`t touch that
	aura['spacing-y'] = 0 -- don`t touch that
	aura:SetHeight(10)
	aura.showDebuffType = true
	aura.PostCreateIcon = auraIcon
	aura.PostUpdateIcon = Update_aura
	return aura
end

W.Auras = function(self,unit,var)
	if unit == "targettarget" or unit == "focustarget" then return end
	if not var.buffs and not var.debuffs then return end
	if var.buffspos == var.debuffspos and var.buffsmax ~= 0 and var.buffsmax ~= 0 and var.buffs and var.debuffs then
		local aura = _aura_init(self)
		aura.numBuffs = var.buffsmax
		aura.numDebuffs = var.debuffsmax
		aura.buffsgray = var.buffs_gray
		aura.debuffsgray = var.debuffs_gray
		nn_help(aura,"buffs",var)
		_postion(aura,self,var.buffspos)
		self.Auras = aura
	elseif unit == "party" then
	
	else
		if var.buffs and var.buffsmax ~= 0 then
			local aura = _aura_init(self)
			aura.num = var.buffsmax
			aura.buffsgray = var.buffs_gray
			nn_help(aura,"buffs",var)
			_postion(aura,self,var.buffspos)
			self.Buffs = aura
		end
		if var.debuffs and var.debuffsmax ~= 0 then
			local aura = _aura_init(self)
			aura.num = var.debuffsmax
			aura.debuffsgray = var.debuffs_gray
			nn_help(aura,"debuffs",var)
			_postion(aura,self,var.debuffspos)
			self.Debuffs = aura
		end
	end
end

local modif_hei = function(self,var,last)
	self._currens = self._currens + var
	if not InCombatLockdown() then
		self:SetHeight(self._currens)
	else
		M.addcombat(function()
			self:SetHeight(self._currens)
			M.addcombat("remove",self.subname,"out")
		end,self.subname,"out")
	end
end

local _temp_help = function(self,unit,pos)
	self._currens = 0
	self.subname = "DerpyAuraUnch"..unit..pos
	self.NewOffset = modif_hei
	self:NewOffset(1)
end

W.AurasUnchor = function(self,unit)
	if unit == "targettarget" or unit == "focustarget" then return end
	local top_unk = CreateFrame("Frame",nil,self)
	top_unk:SetPoint("BOTTOMLEFT",self,"TOPLEFT",3,0)
	top_unk:SetPoint("BOTTOMRIGHT",self,"TOPRIGHT",-3,0)
	_temp_help(top_unk,unit,"Top")
	self.TopAuraUnchor = top_unk
	local bot_unk = CreateFrame("Frame",nil,self)
	bot_unk:SetPoint("TOPLEFT",self,"BOTTOMLEFT",3,0)
	bot_unk:SetPoint("TOPRIGHT",self,"BOTTOMRIGHT",-3,0)
	_temp_help(bot_unk,unit,"Bottom")
	self.BottomAuraUnchor = bot_unk
	self._right_aura_offset = 0
	self._left_aura_offset = 0
end
