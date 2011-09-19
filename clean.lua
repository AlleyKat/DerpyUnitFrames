local W,M,L,V = unpack(select(2,...))

M.addlast(function()
	for _,i in pairs({
		"Portrait",
		"Health",
		"Power",
		"Info",
		"Feed",
		"SpellRange",
		"Experience",
		"Reputation",
		"Totems",
		"Runes",
		"Shards",
		"SetAnim",
		"make_mask",
		"Spawn",
		"druid",
		"SniperOn",
		"SniperOff",
		"Threat",
		"ThreatBar",
		"Castbar",
	}) do W[i] = nil end
end)