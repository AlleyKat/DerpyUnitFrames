local W,M,L,V = unpack(select(2,...))

W.Info = function(self,unit,tablevar)
	if not tablevar.isf and unit~="player" and unit~="target" then return end
	local isf = M.frame(self,3,self:GetFrameStrata())
	local info
	local text_offset = tablevar.isf_offset/10 - 2
	if unit ~= "player" then
		info = M.setfont(isf,tablevar.isf_height)
	end
	if unit ~= "player" and unit ~= "target" then
		self:Tag(info,"[name]")
		info:SetJustifyH("CENTER")
		info:SetPoint("LEFT",isf,8,text_offset)
		info:SetPoint("RIGHT",isf,-7.5,text_offset)
		local x = tablevar.power_pos == "RIGHT" and "LEFT" or "RIGHT"
		local p = tablevar.isf_pos == "TOP" and "BOTTOM" or "TOP"
		local y = tablevar.isf_pos == "TOP" and 2 or -2
		isf:SetPoint(p..x,self,tablevar.isf_pos..x,0,tablevar.isf_pos == "TOP" and -2 or 2)
		isf:SetSize(tablevar.power and tablevar.w+tablevar.pw+6 or tablevar.w,8+tablevar.isf_height)
	else
		isf:SetSize(tablevar.w,8+tablevar.isf_height)
		if tablevar.isf_pos == "TOP" then
			isf:SetPoint("BOTTOM",self,"TOP",0,-2)
		else
			isf:SetPoint("TOP",self,"BOTTOM",0,2)
		end
		local H_value = M.setfont(isf,tablevar.isf_height,nil,nil,"RIGHT")
		local P_value = M.setfont(isf,tablevar.isf_height)
		self.Health.value = H_value
		self.Power.value = P_value
		if unit == "player" then
			H_value:SetPoint("RIGHT",isf,-7.5,text_offset)
			P_value:SetPoint("LEFT",isf,8,text_offset)
			local druid = W.druid(self,isf,tablevar.isf_height)
			if druid then
				druid:SetPoint("LEFT",P_value,"RIGHT")
				druid:SetPoint("RIGHT",H_value,"LEFT")
			end
		else
			local H_perc = M.setfont(isf,tablevar.isf_height,nil,nil,"RIGHT")
			H_perc:SetPoint("RIGHT",isf,-7.5,text_offset)
			H_value:SetPoint("RIGHT",H_perc,"LEFT")
			self.Health.value_percent = H_perc
			P_value:SetPoint("RIGHT",H_value,"LEFT")
			self:Tag(info,"|cfffed100[smartlevel]|r [name]")
			info:SetPoint("LEFT",isf,8,text_offset)
			info:SetPoint("RIGHT",P_value,"LEFT")
		end
	end
	self.isf = isf
end