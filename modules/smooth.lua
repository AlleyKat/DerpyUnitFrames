-- edited oUF_Smooth by Xuerian
local W,M,L,V = unpack(select(2,...))
if V.common.updatemod == 0 then return end

local _, ns = ...
local oUF = ns.oUF

local smoothing = {}
local function Smooth(self, value)
	if value ~= self:GetValue() or value == 0 then
		smoothing[self] = value
	else
		smoothing[self] = nil
	end
end

local function SmoothBar(self, bar)
	bar.SetValue_ = bar.SetValue
	bar.SetValue = Smooth
end

local function hook(frame)
	frame.SmoothBar = SmoothBar
	if frame.Health and frame.Health.Smooth then
		frame:SmoothBar(frame.Health)
	end
	if frame.Power and frame.Power.Smooth then
		frame:SmoothBar(frame.Power)
	end
	if frame.W_ThreatBar and frame.W_ThreatBar.Smooth then
		frame:SmoothBar(frame.W_ThreatBar)
	end
end


for i, frame in ipairs(oUF.objects) do hook(frame) end
oUF:RegisterInitCallback(hook)

local updatemod = V.common.updatemod
local f, min, max, abs = CreateFrame("Frame"), math.min, math.max, math.abs
f:SetScript("OnUpdate", function(_,t)
	for bar, value in pairs(smoothing) do
		local cur = bar:GetValue()
		local limit_ = 15*t
		local barmin, barmax = bar:GetMinMaxValues()
		local new = cur + min((value-cur)/updatemod, max(value-cur,limit_))
		if new ~= new then
			new = value
		end
		bar:SetValue_(new)
		if cur == value or abs(value - cur) < limit_ then
			bar:SetValue_(value)
			smoothing[bar] = nil
		end
	end
end)

