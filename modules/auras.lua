local W,M,L,V = unpack(select(2,...))
local setcdfont = M.setcdfont
local auraUpdateIcon
local _UPDATE_TIMER

local new_vertex = function(self,r,g,b)
	local icon = self.parent
	if (icon.debuff) then
		icon.glow:backcolor(r,g,b,.6)
	else 
		icon.glow:backcolor(0,0,0)
	end
end

local auraIcon = function(icons, button)
	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	button.UpdateNumTimer = _UPDATE_TIMER
	
	button:SetHeight(floor(icons.size*.875+.5))
	
	button.icon:SetTexCoord(.1, .9, .1, .9)
	button.icon:SetGradient("VERTICAL",.5,.5,.5,1,1,1)
	button.icon:SetPoint("TOPLEFT", button,1,-1)
	button.icon:SetPoint("BOTTOMRIGHT", button,-1,1)
	
	button.glow = M.frame(button,0,button:GetFrameStrata())
	button.glow:SetPoint("TOPLEFT",-3,3)
	button.glow:SetPoint("BOTTOMRIGHT",3,-3)
	button.glow:SetBackdrop(M.bg_edge)

	button.count:ClearAllPoints()
	button.count:SetPoint(icons.count_pos,button,icons.count_pos_x,icons.count_pos_y)
	button.count:SetFont(M['media'].font,icons.count_size,"OUTLINE")
	button.count:SetShadowOffset(1,-1)
	button.count:SetTextColor(1,1,1)
	
	button.overlay:SetTexture(nil)
	button.overlay.parent = button
	button.overlay.SetVertexColor = new_vertex
	
	if icons.shownum_cd then
		button.remaining = setcdfont(button,icons.num_cd_size,"OUTLINE")
		button.remaining:SetPoint(icons.num_cd_pos,icons.num_cd_pos_x,icons.num_cd_pos_y)
	end
end

do
	local huge = math.huge
	local UnitAura = UnitAura
	local CreateAuraTimer = M.CreateAuraTimer
	_UPDATE_TIMER = function(icons, unit, icon, index)
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

local Icon_Update = function(icons, unit, icon, index)
	

end

local nn_help = function(aura,prefix,var)
	aura.disableCooldown = not(var[prefix.."show_cd"]) and true or false
	aura.size = 		var[prefix.."size"]
	aura.shownum_cd = 	var[prefix.."show_numcd"]
	aura.num_cd_pos = 	var[prefix.."_num_cd_pos"]
	aura.num_cd_pos_x = var[prefix.."_num_cd_pos_x"]
	aura.num_cd_pos_y = var[prefix.."_num_cd_pos_y"]
	aura.num_cd_size =	var[prefix.."_num_cd_size"]
	aura.count_size = 	var[prefix.."_count_size"]
	aura.count_pos =	var[prefix.."_count_pos"]
	aura.count_pos_x =	var[prefix.."_count_pos_x"]
	aura.count_pos_y = 	var[prefix.."_count_pos_y"]
end

W.Auras = function(self,unit,var)
	if unit == "targettarget" or unit == "focustarget" then return end
	if not var.buffs and not var.debuffs then return end
	if var.buffspos == var.debuffspos then
		local aura = CreateFrame("Frame",nil,self)
		aura.initialAnchor = var.buffsinit_unchor
		aura["growth-x"] = var.buffsgr_x
		aura["growth-y"] = var.buffsgr_y
		aura.numBuffs = var.buffs == false and 0 or var.buffsmax
		aura.numDebuffs = var.debuffs == false and 0 or var.debuffsmax
		aura.spacing = 4 -- don`t touch that
		aura.buffsgray = var.buffsgray
		aura.debuffsgray = var.debuffsgray
		if var.buffs then
			nn_help(aura,"buffs",var)
		else
			nn_help(aura,"debuffs",var)
		end
		aura:SetSize(var.w,aura.size)
		aura.showDebuffType = true
		aura.PostCreateIcon = Icon_Update
		aura:SetSize("BOTTOM",self,"TOP",0,10)
	elseif unit == "party" then
	
	else
	
	end
end
