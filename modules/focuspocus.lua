local W,M,L,V = unpack(select(2,...))
W.SniperOn = function(self,unit)
	if unit ~= "target" then return end 
	local sniper = CreateFrame("BUTTON", "DerpySniperScope", self, "SecureActionButtonTemplate")
	sniper:EnableMouse(true)
	sniper:RegisterForClicks("AnyUp")
	sniper:SetAttribute("type", "macro")
	sniper:SetAttribute("macrotext", "/focus")
	sniper:SetHeight(32)
	sniper:SetWidth(88)
	sniper:SetFrameStrata(self:GetFrameStrata())
	sniper:SetFrameLevel(20)
	sniper:SetPoint("TOPRIGHT",-4,-4)
	
	sniper.headshot = sniper:CreateFontString(nil,"OVERLAY")
	sniper.headshot:SetFont(M['media'].font,33)
	sniper.headshot:SetShadowOffset(1.2,-1,2)	
	sniper.headshot:SetPoint("LEFT",12,1)
	sniper.headshot:SetJustifyH("LEFT")
	
	do
		local text = sniper.headshot
		local stage_table = {
			"",
			"F",
			"FO",
			"FOC",
			"FOCU",
			"FOCUS",}
		local curent_stage = 1
		local printer = CreateFrame("Frame",nil,sniper)
		printer:Hide()
		printer:SetScript("OnUpdate",function(self,et)
			curent_stage = curent_stage + self.dir
			if curent_stage == 7 then
				curent_stage = 6
				self:Hide() return
			elseif curent_stage == 0 then
				curent_stage = 1
				self:Hide() return
			end
			text:SetText(stage_table[curent_stage])
		end)
		sniper.printer = printer
	end
	sniper:SetScript("OnLeave", function(self) self.printer:Hide(); self.printer.dir = -1;  self.printer:Show(); end)
	sniper:SetScript("OnEnter", function(self) self.printer:Hide(); self.printer.dir = 1; self.printer:Show(); end)
	self.Sniper = sniper
end

W.SniperOff = function(self,unit)
	if unit ~= "focus" then return end
	local sniper2 = CreateFrame("BUTTON", "DerpySniperCancel", self, "SecureActionButtonTemplate")
	sniper2:EnableMouse(true)
	sniper2:RegisterForClicks("AnyUp")
	sniper2:SetAttribute("type", "macro")
	sniper2:SetAttribute("macrotext", "/clearfocus")
	sniper2:SetWidth(22)
	sniper2:SetHeight(24)
	sniper2:SetFrameStrata(self:GetFrameStrata())
	sniper2:SetFrameLevel(20)
	sniper2:SetPoint("TOPRIGHT",-4,-4)
	sniper2.headshot2 = sniper2:CreateFontString(nil,"OVERLAY")
	sniper2.headshot2:SetFont(M['media'].font_s,24)
	sniper2.headshot2:SetAllPoints(sniper2)
	sniper2.headshot2:SetTextColor(1,0,0)
	sniper2.headshot2:SetText("X")
	sniper2:SetScript("OnLeave", function(self) self.headshot2:SetVertexColor(1,0.2,0.1) end)
	sniper2:SetScript("OnEnter", function(self) self.headshot2:SetTextColor(1,1,0) end)
	self.Sniper = sniper2
end