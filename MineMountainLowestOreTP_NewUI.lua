repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer

do
local LOAD_GATE_KEY = "CrystalToolsNewUILoadGate"
local LOAD_CHECK_INTERVAL = 0.2
local LOAD_CLEAR_STABLE_SECONDS = 0.75

local LoadGateToken = {}
_G[LOAD_GATE_KEY] = LoadGateToken

local function isCurrentLoadGate()
	return _G[LOAD_GATE_KEY] == LoadGateToken
end

local function waitForGameLoaded()
	while isCurrentLoadGate() and not game:IsLoaded() do
		task.wait(LOAD_CHECK_INTERVAL)
	end
end

local function waitForLocalPlayer()
	local player = Players.LocalPlayer
	while isCurrentLoadGate() and not player do
		task.wait(LOAD_CHECK_INTERVAL)
		player = Players.LocalPlayer
	end
	return player
end

local function waitForPlayerGui(player)
	if not player then
		return nil
	end

	local playerGui = player:FindFirstChild("PlayerGui")
	while isCurrentLoadGate() and not playerGui do
		task.wait(LOAD_CHECK_INTERVAL)
		playerGui = player:FindFirstChild("PlayerGui")
	end
	return playerGui
end

local function isGuiChainVisible(guiObject)
	local current = guiObject
	while current do
		if current:IsA("GuiObject") then
			local ok, visible = pcall(function()
				return current.Visible
			end)
			if ok and not visible then
				return false
			end
		elseif current:IsA("LayerCollector") then
			local ok, enabled = pcall(function()
				return current.Enabled
			end)
			if ok and not enabled then
				return false
			end
		end

		if current == game then
			break
		end
		current = current.Parent
	end

	return true
end

local function isLoadingGuiShowing(instance)
	if not (instance and instance.Parent) then
		return false
	end

	if instance:IsA("GuiObject") then
		return isGuiChainVisible(instance)
	end

	if instance:IsA("LayerCollector") then
		local ok, enabled = pcall(function()
			return instance.Enabled
		end)
		if ok and not enabled then
			return false
		end

		for _, descendant in ipairs(instance:GetDescendants()) do
			if descendant:IsA("GuiObject") and isGuiChainVisible(descendant) then
				return true
			end
		end
	end

	return false
end

local function isProgressAttributeLoading(player, prefix)
	local total = tonumber(player:GetAttribute(prefix .. "Total"))
	local progress = tonumber(player:GetAttribute(prefix .. "Progress"))
	if total and total > 0 then
		return not progress or progress < total
	end
	return false
end

local function isMineMountainLoadDone(player, playerGui)
	if not playerGui then
		return false
	end

	if player:GetAttribute("LoadingScreenActive") == true then
		return false
	end

	if isProgressAttributeLoading(player, "MountainReset") or isProgressAttributeLoading(player, "GardenLoading") then
		return false
	end

	local explorerHud = playerGui:FindFirstChild("ExplorerHud")
	local resetOverlay = explorerHud and explorerHud:FindFirstChild("ResetOverlay")
	if isLoadingGuiShowing(resetOverlay) then
		return false
	end

	local tutorialCover = playerGui:FindFirstChild("TutorialLoadingCover")
	if isLoadingGuiShowing(tutorialCover) then
		return false
	end

	return true
end

local function waitForMineMountainLoadDone(player)
	local playerGui = waitForPlayerGui(player)
	local clearSince = nil
	local announced = false

	while isCurrentLoadGate() do
		if isMineMountainLoadDone(player, playerGui) then
			clearSince = clearSince or os.clock()
			if os.clock() - clearSince >= LOAD_CLEAR_STABLE_SECONDS then
				break
			end
		else
			clearSince = nil
			if not announced then
				announced = true
				print("[CrystalTools] waiting for Mine Mountain loading screen to finish...")
			end
		end

		task.wait(LOAD_CHECK_INTERVAL)
		if playerGui and not playerGui.Parent then
			playerGui = waitForPlayerGui(player)
		end
	end

	if announced and isCurrentLoadGate() then
		print("[CrystalTools] loading finished, starting script.")
	end
end

waitForGameLoaded()
LocalPlayer = waitForLocalPlayer()
if not LocalPlayer or not isCurrentLoadGate() then
	return
end
waitForMineMountainLoadDone(LocalPlayer)
if not isCurrentLoadGate() then
	return
end
_G[LOAD_GATE_KEY] = nil
end

do
local AllowedUsers = {
	LockedScriptUsers = {
		mxnkyhpc5015 = true,
	},
	mxnkyhpc5015 = true,
	FERN_18157 = true, --ลูกค้า
	zonebuxx29 = true, --ลูกค้า
	Sleep223450 = true, --ลูกค้า
	m4rymeqw = true, --มิวสิค
	Achirada3 = true, --ลูกค้า
	fewkung2580 = true, --ลูกค้า
	OoShinobiPKoO = true, --ลูกค้า
	Abox0611 = true, --เด็กจ้าง
	guplqqeb = true, --เด็กจ้าง
	ufmn88zmuh19 = true, --ให้เทส
	Tans24fe = true --ลูกค้า
}

if not (LocalPlayer and AllowedUsers[LocalPlayer.Name]) then
	warn("[CrystalTools] This script is locked for this Roblox username.")
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "BenJaMinX",
			Text = "This username is not allowed to run this script.",
			Duration = 6
		})
	end)
	return
end

_G.CrystalToolsLockedScriptUnlocked = LocalPlayer and AllowedUsers.LockedScriptUsers and AllowedUsers.LockedScriptUsers[LocalPlayer.Name] == true
end

Players.LocalPlayer.Idled:Connect(function()
	local VirtualUser = game:GetService("VirtualUser")
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0, 0))
end)

local Config = {
	FarmDistance = 100,
	FarmInterval = 0.2,
	WeightEnabled = false,
	MoneyEnabled = false,
	LuckEnabled = false,
	WeightMode = "Above",
	WeightThreshold = 0,
	MoneyMode = "Above",
	MoneyThreshold = 0,
	LuckMode = "Above",
	LuckThreshold = 0,
	BombItemNames = { "ClassicBomb" },
	BombItemName = "ClassicBomb",
	BuyBombInterval = 0.1,
	BombStockRefreshInterval = 1,
	RadarItemNames = { "CrystalRadar" },
	RadarItemName = "CrystalRadar",
	BuyRadarInterval = 0.1,
	RadarStockRefreshInterval = 1,
	PlayerTeleportInterval = 0,
	PlayerTeleportOffset = CFrame.new(0, 0, 3),
	BoulderTeleportInterval = 0.1,
	BoulderTeleportOffset = Vector3.new(0, 0, 0),
	BoulderNoclipEnabled = true,
	SpeedHackSpeed = 250,
	SpeedHackDefaultSpeed = 30,
	BoulderEspMaxDistance = 50000,
	BoulderPromptInterval = 0,
	DigLoopInterval = 0.01,
	PrintStatus = true,
	FarmStart = false,
	PlayerTeleportStart = false,
	BoulderTeleportStart = false,
	BoulderEspStart = false,
	BoulderPromptStart = false,
	BoulderLevelFarmStart = false,
	BoulderHopStart = false,
	BoulderHopInterval = 1,
	BoulderHopEmptyDelay = 2,
	BoulderHopSort = "Asc",
	BoulderRejoinStart = false,
	BoulderLevelFarmLevel = "All",
	BoulderLevelFarmLevels = { "All" },
	BoulderLevelFarmUpDistance = 0,
	BoulderLevelFarmForwardDistance = 0,
	BoulderLevelFarmSpeed = 300,
	BoulderLevelFarmUnderOffset = 4,
	BoulderLevelFarmReturnDistance = 25,
	BoulderLevelFarmTweenInterval = 0.1,
	BoulderLevelFarmNextDelay = 2.2,
	PickaxeRecoverInterval = 1,
	DigReplayStart = false,
	NoclipStart = false,
	FloatStart = false,
	SpeedHackStart = false,
	InfiniteJumpStart = false,
	RuneItemNames = {},
	RuneDropAmount = 1,
	MoneyDropThresholdText = "",
	SelectedTeleportPlayerUserId = 0,
	SelectedTeleportPlayerName = "",
	SelectedBoulderName = "",
	SelectedDigBoulderName = "",
	Collapsed = false,
	GearShopBuyAll = false,
	GearShopAutoBuyEnabled = false,
	GearShopStartBuy = false,
	RadarShopBuyAll = false,
	RadarShopAutoBuyEnabled = false,
	RadarShopStartBuy = false
}

Config.GearShopConfigFile = ("CrystalTools_GearShop_%s.json"):format(tostring(LocalPlayer and LocalPlayer.UserId or "local"))
Config.ConfigFile = Config.GearShopConfigFile

do
	local function copyStringArray(value)
		local result = {}
		if type(value) ~= "table" then
			return result
		end

		for _, itemName in ipairs(value) do
			if itemName ~= nil then
				table.insert(result, tostring(itemName))
			end
		end

		return result
	end

	local function loadGearShopConfig()
		if type(readfile) ~= "function" or type(isfile) ~= "function" or not isfile(Config.GearShopConfigFile) then
			return nil
		end

		local ok, result = pcall(function()
			return game:GetService("HttpService"):JSONDecode(readfile(Config.GearShopConfigFile))
		end)

		if ok and type(result) == "table" then
			return result
		end

		return nil
	end

	local function applySavedConfig(savedConfig)
		if type(savedConfig) ~= "table" then
			return
		end

		local savedNames = copyStringArray(savedConfig.BombItemNames or savedConfig.GearItemNames)
		if type(savedConfig.BombItemNames) == "table" or type(savedConfig.GearItemNames) == "table" then
			Config.BombItemNames = savedNames
			Config.BombItemName = savedNames[1]
		end

		if type(savedConfig.RadarItemNames) == "table" or type(savedConfig.SelectedRadarItems) == "table" then
			Config.RadarItemNames = copyStringArray(savedConfig.RadarItemNames or savedConfig.SelectedRadarItems)
			Config.RadarItemName = Config.RadarItemNames[1]
		end

		if type(savedConfig.RuneItemNames) == "table" or type(savedConfig.SelectedRuneItems) == "table" then
			Config.RuneItemNames = copyStringArray(savedConfig.RuneItemNames or savedConfig.SelectedRuneItems)
		end

		if tonumber(savedConfig.FarmDistance) and tonumber(savedConfig.FarmDistance) > 0 then
			Config.FarmDistance = tonumber(savedConfig.FarmDistance)
		end
		if savedConfig.WeightEnabled ~= nil then
			Config.WeightEnabled = savedConfig.WeightEnabled == true
		end
		if savedConfig.MoneyEnabled ~= nil then
			Config.MoneyEnabled = savedConfig.MoneyEnabled == true
		end
		if savedConfig.LuckEnabled ~= nil then
			Config.LuckEnabled = savedConfig.LuckEnabled == true
		end
		if savedConfig.WeightMode ~= nil then
			Config.WeightMode = tostring(savedConfig.WeightMode):lower():find("below", 1, true) and "Below" or "Above"
		end
		if savedConfig.MoneyMode ~= nil then
			Config.MoneyMode = tostring(savedConfig.MoneyMode):lower():find("below", 1, true) and "Below" or "Above"
		end
		if savedConfig.LuckMode ~= nil then
			Config.LuckMode = tostring(savedConfig.LuckMode):lower():find("below", 1, true) and "Below" or "Above"
		end
		if savedConfig.WeightThreshold ~= nil then
			Config.WeightThreshold = savedConfig.WeightThreshold
		end
		if savedConfig.MoneyThreshold ~= nil then
			Config.MoneyThreshold = savedConfig.MoneyThreshold
		end
		if savedConfig.LuckThreshold ~= nil then
			Config.LuckThreshold = savedConfig.LuckThreshold
		end
		if tonumber(savedConfig.RuneDropAmount) and tonumber(savedConfig.RuneDropAmount) > 0 then
			Config.RuneDropAmount = math.floor(tonumber(savedConfig.RuneDropAmount))
		end
		if savedConfig.MoneyDropThresholdText ~= nil then
			Config.MoneyDropThresholdText = tostring(savedConfig.MoneyDropThresholdText)
		end
		if tonumber(savedConfig.SelectedTeleportPlayerUserId) then
			Config.SelectedTeleportPlayerUserId = tonumber(savedConfig.SelectedTeleportPlayerUserId)
		end
		if savedConfig.SelectedTeleportPlayerName ~= nil then
			Config.SelectedTeleportPlayerName = tostring(savedConfig.SelectedTeleportPlayerName)
		end
		if savedConfig.SelectedBoulderName ~= nil then
			Config.SelectedBoulderName = tostring(savedConfig.SelectedBoulderName)
		end
		if savedConfig.SelectedDigBoulderName ~= nil then
			Config.SelectedDigBoulderName = tostring(savedConfig.SelectedDigBoulderName)
		end
		if type(savedConfig.BoulderLevelFarmLevels) == "table" or type(savedConfig.SelectedBoulderLevels) == "table" then
			Config.BoulderLevelFarmLevels = copyStringArray(savedConfig.BoulderLevelFarmLevels or savedConfig.SelectedBoulderLevels)
			Config.BoulderLevelFarmLevel = Config.BoulderLevelFarmLevels[1] or "All"
		elseif savedConfig.BoulderLevelFarmLevel ~= nil then
			Config.BoulderLevelFarmLevel = tostring(savedConfig.BoulderLevelFarmLevel)
			Config.BoulderLevelFarmLevels = { Config.BoulderLevelFarmLevel }
		end
		if savedConfig.Collapsed ~= nil then
			Config.Collapsed = savedConfig.Collapsed == true
		end

		Config.FarmStart = savedConfig.FarmStart == true or savedConfig.Farming == true
		Config.PlayerTeleportStart = savedConfig.PlayerTeleportStart == true or savedConfig.PlayerTeleporting == true
		Config.BoulderTeleportStart = savedConfig.BoulderTeleportStart == true or savedConfig.BoulderTeleporting == true
		Config.BoulderEspStart = savedConfig.BoulderEspStart == true or savedConfig.BoulderEspEnabled == true
		Config.BoulderPromptStart = savedConfig.BoulderPromptStart == true or savedConfig.BoulderPromptEnabled == true
		Config.BoulderLevelFarmStart = savedConfig.BoulderLevelFarmStart == true or savedConfig.BoulderLevelFarmEnabled == true
		Config.BoulderHopStart = savedConfig.BoulderHopStart == true or savedConfig.BoulderHopEnabled == true
		Config.BoulderRejoinStart = savedConfig.BoulderRejoinStart == true or savedConfig.BoulderRejoinEnabled == true
		if savedConfig.BoulderHopSort ~= nil then
			Config.BoulderHopSort = tostring(savedConfig.BoulderHopSort)
		end
		if not _G.CrystalToolsLockedScriptUnlocked then
			Config.BoulderLevelFarmStart = false
			Config.BoulderHopStart = false
			Config.BoulderRejoinStart = false
		end
		Config.DigReplayStart = savedConfig.DigReplayStart == true or savedConfig.DigReplayEnabled == true
		Config.NoclipStart = savedConfig.NoclipStart == true or savedConfig.NoclipEnabled == true
		Config.FloatStart = savedConfig.FloatStart == true or savedConfig.Floating == true
		Config.SpeedHackStart = savedConfig.SpeedHackStart == true or savedConfig.SpeedHackEnabled == true
		Config.InfiniteJumpStart = savedConfig.InfiniteJumpStart == true or savedConfig.InfiniteJumpEnabled == true
		Config.GearShopBuyAll = savedConfig.GearShopBuyAll == true
		Config.GearShopStartBuy = savedConfig.GearShopStartBuy == true
			or savedConfig.StartBuy == true
			or savedConfig.GearShopAutoBuyEnabled == true
		Config.GearShopAutoBuyEnabled = Config.GearShopStartBuy
		Config.RadarShopBuyAll = savedConfig.RadarShopBuyAll == true
		Config.RadarShopStartBuy = savedConfig.RadarShopStartBuy == true
			or savedConfig.BuyRadarStart == true
			or savedConfig.RadarShopAutoBuyEnabled == true
		Config.RadarShopAutoBuyEnabled = Config.RadarShopStartBuy
	end

	applySavedConfig(loadGearShopConfig())
end

local function cleanupPreviousState(previousState)
	if not previousState then
		return
	end

	if type(previousState.Destroy) == "function" then
		pcall(function()
			previousState.Destroy()
		end)
	else
		if type(previousState.Stop) == "function" then
			pcall(function()
				previousState.Stop()
			end)
		end
		for _, connection in ipairs(previousState.Connections or {}) do
			pcall(function()
				connection:Disconnect()
			end)
		end
		if previousState.Gui then
			pcall(function()
				previousState.Gui:Destroy()
			end)
		end
	end
end

cleanupPreviousState(_G.CrystalToolsUI)
if _G.PlayerBackTPUI ~= _G.CrystalToolsUI then
	cleanupPreviousState(_G.PlayerBackTPUI)
end

local State = {
	Connections = {},
	LockedScriptUnlocked = _G.CrystalToolsLockedScriptUnlocked == true,
	Farming = false,
	Dropping = false,
	DroppingRunes = false,
	DroppingMoneyCrystals = false,
	BuyingBomb = false,
	GearShopBuyAll = Config.GearShopBuyAll == true,
	BuyingRadar = false,
	RadarShopBuyAll = Config.RadarShopBuyAll == true,
	PlayerTeleporting = false,
	BoulderTeleporting = false,
	BoulderEspEnabled = false,
	BoulderPromptEnabled = false,
	BoulderLevelFarmEnabled = false,
	BoulderLevelFarmThreadRunning = false,
	BoulderLevelFarmTarget = nil,
	BoulderLevelFarmTween = nil,
	BoulderHopEnabled = false,
	BoulderHopTeleporting = false,
	BoulderHopNoTargetSince = nil,
	BoulderRejoinEnabled = false,
	BoulderRejoining = false,
	BoulderRejoinNoTargetSince = nil,
	PickaxeShopNameSet = nil,
	PickaxeShopNameSetTick = 0,
	DigToolCache = nil,
	DigToolCacheTick = -1000000000,
	LastDigToolEquipAttemptTick = -1000000000,
	LastDigToolStatusTick = 0,
	LastWrongDigToolUnequipTick = 0,
	LastPickaxeRecoverTick = -1000000000,
	SelectedBoulderLevel = tostring(Config.BoulderLevelFarmLevel or "All"),
	SelectedBoulderLevels = {},
	NoclipEnabled = false,
	Floating = false,
	FloatHeight = nil,
	FloatCharacter = nil,
	FloatVelocity = nil,
	SpeedHackEnabled = false,
	SpeedHackHumanoid = nil,
	SpeedHackOriginalWalkSpeed = nil,
	InfiniteJumpEnabled = false,
	Collapsed = Config.Collapsed == true,
	SelectedBombItems = {},
	SelectedRadarItems = {},
	SelectedRuneItems = {},
	RuneDropAmount = tonumber(Config.RuneDropAmount) or 1,
	MoneyDropThresholdText = tostring(Config.MoneyDropThresholdText or ""),
	DigReplayEnabled = false,
	DigReplayThreadRunning = false,
	SelectedDigBoulderTarget = nil,
	SelectedDigBoulderName = tostring(Config.SelectedDigBoulderName or "") ~= "" and tostring(Config.SelectedDigBoulderName) or nil,
	SelectedTeleportPlayerUserId = tonumber(Config.SelectedTeleportPlayerUserId) and tonumber(Config.SelectedTeleportPlayerUserId) > 0 and tonumber(Config.SelectedTeleportPlayerUserId) or nil,
	SelectedTeleportPlayerName = tostring(Config.SelectedTeleportPlayerName or "") ~= "" and tostring(Config.SelectedTeleportPlayerName) or nil,
	SelectedBoulderTarget = nil,
	SelectedBoulderName = tostring(Config.SelectedBoulderName or "") ~= "" and tostring(Config.SelectedBoulderName) or nil,
	BoulderNoclipParts = {},
	LastFarmTick = 0,
	LastBuyBombTick = 0,
	LastBuyRadarTick = 0,
	LastPlayerTeleportTick = 0,
	LastBoulderTeleportTick = 0,
	LastBoulderPromptTick = 0,
	LastBoulderHopTick = 0,
	LastBoulderRejoinTick = 0,
	LastBuyBombStatus = nil,
	LastBuyRadarStatus = nil,
	RadarShopConfig = nil,
	RadarShopStockCache = {},
	LastRadarShopStockQuery = 0
}

_G.CrystalToolsUI = State
_G.PlayerBackTPUI = State
State.Config = Config

for _, bombName in ipairs(Config.BombItemNames or { Config.BombItemName }) do
	if bombName then
		State.SelectedBombItems[tostring(bombName)] = true
	end
end

for _, radarName in ipairs(Config.RadarItemNames or { Config.RadarItemName }) do
	if radarName then
		State.SelectedRadarItems[tostring(radarName)] = true
	end
end

for _, runeName in ipairs(Config.RuneItemNames or {}) do
	if runeName then
		State.SelectedRuneItems[tostring(runeName)] = true
	end
end

for _, levelName in ipairs(Config.BoulderLevelFarmLevels or { Config.BoulderLevelFarmLevel or "All" }) do
	if levelName and tostring(levelName) ~= "" then
		State.SelectedBoulderLevels[tostring(levelName)] = true
	end
end
if next(State.SelectedBoulderLevels) == nil then
	State.SelectedBoulderLevels.All = true
end

function State.SaveConfig()
	if type(writefile) ~= "function" then
		return false
	end

	local selectedGearNames = {}
	for itemName, selected in pairs(State.SelectedBombItems or {}) do
		if selected then
			table.insert(selectedGearNames, tostring(itemName))
		end
	end
	table.sort(selectedGearNames)

	local selectedRadarNames = {}
	for itemName, selected in pairs(State.SelectedRadarItems or {}) do
		if selected then
			table.insert(selectedRadarNames, tostring(itemName))
		end
	end
	table.sort(selectedRadarNames)

	local selectedRuneNames = {}
	for itemName, selected in pairs(State.SelectedRuneItems or {}) do
		if selected then
			table.insert(selectedRuneNames, tostring(itemName))
		end
	end
	table.sort(selectedRuneNames)

	local selectedBoulderLevels = {}
	for levelName, selected in pairs(State.SelectedBoulderLevels or {}) do
		if selected then
			table.insert(selectedBoulderLevels, tostring(levelName))
		end
	end
	table.sort(selectedBoulderLevels, function(left, right)
		local leftRank = State.GetBoulderLevelRankText and State.GetBoulderLevelRankText(left) or 0
		local rightRank = State.GetBoulderLevelRankText and State.GetBoulderLevelRankText(right) or 0
		if left == "All" then
			return true
		end
		if right == "All" then
			return false
		end
		if leftRank ~= rightRank then
			return leftRank > rightRank
		end
		return tostring(left):lower() < tostring(right):lower()
	end)
	if #selectedBoulderLevels == 0 then
		table.insert(selectedBoulderLevels, "All")
	end

	Config.BombItemNames = selectedGearNames
	Config.BombItemName = selectedGearNames[1]
	Config.RadarItemNames = selectedRadarNames
	Config.RadarItemName = selectedRadarNames[1]
	Config.RuneItemNames = selectedRuneNames
	Config.RuneDropAmount = State.RuneDropAmount or 1
	Config.MoneyDropThresholdText = State.MoneyDropThresholdText or ""
	Config.GearShopBuyAll = State.GearShopBuyAll == true
	Config.GearShopAutoBuyEnabled = State.BuyingBomb == true
	Config.GearShopStartBuy = State.BuyingBomb == true
	Config.RadarShopBuyAll = State.RadarShopBuyAll == true
	Config.RadarShopAutoBuyEnabled = State.BuyingRadar == true
	Config.RadarShopStartBuy = State.BuyingRadar == true
	Config.FarmStart = State.Farming == true
	Config.PlayerTeleportStart = State.PlayerTeleporting == true
	Config.BoulderTeleportStart = State.BoulderTeleporting == true
	Config.BoulderEspStart = State.BoulderEspEnabled == true
	Config.BoulderPromptStart = State.BoulderPromptEnabled == true
	Config.BoulderLevelFarmStart = State.BoulderLevelFarmEnabled == true
	Config.BoulderHopStart = State.BoulderHopEnabled == true
	Config.BoulderRejoinStart = State.BoulderRejoinEnabled == true
	Config.BoulderLevelFarmLevels = selectedBoulderLevels
	Config.BoulderLevelFarmLevel = selectedBoulderLevels[1] or "All"
	Config.DigReplayStart = State.DigReplayEnabled == true
	Config.NoclipStart = State.NoclipEnabled == true
	Config.FloatStart = State.Floating == true
	Config.SpeedHackStart = State.SpeedHackEnabled == true
	Config.InfiniteJumpStart = State.InfiniteJumpEnabled == true
	Config.Collapsed = State.Collapsed == true

	local data = {
		Version = 2,
		FarmDistance = Config.FarmDistance,
		FarmStart = Config.FarmStart,
		Farming = Config.FarmStart,
		WeightEnabled = Config.WeightEnabled == true,
		MoneyEnabled = Config.MoneyEnabled == true,
		LuckEnabled = Config.LuckEnabled == true,
		WeightMode = Config.WeightMode,
		MoneyMode = Config.MoneyMode,
		LuckMode = Config.LuckMode,
		WeightThreshold = Config.WeightThreshold,
		MoneyThreshold = Config.MoneyThreshold,
		LuckThreshold = Config.LuckThreshold,
		MoneyDropThresholdText = Config.MoneyDropThresholdText,
		RuneDropAmount = Config.RuneDropAmount,
		RuneItemNames = selectedRuneNames,
		SelectedRuneItems = selectedRuneNames,
		PlayerTeleportStart = Config.PlayerTeleportStart,
		PlayerTeleporting = Config.PlayerTeleportStart,
		SelectedTeleportPlayerUserId = State.SelectedTeleportPlayerUserId,
		SelectedTeleportPlayerName = State.SelectedTeleportPlayerName,
		BoulderTeleportStart = Config.BoulderTeleportStart,
		BoulderTeleporting = Config.BoulderTeleportStart,
		SelectedBoulderName = State.SelectedBoulderName,
		BoulderEspStart = Config.BoulderEspStart,
		BoulderEspEnabled = Config.BoulderEspStart,
		BoulderPromptStart = Config.BoulderPromptStart,
		BoulderPromptEnabled = Config.BoulderPromptStart,
		BoulderLevelFarmStart = Config.BoulderLevelFarmStart,
		BoulderLevelFarmEnabled = Config.BoulderLevelFarmStart,
		BoulderHopStart = Config.BoulderHopStart,
		BoulderHopEnabled = Config.BoulderHopStart,
		BoulderHopSort = Config.BoulderHopSort,
		BoulderRejoinStart = Config.BoulderRejoinStart,
		BoulderRejoinEnabled = Config.BoulderRejoinStart,
		BoulderLevelFarmLevel = Config.BoulderLevelFarmLevel,
		BoulderLevelFarmLevels = selectedBoulderLevels,
		SelectedBoulderLevels = selectedBoulderLevels,
		DigReplayStart = Config.DigReplayStart,
		DigReplayEnabled = Config.DigReplayStart,
		SelectedDigBoulderName = State.SelectedDigBoulderName,
		NoclipStart = Config.NoclipStart,
		NoclipEnabled = Config.NoclipStart,
		FloatStart = Config.FloatStart,
		Floating = Config.FloatStart,
		SpeedHackStart = Config.SpeedHackStart,
		SpeedHackEnabled = Config.SpeedHackStart,
		InfiniteJumpStart = Config.InfiniteJumpStart,
		InfiniteJumpEnabled = Config.InfiniteJumpStart,
		Collapsed = Config.Collapsed,
		GearShopBuyAll = State.GearShopBuyAll == true,
		GearShopAutoBuyEnabled = State.BuyingBomb == true,
		GearShopStartBuy = State.BuyingBomb == true,
		StartBuy = State.BuyingBomb == true,
		BombItemNames = selectedGearNames,
		GearItemNames = selectedGearNames,
		RadarShopBuyAll = State.RadarShopBuyAll == true,
		RadarShopAutoBuyEnabled = State.BuyingRadar == true,
		RadarShopStartBuy = State.BuyingRadar == true,
		BuyRadarStart = State.BuyingRadar == true,
		RadarItemNames = selectedRadarNames,
		SelectedRadarItems = selectedRadarNames
	}

	local ok = pcall(function()
		writefile(Config.ConfigFile or Config.GearShopConfigFile, game:GetService("HttpService"):JSONEncode(data))
	end)

	return ok
end

function State.SaveGearShopConfig()
	return State.SaveConfig()
end

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local CrystalDropRequest = Remotes and Remotes:FindFirstChild("CrystalDropRequest")
State.DigRequestRemote = Remotes and Remotes:FindFirstChild("DigRequest")
State.GoHomeRemote = Remotes and Remotes:FindFirstChild("GoHome")
local Networking
local BombShopConfig
local BombShopStockCache = {}
local LastBombShopStockQuery = 0

local function log(...)
	if Config.PrintStatus then
		print("[CrystalTools]", ...)
	end
end

local function connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(State.Connections, connection)
	return connection
end

function State.PackArgs(...)
	return {
		n = select("#", ...),
		...
	}
end

State.UnpackArgs = table.unpack or unpack

local function create(className, props, parent)
	local object = Instance.new(className)
	for key, value in pairs(props or {}) do
		object[key] = value
	end
	object.Parent = parent
	return object
end

local function styleSurface(instance, radius, strokeColor, strokeTransparency, strokeThickness)
	create("UICorner", { CornerRadius = UDim.new(0, radius or 7) }, instance)
	if strokeColor then
		create("UIStroke", {
			Color = strokeColor,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Transparency = strokeTransparency or 0.35,
			Thickness = strokeThickness or 1
		}, instance)
	end
	return instance
end

local Theme = {
	Background = Color3.fromRGB(3, 7, 17),
	Panel = Color3.fromRGB(7, 14, 30),
	PanelAlt = Color3.fromRGB(10, 22, 45),
	Field = Color3.fromRGB(8, 18, 36),
	FieldStroke = Color3.fromRGB(32, 148, 255),
	RowStroke = Color3.fromRGB(19, 82, 145),
	Button = Color3.fromRGB(9, 74, 136),
	ButtonDark = Color3.fromRGB(20, 34, 54),
	Accent = Color3.fromRGB(92, 214, 255),
	GlowSoft = Color3.fromRGB(20, 113, 194),
	Text = Color3.fromRGB(255, 255, 255),
	Muted = Color3.fromRGB(255, 255, 255),
	Good = Color3.fromRGB(80, 225, 170),
	Bad = Color3.fromRGB(255, 118, 118)
}

local function getViewportSize()
	local camera = Workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local ok, topLeftInset, bottomRightInset = pcall(function()
		return GuiService:GetGuiInset()
	end)

	if ok and typeof(topLeftInset) == "Vector2" and typeof(bottomRightInset) == "Vector2" then
		viewport = Vector2.new(
			math.max(1, viewport.X - topLeftInset.X - bottomRightInset.X),
			math.max(1, viewport.Y - topLeftInset.Y - bottomRightInset.Y)
		)
	end

	return viewport
end

local function shouldUseMobileLayout(viewport)
	return UserInputService.TouchEnabled or viewport.X <= 720 or viewport.Y <= 560
end

local function getCharacterParts(player)
	local character = player and player.Character
	if not character then
		return nil, nil, nil
	end

	local root = character:FindFirstChild("HumanoidRootPart")
		or character.PrimaryPart
		or character:FindFirstChildWhichIsA("BasePart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if root and not character.PrimaryPart then
		pcall(function()
			character.PrimaryPart = root
		end)
	end

	return character, root, humanoid
end

local UI = {}
local DESKTOP_HEADER_HEIGHT = 42
local MOBILE_HEADER_HEIGHT = 40
local CONTENT_HEIGHT = 2120
local HORIZONTAL_CONTENT_HEIGHT = 920
local DESKTOP_COLLAPSED_WIDTH = 390
local MOBILE_COLLAPSED_WIDTH = 300

local Gui = create("ScreenGui", {
	Name = "CrystalTools_NewUI",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, LocalPlayer:WaitForChild("PlayerGui"))
State.Gui = Gui
pcall(function()
	Gui.IgnoreGuiInset = false
end)
pcall(function()
	Gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
end)

local Main = create("Frame", {
	Name = "Main",
	Position = UDim2.new(0, 22, 0, 112),
	Size = UDim2.new(0, 700, 0, DESKTOP_HEADER_HEIGHT + HORIZONTAL_CONTENT_HEIGHT),
	BackgroundColor3 = Theme.Background,
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	Active = true,
	ClipsDescendants = true
}, Gui)
styleSurface(Main, 6, Theme.Accent, 0.14, 1.5)
UI.Main = Main
UI.ExpandedSize = Main.Size
UI.CollapsedSize = UDim2.new(0, 700, 0, DESKTOP_HEADER_HEIGHT)
UI.ExpandedPixelSize = Vector2.new(700, DESKTOP_HEADER_HEIGHT + HORIZONTAL_CONTENT_HEIGHT)
UI.CollapsedPixelSize = Vector2.new(700, DESKTOP_HEADER_HEIGHT)

create("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 12, 28)),
		ColorSequenceKeypoint.new(1, Theme.Background)
	}),
	Rotation = 90
}, Main)

local Header = create("Frame", {
	Name = "Header",
	Size = UDim2.new(1, 0, 0, DESKTOP_HEADER_HEIGHT),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	Active = true
}, Main)
styleSurface(Header, 6, Theme.GlowSoft, 0.55, 1)
UI.Header = Header
create("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Theme.PanelAlt),
		ColorSequenceKeypoint.new(1, Theme.Panel)
	}),
	Rotation = 0
}, Header)

local HeaderTitle = create("TextLabel", {
	Position = UDim2.new(0, 16, 0, 0),
	Size = UDim2.new(1, -108, 1, 0),
	BackgroundTransparency = 1,
	Text = "BENJAMINX | Mine a Mountain",
	TextColor3 = Theme.Text,
	TextSize = 15,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd
}, Header)

local CollapseButton = create("TextButton", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -44, 0.5, 0),
	Size = UDim2.new(0, 30, 0, 24),
	BackgroundColor3 = Theme.ButtonDark,
	BorderSizePixel = 0,
	Text = "-",
	TextColor3 = Theme.Text,
	TextSize = 15,
	Font = Enum.Font.GothamBold
}, Header)
styleSurface(CollapseButton, 8, Theme.GlowSoft, 0.35, 1)
UI.CollapseButton = CollapseButton

local CloseButton = create("TextButton", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -8, 0.5, 0),
	Size = UDim2.new(0, 30, 0, 24),
	BackgroundColor3 = Theme.ButtonDark,
	BorderSizePixel = 0,
	Text = "X",
	TextColor3 = Theme.Text,
	TextSize = 13,
	Font = Enum.Font.GothamBold
}, Header)
styleSurface(CloseButton, 8, Theme.GlowSoft, 0.35, 1)

local Content = create("ScrollingFrame", {
	Name = "Content",
	Position = UDim2.new(0, 0, 0, DESKTOP_HEADER_HEIGHT),
	Size = UDim2.new(1, 0, 1, -DESKTOP_HEADER_HEIGHT),
	BackgroundColor3 = Theme.Background,
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(0, 0, 0, CONTENT_HEIGHT),
	ScrollBarThickness = 5,
	ScrollBarImageColor3 = Theme.Accent,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	ElasticBehavior = Enum.ElasticBehavior.Never,
	Active = true
}, Main)
UI.Content = Content

styleSurface(create("Frame", {
	Name = "HeaderAccent",
	Position = UDim2.new(0, 14, 1, -3),
	Size = UDim2.new(1, -28, 0, 2),
	BackgroundColor3 = Theme.GlowSoft,
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	ZIndex = 3
}, Header), 2)

local CrystalFarmLabel = create("TextLabel", {
	Position = UDim2.new(0, 14, 0, 14),
	Size = UDim2.new(1, -28, 0, 18),
	BackgroundTransparency = 1,
	Text = "Crystal filters",
	TextColor3 = Theme.Muted,
	TextSize = 12,
	Font = Enum.Font.GothamMedium,
	TextXAlignment = Enum.TextXAlignment.Left
}, Content)

local FilterTypeButton = create("TextButton", {
	Position = UDim2.new(0, 14, 0, 38),
	Size = UDim2.new(1, -28, 0, 30),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	Text = "Weight",
	TextColor3 = Theme.Text,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left
}, Content)
styleSurface(FilterTypeButton, 6, Theme.Accent)
create("UIPadding", {
	PaddingLeft = UDim.new(0, 8),
	PaddingRight = UDim.new(0, 8)
}, FilterTypeButton)
UI.FilterTypeButton = FilterTypeButton

local WeightModeButton = create("TextButton", {
	Position = UDim2.new(0, 14, 0, 74),
	Size = UDim2.new(1, -28, 0, 30),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	Text = "Above",
	TextColor3 = Theme.Text,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left
}, Content)
styleSurface(WeightModeButton, 6, Theme.Accent)
create("UIPadding", {
	PaddingLeft = UDim.new(0, 8),
	PaddingRight = UDim.new(0, 8)
}, WeightModeButton)
UI.WeightModeButton = WeightModeButton

local WeightInput = create("TextBox", {
	Position = UDim2.new(0, 14, 0, 110),
	Size = UDim2.new(1, -28, 0, 30),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	ClearTextOnFocus = false,
	Text = tostring(Config.WeightThreshold),
	PlaceholderText = "kg",
	TextColor3 = Theme.Text,
	PlaceholderColor3 = Theme.Muted,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Center
}, Content)
styleSurface(WeightInput, 6, Theme.Accent)
UI.WeightInput = WeightInput

local MoneyToggleButton = create("TextButton", {
	Position = UDim2.new(0, 14, 0, 146),
	Size = UDim2.new(1, -28, 0, 30),
	BackgroundColor3 = Theme.ButtonDark,
	BorderSizePixel = 0,
	Text = "Money",
	TextColor3 = Theme.Text,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left
}, Content)
styleSurface(MoneyToggleButton, 6, Theme.Accent)
create("UIPadding", {
	PaddingLeft = UDim.new(0, 8),
	PaddingRight = UDim.new(0, 8)
}, MoneyToggleButton)
UI.MoneyToggleButton = MoneyToggleButton

local MoneyModeButton = create("TextButton", {
	Position = UDim2.new(0, 14, 0, 182),
	Size = UDim2.new(1, -28, 0, 30),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	Text = "Above",
	TextColor3 = Theme.Text,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left
}, Content)
styleSurface(MoneyModeButton, 6, Theme.Accent)
create("UIPadding", {
	PaddingLeft = UDim.new(0, 8),
	PaddingRight = UDim.new(0, 8)
}, MoneyModeButton)
UI.MoneyModeButton = MoneyModeButton

local MoneyInput = create("TextBox", {
	Position = UDim2.new(0, 14, 0, 218),
	Size = UDim2.new(1, -28, 0, 30),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	ClearTextOnFocus = false,
	Text = tostring(Config.MoneyThreshold),
	PlaceholderText = "$",
	TextColor3 = Theme.Text,
	PlaceholderColor3 = Theme.Muted,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Center
}, Content)
styleSurface(MoneyInput, 6, Theme.Accent)
UI.MoneyInput = MoneyInput

local LuckToggleButton = create("TextButton", {
	Position = UDim2.new(0, 14, 0, 258),
	Size = UDim2.new(1, -28, 0, 30),
	BackgroundColor3 = Theme.ButtonDark,
	BorderSizePixel = 0,
	Text = "Luck",
	TextColor3 = Theme.Text,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left
}, Content)
styleSurface(LuckToggleButton, 6, Theme.Accent)
create("UIPadding", {
	PaddingLeft = UDim.new(0, 8),
	PaddingRight = UDim.new(0, 8)
}, LuckToggleButton)
UI.LuckToggleButton = LuckToggleButton

local LuckModeButton = create("TextButton", {
	Position = UDim2.new(0, 14, 0, 294),
	Size = UDim2.new(1, -28, 0, 30),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	Text = "Above",
	TextColor3 = Theme.Text,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left
}, Content)
styleSurface(LuckModeButton, 6, Theme.Accent)
create("UIPadding", {
	PaddingLeft = UDim.new(0, 8),
	PaddingRight = UDim.new(0, 8)
}, LuckModeButton)
UI.LuckModeButton = LuckModeButton

local LuckInput = create("TextBox", {
	Position = UDim2.new(0, 14, 0, 330),
	Size = UDim2.new(1, -28, 0, 30),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	ClearTextOnFocus = false,
	Text = tostring(Config.LuckThreshold),
	PlaceholderText = "luck",
	TextColor3 = Theme.Text,
	PlaceholderColor3 = Theme.Muted,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Center
}, Content)
styleSurface(LuckInput, 6, Theme.Accent)
UI.LuckInput = LuckInput

UI.FarmDistanceInput = create("TextBox", {
	Position = UDim2.new(0, 14, 0, 370),
	Size = UDim2.new(1 / 2, -19, 0, 34),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	ClearTextOnFocus = false,
	Text = tostring(Config.FarmDistance or 100),
	PlaceholderText = "stud",
	TextColor3 = Theme.Text,
	PlaceholderColor3 = Theme.Muted,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Center
}, Content)
styleSurface(UI.FarmDistanceInput, 6, Theme.Accent)

local FilterTypeList = create("Frame", {
	Position = UDim2.new(0, 14, 0, 72),
	Size = UDim2.new(0.5, -18, 0, 64),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	Visible = false,
	ZIndex = 5
}, Content)
styleSurface(FilterTypeList, 6, Theme.Accent)
UI.FilterTypeList = FilterTypeList

local WeightFilterButton = create("TextButton", {
	Position = UDim2.new(0, 6, 0, 6),
	Size = UDim2.new(1, -12, 0, 24),
	BackgroundColor3 = Theme.Button,
	BorderSizePixel = 0,
	Text = "Weight",
	TextColor3 = Theme.Text,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	ZIndex = 6
}, FilterTypeList)
styleSurface(WeightFilterButton, 5, Theme.Accent)

local MoneyFilterButton = create("TextButton", {
	Position = UDim2.new(0, 6, 0, 34),
	Size = UDim2.new(1, -12, 0, 24),
	BackgroundColor3 = Theme.ButtonDark,
	BorderSizePixel = 0,
	Text = "Money",
	TextColor3 = Theme.Text,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	ZIndex = 6
}, FilterTypeList)
styleSurface(MoneyFilterButton, 5, Theme.Accent)

local WeightModeList = create("Frame", {
	Position = UDim2.new(0.5, 4, 0, 72),
	Size = UDim2.new(0.5, -18, 0, 64),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	Visible = false,
	ZIndex = 5
}, Content)
styleSurface(WeightModeList, 6, Theme.Accent)
UI.WeightModeList = WeightModeList

local AboveButton = create("TextButton", {
	Position = UDim2.new(0, 6, 0, 6),
	Size = UDim2.new(1, -12, 0, 24),
	BackgroundColor3 = Theme.ButtonDark,
	BorderSizePixel = 0,
	Text = "Above",
	TextColor3 = Theme.Text,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	ZIndex = 6
}, WeightModeList)
styleSurface(AboveButton, 5, Theme.Accent)

local BelowButton = create("TextButton", {
	Position = UDim2.new(0, 6, 0, 34),
	Size = UDim2.new(1, -12, 0, 24),
	BackgroundColor3 = Theme.ButtonDark,
	BorderSizePixel = 0,
	Text = "Below",
	TextColor3 = Theme.Text,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	ZIndex = 6
}, WeightModeList)
styleSurface(BelowButton, 5, Theme.Accent)

local FarmButton = create("TextButton", {
	Position = UDim2.new(1 / 2, 5, 0, 370),
	Size = UDim2.new(1 / 2, -19, 0, 34),
	BackgroundColor3 = Theme.Button,
	BorderSizePixel = 0,
	Text = "Start Farm",
	TextColor3 = Theme.Text,
	TextSize = 14,
	Font = Enum.Font.GothamBold
}, Content)
styleSurface(FarmButton, 6, Theme.Accent)
UI.FarmButton = FarmButton

local CrystalActionsLabel = create("TextLabel", {
	Position = UDim2.new(0, 14, 0, 420),
	Size = UDim2.new(1, -28, 0, 18),
	BackgroundTransparency = 1,
	Text = "Crystal actions",
	TextColor3 = Theme.Muted,
	TextSize = 12,
	Font = Enum.Font.GothamMedium,
	TextXAlignment = Enum.TextXAlignment.Left
}, Content)

local DropAllButton = create("TextButton", {
	Position = UDim2.new(0, 14, 0, 444),
	Size = UDim2.new(1, -28, 0, 34),
	BackgroundColor3 = Theme.ButtonDark,
	BorderSizePixel = 0,
	Text = "Drop All Backpack",
	TextColor3 = Theme.Text,
	TextSize = 14,
	Font = Enum.Font.GothamBold
}, Content)
styleSurface(DropAllButton, 6, Theme.Accent)
UI.DropAllButton = DropAllButton

UI.MoneyDropLabel = create("TextLabel", {
	Position = UDim2.new(0, 14, 0, 494),
	Size = UDim2.new(1, -28, 0, 18),
	BackgroundTransparency = 1,
	Text = "Money drop",
	TextColor3 = Theme.Muted,
	TextSize = 12,
	Font = Enum.Font.GothamMedium,
	TextXAlignment = Enum.TextXAlignment.Left
}, Content)

UI.MoneyDropInput = create("TextBox", {
	Position = UDim2.new(0, 14, 0, 518),
	Size = UDim2.new(1 / 2, -19, 0, 34),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	Text = tostring(Config.MoneyDropThresholdText or ""),
	PlaceholderText = "",
	ClearTextOnFocus = false,
	TextColor3 = Theme.Text,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left
}, Content)
styleSurface(UI.MoneyDropInput, 6, Theme.Accent)
create("UIPadding", {
	PaddingLeft = UDim.new(0, 8),
	PaddingRight = UDim.new(0, 8)
}, UI.MoneyDropInput)

UI.DropMoneyButton = create("TextButton", {
	Position = UDim2.new(1 / 2, 5, 0, 518),
	Size = UDim2.new(1 / 2, -19, 0, 34),
	BackgroundColor3 = Theme.Button,
	BorderSizePixel = 0,
	Text = "Drop Crystal",
	TextColor3 = Theme.Text,
	TextSize = 14,
	Font = Enum.Font.GothamBold
}, Content)
styleSurface(UI.DropMoneyButton, 6, Theme.Accent)

UI.RuneDropLabel = create("TextLabel", {
	Position = UDim2.new(0, 14, 0, 568),
	Size = UDim2.new(1, -28, 0, 18),
	BackgroundTransparency = 1,
	Text = "Rune drop",
	TextColor3 = Theme.Muted,
	TextSize = 12,
	Font = Enum.Font.GothamMedium,
	TextXAlignment = Enum.TextXAlignment.Left
}, Content)

UI.RuneDropdownButton = create("TextButton", {
	Position = UDim2.new(0, 14, 0, 592),
	Size = UDim2.new(1, -28, 0, 32),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	Text = "Select Rune",
	TextColor3 = Theme.Text,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd
}, Content)
styleSurface(UI.RuneDropdownButton, 6, Theme.Accent)
create("UIPadding", {
	PaddingLeft = UDim.new(0, 8),
	PaddingRight = UDim.new(0, 8)
}, UI.RuneDropdownButton)

UI.RuneDropdownList = create("ScrollingFrame", {
	Position = UDim2.new(0, 14, 0, 630),
	Size = UDim2.new(1, -28, 0, 102),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	ScrollBarThickness = 4,
	ScrollBarImageColor3 = Theme.Accent,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	ElasticBehavior = Enum.ElasticBehavior.Never,
	Visible = false,
	ZIndex = 7
}, Content)
styleSurface(UI.RuneDropdownList, 6, Theme.Accent)
create("UIPadding", {
	PaddingTop = UDim.new(0, 6),
	PaddingLeft = UDim.new(0, 6),
	PaddingRight = UDim.new(0, 6),
	PaddingBottom = UDim.new(0, 6)
}, UI.RuneDropdownList)
UI.RuneDropdownLayout = create("UIListLayout", {
	Padding = UDim.new(0, 4),
	SortOrder = Enum.SortOrder.LayoutOrder
}, UI.RuneDropdownList)

UI.RuneAmountInput = create("TextBox", {
	Position = UDim2.new(0, 14, 0, 744),
	Size = UDim2.new(1 / 2, -19, 0, 34),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	Text = tostring(Config.RuneDropAmount or 1),
	PlaceholderText = "Amount",
	ClearTextOnFocus = false,
	TextColor3 = Theme.Text,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left
}, Content)
styleSurface(UI.RuneAmountInput, 6, Theme.Accent)
create("UIPadding", {
	PaddingLeft = UDim.new(0, 8),
	PaddingRight = UDim.new(0, 8)
}, UI.RuneAmountInput)

UI.DropRuneButton = create("TextButton", {
	Position = UDim2.new(1 / 2, 5, 0, 744),
	Size = UDim2.new(1 / 2, -19, 0, 34),
	BackgroundColor3 = Theme.Button,
	BorderSizePixel = 0,
	Text = "Drop Rune",
	TextColor3 = Theme.Text,
	TextSize = 14,
	Font = Enum.Font.GothamBold
}, Content)
styleSurface(UI.DropRuneButton, 6, Theme.Accent)

UI.DigReplayButton = create("TextButton", {
	Position = UDim2.new(0, 14, 0, 794),
	Size = UDim2.new(1 / 2, -19, 0, 34),
	BackgroundColor3 = Theme.Button,
	BorderSizePixel = 0,
	Text = "DIG LOOP OFF",
	TextColor3 = Theme.Text,
	TextSize = 14,
	Font = Enum.Font.GothamBold
}, Content)
styleSurface(UI.DigReplayButton, 6, Theme.Accent)

UI.DigBoulderDropdownButton = create("TextButton", {
	Position = UDim2.new(1 / 2, 5, 0, 794),
	Size = UDim2.new(1 / 2, -19, 0, 34),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	Text = "Select Dig Boulder",
	TextColor3 = Theme.Text,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd
}, Content)
styleSurface(UI.DigBoulderDropdownButton, 6, Theme.Accent)
create("UIPadding", {
	PaddingLeft = UDim.new(0, 8),
	PaddingRight = UDim.new(0, 8)
}, UI.DigBoulderDropdownButton)

UI.DigBoulderDropdownList = create("ScrollingFrame", {
	Position = UDim2.new(0, 14, 0, 836),
	Size = UDim2.new(1, -28, 0, 102),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	ScrollBarThickness = 4,
	ScrollBarImageColor3 = Theme.Accent,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	ElasticBehavior = Enum.ElasticBehavior.Never,
	Visible = false,
	ZIndex = 7
}, Content)
styleSurface(UI.DigBoulderDropdownList, 6, Theme.Accent)
create("UIPadding", {
	PaddingTop = UDim.new(0, 6),
	PaddingLeft = UDim.new(0, 6),
	PaddingRight = UDim.new(0, 6),
	PaddingBottom = UDim.new(0, 6)
}, UI.DigBoulderDropdownList)
UI.DigBoulderDropdownLayout = create("UIListLayout", {
	Padding = UDim.new(0, 4),
	SortOrder = Enum.SortOrder.LayoutOrder
}, UI.DigBoulderDropdownList)

UI.BoulderLevelFarmLabel = create("TextLabel", {
	Position = UDim2.new(0, 14, 0, 954),
	Size = UDim2.new(1, -28, 0, 18),
	BackgroundTransparency = 1,
	Text = "Auto Farm Rune",
	TextColor3 = Theme.Muted,
	TextSize = 12,
	Font = Enum.Font.GothamMedium,
	TextXAlignment = Enum.TextXAlignment.Left
}, Content)

UI.BoulderLevelDropdownButton = create("TextButton", {
	Position = UDim2.new(0, 14, 0, 978),
	Size = UDim2.new(1 / 2, -19, 0, 34),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	Text = "Level: All",
	TextColor3 = Theme.Text,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd
}, Content)
styleSurface(UI.BoulderLevelDropdownButton, 6, Theme.Accent)
create("UIPadding", {
	PaddingLeft = UDim.new(0, 8),
	PaddingRight = UDim.new(0, 8)
}, UI.BoulderLevelDropdownButton)

UI.BoulderLevelFarmButton = create("TextButton", {
	Position = UDim2.new(1 / 2, 5, 0, 978),
	Size = UDim2.new(1 / 2, -19, 0, 34),
	BackgroundColor3 = Theme.ButtonDark,
	BorderSizePixel = 0,
	Text = "LEVEL FARM OFF",
	TextColor3 = Theme.Text,
	TextSize = 12,
	Font = Enum.Font.GothamBold
}, Content)
styleSurface(UI.BoulderLevelFarmButton, 6, Theme.Accent)

UI.BoulderLevelDropdownList = create("ScrollingFrame", {
	Position = UDim2.new(0, 14, 0, 1018),
	Size = UDim2.new(1, -28, 0, 102),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	ScrollBarThickness = 4,
	ScrollBarImageColor3 = Theme.Accent,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	ElasticBehavior = Enum.ElasticBehavior.Never,
	Visible = false,
	ZIndex = 7
}, Content)
styleSurface(UI.BoulderLevelDropdownList, 6, Theme.Accent)
create("UIPadding", {
	PaddingTop = UDim.new(0, 6),
	PaddingLeft = UDim.new(0, 6),
	PaddingRight = UDim.new(0, 6),
	PaddingBottom = UDim.new(0, 6)
}, UI.BoulderLevelDropdownList)
UI.BoulderLevelDropdownLayout = create("UIListLayout", {
	Padding = UDim.new(0, 4),
	SortOrder = Enum.SortOrder.LayoutOrder
}, UI.BoulderLevelDropdownList)

local PlayerTPLabel = create("TextLabel", {
	Position = UDim2.new(0, 14, 0, 1006),
	Size = UDim2.new(1, -28, 0, 18),
	BackgroundTransparency = 1,
	Text = "Player TP",
	TextColor3 = Theme.Muted,
	TextSize = 12,
	Font = Enum.Font.GothamMedium,
	TextXAlignment = Enum.TextXAlignment.Left
}, Content)

local PlayerDropdownButton = create("TextButton", {
	Position = UDim2.new(0, 14, 0, 558),
	Size = UDim2.new(1, -28, 0, 32),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	Text = "Select player",
	TextColor3 = Theme.Text,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd
}, Content)
styleSurface(PlayerDropdownButton, 6, Theme.Accent)
create("UIPadding", {
	PaddingLeft = UDim.new(0, 8),
	PaddingRight = UDim.new(0, 8)
}, PlayerDropdownButton)
UI.PlayerDropdownButton = PlayerDropdownButton

local PlayerDropdownList = create("ScrollingFrame", {
	Position = UDim2.new(0, 14, 0, 596),
	Size = UDim2.new(1, -28, 0, 102),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	ScrollBarThickness = 4,
	ScrollBarImageColor3 = Theme.Accent,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	ElasticBehavior = Enum.ElasticBehavior.Never,
	Visible = false,
	ZIndex = 7
}, Content)
styleSurface(PlayerDropdownList, 6, Theme.Accent)
create("UIPadding", {
	PaddingTop = UDim.new(0, 6),
	PaddingLeft = UDim.new(0, 6),
	PaddingRight = UDim.new(0, 6),
	PaddingBottom = UDim.new(0, 6)
}, PlayerDropdownList)
local PlayerDropdownLayout = create("UIListLayout", {
	Padding = UDim.new(0, 4),
	SortOrder = Enum.SortOrder.LayoutOrder
}, PlayerDropdownList)
UI.PlayerDropdownList = PlayerDropdownList
UI.PlayerDropdownLayout = PlayerDropdownLayout

local PlayerTeleportButton = create("TextButton", {
	Position = UDim2.new(0, 14, 0, 710),
	Size = UDim2.new(1, -28, 0, 34),
	BackgroundColor3 = Theme.Button,
	BorderSizePixel = 0,
	Text = "Start TP",
	TextColor3 = Theme.Text,
	TextSize = 14,
	Font = Enum.Font.GothamBold
}, Content)
styleSurface(PlayerTeleportButton, 6, Theme.Accent)
UI.PlayerTeleportButton = PlayerTeleportButton

local BoulderTPLabel = create("TextLabel", {
	Position = UDim2.new(0, 14, 0, 760),
	Size = UDim2.new(1, -28, 0, 18),
	BackgroundTransparency = 1,
	Text = "Boulder TP",
	TextColor3 = Theme.Muted,
	TextSize = 12,
	Font = Enum.Font.GothamMedium,
	TextXAlignment = Enum.TextXAlignment.Left
}, Content)

local BoulderDropdownButton = create("TextButton", {
	Position = UDim2.new(0, 14, 0, 784),
	Size = UDim2.new(1, -28, 0, 32),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	Text = "Select boulder",
	TextColor3 = Theme.Text,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd
}, Content)
styleSurface(BoulderDropdownButton, 6, Theme.Accent)
create("UIPadding", {
	PaddingLeft = UDim.new(0, 8),
	PaddingRight = UDim.new(0, 8)
}, BoulderDropdownButton)
UI.BoulderDropdownButton = BoulderDropdownButton

local BoulderDropdownList = create("ScrollingFrame", {
	Position = UDim2.new(0, 14, 0, 822),
	Size = UDim2.new(1, -28, 0, 102),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	ScrollBarThickness = 4,
	ScrollBarImageColor3 = Theme.Accent,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	ElasticBehavior = Enum.ElasticBehavior.Never,
	Visible = false,
	ZIndex = 7
}, Content)
styleSurface(BoulderDropdownList, 6, Theme.Accent)
create("UIPadding", {
	PaddingTop = UDim.new(0, 6),
	PaddingLeft = UDim.new(0, 6),
	PaddingRight = UDim.new(0, 6),
	PaddingBottom = UDim.new(0, 6)
}, BoulderDropdownList)
local BoulderDropdownLayout = create("UIListLayout", {
	Padding = UDim.new(0, 4),
	SortOrder = Enum.SortOrder.LayoutOrder
}, BoulderDropdownList)
UI.BoulderDropdownList = BoulderDropdownList
UI.BoulderDropdownLayout = BoulderDropdownLayout

local BoulderTeleportButton = create("TextButton", {
	Position = UDim2.new(0, 14, 0, 936),
	Size = UDim2.new(1 / 4, -13, 0, 34),
	BackgroundColor3 = Theme.Button,
	BorderSizePixel = 0,
	Text = "Start Boulder TP",
	TextColor3 = Theme.Text,
	TextSize = 11,
	Font = Enum.Font.GothamBold
}, Content)
styleSurface(BoulderTeleportButton, 6, Theme.Accent)
UI.BoulderTeleportButton = BoulderTeleportButton

UI.BoulderNoclipButton = create("TextButton", {
	Position = UDim2.new(1 / 4, 9, 0, 936),
	Size = UDim2.new(1 / 4, -13, 0, 34),
	BackgroundColor3 = Theme.ButtonDark,
	BorderSizePixel = 0,
	Text = "NC OFF",
	TextColor3 = Theme.Text,
	TextSize = 11,
	Font = Enum.Font.GothamBold
}, Content)
styleSurface(UI.BoulderNoclipButton, 6, Theme.Accent)

local BoulderEspButton = create("TextButton", {
	Position = UDim2.new(1 / 2, 4, 0, 936),
	Size = UDim2.new(1 / 4, -13, 0, 34),
	BackgroundColor3 = Theme.ButtonDark,
	BorderSizePixel = 0,
	Text = "ESP OFF",
	TextColor3 = Theme.Text,
	TextSize = 11,
	Font = Enum.Font.GothamBold
}, Content)
styleSurface(BoulderEspButton, 6, Theme.Accent)
UI.BoulderEspButton = BoulderEspButton

local BoulderPromptButton = create("TextButton", {
	Position = UDim2.new(3 / 4, -1, 0, 936),
	Size = UDim2.new(1 / 4, -13, 0, 34),
	BackgroundColor3 = Theme.ButtonDark,
	BorderSizePixel = 0,
	Text = "RUNE OFF",
	TextColor3 = Theme.Text,
	TextSize = 11,
	Font = Enum.Font.GothamBold
}, Content)
styleSurface(BoulderPromptButton, 6, Theme.Accent)
UI.BoulderPromptButton = BoulderPromptButton

UI.BoulderHopButton = create("TextButton", {
	Position = UDim2.new(4 / 5, -6, 0, 936),
	Size = UDim2.new(1 / 5, -12, 0, 34),
	BackgroundColor3 = Theme.ButtonDark,
	BorderSizePixel = 0,
	Text = "HOP OFF",
	TextColor3 = Theme.Text,
	TextSize = 11,
	Font = Enum.Font.GothamBold
}, Content)
styleSurface(UI.BoulderHopButton, 6, Theme.Accent)

UI.BoulderRejoinButton = create("TextButton", {
	Position = UDim2.new(5 / 6, -6, 0, 936),
	Size = UDim2.new(1 / 6, -10, 0, 34),
	BackgroundColor3 = Theme.ButtonDark,
	BorderSizePixel = 0,
	Text = "RJ OFF",
	TextColor3 = Theme.Text,
	TextSize = 10,
	Font = Enum.Font.GothamBold
}, Content)
styleSurface(UI.BoulderRejoinButton, 6, Theme.Accent)

UI.FloatButton = create("TextButton", {
	Position = UDim2.new(0, 14, 0, 976),
	Size = UDim2.new(1 / 3, -16, 0, 34),
	BackgroundColor3 = Theme.ButtonDark,
	BorderSizePixel = 0,
	Text = "FLOAT OFF",
	TextColor3 = Theme.Text,
	TextSize = 12,
	Font = Enum.Font.GothamBold
}, Content)
styleSurface(UI.FloatButton, 6, Theme.Accent)

UI.SpeedButton = create("TextButton", {
	Position = UDim2.new(1 / 3, 4, 0, 976),
	Size = UDim2.new(1 / 3, -16, 0, 34),
	BackgroundColor3 = Theme.ButtonDark,
	BorderSizePixel = 0,
	Text = "SPEED OFF",
	TextColor3 = Theme.Text,
	TextSize = 12,
	Font = Enum.Font.GothamBold
}, Content)
styleSurface(UI.SpeedButton, 6, Theme.Accent)

UI.InfiniteJumpButton = create("TextButton", {
	Position = UDim2.new(2 / 3, -6, 0, 976),
	Size = UDim2.new(1 / 3, -16, 0, 34),
	BackgroundColor3 = Theme.ButtonDark,
	BorderSizePixel = 0,
	Text = "JUMP OFF",
	TextColor3 = Theme.Text,
	TextSize = 12,
	Font = Enum.Font.GothamBold
}, Content)
styleSurface(UI.InfiniteJumpButton, 6, Theme.Accent)

local GearShopLabel = create("TextLabel", {
	Position = UDim2.new(0, 14, 0, 1026),
	Size = UDim2.new(1, -28, 0, 18),
	BackgroundTransparency = 1,
	Text = "Gear shop",
	TextColor3 = Theme.Muted,
	TextSize = 12,
	Font = Enum.Font.GothamMedium,
	TextXAlignment = Enum.TextXAlignment.Left
}, Content)

local BombDropdownButton = create("TextButton", {
	Position = UDim2.new(0, 14, 0, 1050),
	Size = UDim2.new(1, -28, 0, 32),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	Text = "Bomb: Classic Bomb",
	TextColor3 = Theme.Text,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd
}, Content)
styleSurface(BombDropdownButton, 6, Theme.Accent)
create("UIPadding", {
	PaddingLeft = UDim.new(0, 8),
	PaddingRight = UDim.new(0, 8)
}, BombDropdownButton)
UI.BombDropdownButton = BombDropdownButton

local BombDropdownList = create("ScrollingFrame", {
	Position = UDim2.new(0, 14, 0, 1088),
	Size = UDim2.new(1, -28, 0, 102),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	ScrollBarThickness = 4,
	ScrollBarImageColor3 = Theme.Accent,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	ElasticBehavior = Enum.ElasticBehavior.Never,
	Visible = false,
	ZIndex = 7
}, Content)
styleSurface(BombDropdownList, 6, Theme.Accent)
create("UIPadding", {
	PaddingTop = UDim.new(0, 6),
	PaddingLeft = UDim.new(0, 6),
	PaddingRight = UDim.new(0, 6),
	PaddingBottom = UDim.new(0, 6)
}, BombDropdownList)
local BombDropdownLayout = create("UIListLayout", {
	Padding = UDim.new(0, 4),
	SortOrder = Enum.SortOrder.LayoutOrder
}, BombDropdownList)
UI.BombDropdownList = BombDropdownList
UI.BombDropdownLayout = BombDropdownLayout

local BuyBombButton = create("TextButton", {
	Position = UDim2.new(0, 14, 0, 1202),
	Size = UDim2.new(1, -28, 0, 34),
	BackgroundColor3 = Theme.Button,
	BorderSizePixel = 0,
	Text = "Start Buy Selected",
	TextColor3 = Theme.Text,
	TextSize = 14,
	Font = Enum.Font.GothamBold
}, Content)
styleSurface(BuyBombButton, 6, Theme.Accent)
UI.BuyBombButton = BuyBombButton

UI.BuyAllBombButton = create("TextButton", {
	Position = UDim2.new(0, 14, 0, 1202),
	Size = UDim2.new(1 / 2, -18, 0, 34),
	BackgroundColor3 = Theme.ButtonDark,
	BorderSizePixel = 0,
	Text = "Buy All OFF",
	TextColor3 = Theme.Text,
	TextSize = 13,
	Font = Enum.Font.GothamBold
}, Content)
styleSurface(UI.BuyAllBombButton, 6, Theme.Accent)

UI.RadarShopLabel = create("TextLabel", {
	Position = UDim2.new(0, 14, 0, 1240),
	Size = UDim2.new(1, -28, 0, 18),
	BackgroundTransparency = 1,
	Text = "Radar shop",
	TextColor3 = Theme.Muted,
	TextSize = 12,
	Font = Enum.Font.GothamMedium,
	TextXAlignment = Enum.TextXAlignment.Left
}, Content)

UI.RadarDropdownButton = create("TextButton", {
	Position = UDim2.new(0, 14, 0, 1264),
	Size = UDim2.new(1, -28, 0, 32),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	Text = "Radar: Crystal Radar",
	TextColor3 = Theme.Text,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd
}, Content)
styleSurface(UI.RadarDropdownButton, 6, Theme.Accent)
create("UIPadding", {
	PaddingLeft = UDim.new(0, 8),
	PaddingRight = UDim.new(0, 8)
}, UI.RadarDropdownButton)

UI.RadarDropdownList = create("ScrollingFrame", {
	Position = UDim2.new(0, 14, 0, 1378),
	Size = UDim2.new(1, -28, 0, 102),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	ScrollBarThickness = 4,
	ScrollBarImageColor3 = Theme.Accent,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	ElasticBehavior = Enum.ElasticBehavior.Never,
	Visible = false,
	ZIndex = 7
}, Content)
styleSurface(UI.RadarDropdownList, 6, Theme.Accent)
create("UIPadding", {
	PaddingTop = UDim.new(0, 6),
	PaddingLeft = UDim.new(0, 6),
	PaddingRight = UDim.new(0, 6),
	PaddingBottom = UDim.new(0, 6)
}, UI.RadarDropdownList)
UI.RadarDropdownLayout = create("UIListLayout", {
	Padding = UDim.new(0, 4),
	SortOrder = Enum.SortOrder.LayoutOrder
}, UI.RadarDropdownList)

UI.BuyAllRadarButton = create("TextButton", {
	Position = UDim2.new(0, 14, 0, 1304),
	Size = UDim2.new(1 / 2, -18, 0, 34),
	BackgroundColor3 = Theme.ButtonDark,
	BorderSizePixel = 0,
	Text = "Buy All Radar OFF",
	TextColor3 = Theme.Text,
	TextSize = 13,
	Font = Enum.Font.GothamBold
}, Content)
styleSurface(UI.BuyAllRadarButton, 6, Theme.Accent)

UI.BuyRadarButton = create("TextButton", {
	Position = UDim2.new(1 / 2, 4, 0, 1304),
	Size = UDim2.new(1 / 2, -18, 0, 34),
	BackgroundColor3 = Theme.Button,
	BorderSizePixel = 0,
	Text = "Start Buy Radar",
	TextColor3 = Theme.Text,
	TextSize = 14,
	Font = Enum.Font.GothamBold
}, Content)
styleSurface(UI.BuyRadarButton, 6, Theme.Accent)

local StatusLabel = create("TextLabel", {
	Position = UDim2.new(0, 14, 0, 1240),
	Size = UDim2.new(1, -28, 0, 18),
	BackgroundTransparency = 1,
	Text = "Idle",
	TextColor3 = Theme.Muted,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd
}, Content)
UI.StatusLabel = StatusLabel

do
	local function restyleStroke(control, color, transparency, thickness)
		local stroke = control:FindFirstChildOfClass("UIStroke")
		if stroke then
			stroke.Color = color
			stroke.Transparency = transparency or 0.35
			stroke.Thickness = thickness or 1
		end
	end

	local function restyleSectionLabel(label)
		label.Text = string.upper(label.Text)
		label.TextColor3 = Theme.Muted
		label.TextSize = 10
		label.Font = Enum.Font.GothamBold
		label.TextTransparency = 0
	end

	local function restyleTextControl(control, background)
		control.BackgroundColor3 = background or Theme.Panel
		control.TextColor3 = Theme.Text
		control.TextSize = 12
		control.Font = Enum.Font.Gotham
		control.TextTransparency = 0
		if control:IsA("TextButton") then
			control.AutoButtonColor = true
			control.Font = Enum.Font.GothamBold
		end
	end

	for _, label in ipairs({
		CrystalFarmLabel,
		CrystalActionsLabel,
		UI.MoneyDropLabel,
		UI.RuneDropLabel,
		UI.BoulderLevelFarmLabel,
		PlayerTPLabel,
		BoulderTPLabel,
		GearShopLabel,
		UI.RadarShopLabel
	}) do
		restyleSectionLabel(label)
	end

	for _, control in ipairs({
		FilterTypeButton,
		WeightModeButton,
		MoneyToggleButton,
		MoneyModeButton,
		LuckToggleButton,
		LuckModeButton,
		PlayerDropdownButton,
		BoulderDropdownButton,
		UI.RuneDropdownButton,
		UI.DigBoulderDropdownButton,
		UI.BoulderLevelDropdownButton,
		BombDropdownButton,
		UI.RadarDropdownButton
	}) do
		restyleTextControl(control, Theme.ButtonDark)
		restyleStroke(control, Theme.GlowSoft, 0.35, 1)
	end

	for _, input in ipairs({
		WeightInput,
		MoneyInput,
		LuckInput,
		UI.FarmDistanceInput,
		UI.MoneyDropInput,
		UI.RuneAmountInput
	}) do
		restyleTextControl(input, Theme.Field)
		input.PlaceholderColor3 = Theme.Text
		restyleStroke(input, Theme.FieldStroke, 0.42, 1)
	end

	for _, button in ipairs({
		FarmButton,
		DropAllButton,
		UI.DropMoneyButton,
		UI.DigReplayButton,
		UI.BoulderLevelFarmButton,
		PlayerTeleportButton,
		BoulderTeleportButton,
		UI.BoulderNoclipButton,
		BoulderEspButton,
		BoulderPromptButton,
		UI.BoulderHopButton,
		UI.BoulderRejoinButton,
		UI.FloatButton,
		UI.SpeedButton,
		UI.InfiniteJumpButton,
		UI.DropRuneButton,
		UI.BuyAllBombButton,
		BuyBombButton,
		UI.BuyAllRadarButton,
		UI.BuyRadarButton,
		WeightFilterButton,
		MoneyFilterButton,
		AboveButton,
		BelowButton
	}) do
		restyleTextControl(button, button.BackgroundColor3)
		button.TextSize = 12
		button.Font = Enum.Font.GothamBold
		restyleStroke(button, Theme.GlowSoft, 0.35, 1)
	end

	for _, list in ipairs({
		FilterTypeList,
		WeightModeList,
		PlayerDropdownList,
		BoulderDropdownList,
		UI.RuneDropdownList,
		UI.DigBoulderDropdownList,
		UI.BoulderLevelDropdownList,
		BombDropdownList,
		UI.RadarDropdownList
	}) do
		list.BackgroundColor3 = Theme.Panel
		restyleStroke(list, Theme.GlowSoft, 0.55, 1)
		if list:IsA("ScrollingFrame") then
			list.ScrollBarImageColor3 = Theme.GlowSoft
		end
	end
end

StatusLabel.BackgroundTransparency = 0
StatusLabel.BackgroundColor3 = Theme.PanelAlt
StatusLabel.TextColor3 = Theme.Text
StatusLabel.TextSize = 11
StatusLabel.Font = Enum.Font.Gotham
styleSurface(StatusLabel, 6, Theme.GlowSoft, 0.55, 1)

local function setStatus(text, color)
	StatusLabel.Text = text
	StatusLabel.TextColor3 = color or Theme.Muted
end

function State.IsLockedScriptUnlocked()
	return State.LockedScriptUnlocked == true
end

function State.ShowLockedScriptMessage()
	setStatus("Locked: add username to LockedScriptUsers", Theme.Bad)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "BenJaMinX",
			Text = "ต้องซื้อระบบนี้เพิ่มถึงจะปลดล็อคได้",
			Duration = 5
		})
	end)
	return false
end

function State.UpdateDigReplayButton()
	if not UI.DigReplayButton then
		return
	end

	if State.DigReplayEnabled then
		UI.DigReplayButton.Text = "DIG LOOP ON"
		UI.DigReplayButton.BackgroundColor3 = Theme.Bad
	else
		UI.DigReplayButton.Text = "DIG LOOP OFF"
		UI.DigReplayButton.BackgroundColor3 = Theme.Button
	end
end

function State.GetDigRequestRemote()
	if State.DigRequestRemote and State.DigRequestRemote.Parent then
		return State.DigRequestRemote
	end

	State.DigRequestRemote = Remotes and Remotes:FindFirstChild("DigRequest")
	return State.DigRequestRemote
end

State.SetStatus = setStatus

function State.RunDigReplayLoop()
	if State.DigReplayThreadRunning then
		return
	end

	State.DigReplayThreadRunning = true
	task.spawn(function()
		while State.DigReplayEnabled do
			local remote = State.GetDigRequestRemote()
			local target = State.GetSelectedDigBoulderTarget and State.GetSelectedDigBoulderTarget()
			if remote and remote.Parent and target and State.FireDigRequestAtBoulder then
				State.FireDigRequestAtBoulder(remote, target)
			end
			task.wait(Config.DigLoopInterval or 0.01)
		end

		State.DigReplayThreadRunning = false
	end)
end

function State.SetDigReplayEnabled(enabled, persist)
	State.DigReplayEnabled = enabled == true
	local digRemote = State.DigReplayEnabled and State.GetDigRequestRemote() or nil
	State.UpdateDigReplayButton()

	if State.DigReplayEnabled then
		if not digRemote then
			State.DigReplayEnabled = false
			State.UpdateDigReplayButton()
			setStatus("DigRequest remote not found", Theme.Bad)
			if persist ~= false then
				State.SaveConfig()
			end
			return false
		end

		if State.GetSelectedDigBoulderTarget and not State.GetSelectedDigBoulderTarget() then
			State.DigReplayEnabled = false
			State.UpdateDigReplayButton()
			UI.DigBoulderDropdownList.Visible = true
			if State.RefreshDigBoulderDropdownOptions then
				State.RefreshDigBoulderDropdownOptions()
			end
			setStatus("Select Dig Boulder first", Theme.Bad)
			if persist ~= false then
				State.SaveConfig()
			end
			return false
		end

		State.RunDigReplayLoop()
		setStatus("Dig loop ON -> " .. (State.GetDigBoulderDisplayName and State.GetDigBoulderDisplayName() or "Boulder"), Theme.Good)
	else
		setStatus("Dig loop stopped", Theme.Muted)
	end

	if persist ~= false then
		State.SaveConfig()
	end
	return State.DigReplayEnabled
end

local function setRect(object, x, y, width, height)
	object.Position = UDim2.new(0, x, 0, y)
	object.Size = UDim2.new(0, width, 0, height)
end

function State.ApplyContentDensity(positionScale, heightScale, baseCanvasHeight)
	for _, child in ipairs(Content:GetChildren()) do
		if child:IsA("GuiObject") and child ~= FilterTypeList and child ~= WeightModeList then
			local position = child.Position
			local size = child.Size
			child.Position = UDim2.new(
				position.X.Scale,
				position.X.Offset,
				position.Y.Scale,
				math.floor((position.Y.Offset * positionScale) + 0.5)
			)
			if size.Y.Offset > 0 then
				child.Size = UDim2.new(
					size.X.Scale,
					size.X.Offset,
					size.Y.Scale,
					math.max(14, math.floor((size.Y.Offset * heightScale) + 0.5))
				)
			end
		end
	end

	Content.CanvasSize = UDim2.new(0, 0, 0, math.floor((baseCanvasHeight * positionScale) + 28))
end

local function applyVerticalControlsLayout()
	Content.CanvasSize = UDim2.new(0, 0, 0, CONTENT_HEIGHT)

	CrystalFarmLabel.Position = UDim2.new(0, 14, 0, 14)
	CrystalFarmLabel.Size = UDim2.new(1, -28, 0, 18)
	FilterTypeButton.Position = UDim2.new(0, 14, 0, 38)
	FilterTypeButton.Size = UDim2.new(1, -28, 0, 30)
	WeightModeButton.Position = UDim2.new(0, 14, 0, 74)
	WeightModeButton.Size = UDim2.new(1, -28, 0, 30)
	WeightInput.Position = UDim2.new(0, 14, 0, 110)
	WeightInput.Size = UDim2.new(1, -28, 0, 30)
	MoneyToggleButton.Position = UDim2.new(0, 14, 0, 146)
	MoneyToggleButton.Size = UDim2.new(1, -28, 0, 30)
	MoneyModeButton.Position = UDim2.new(0, 14, 0, 182)
	MoneyModeButton.Size = UDim2.new(1, -28, 0, 30)
	MoneyInput.Position = UDim2.new(0, 14, 0, 218)
	MoneyInput.Size = UDim2.new(1, -28, 0, 30)
	LuckToggleButton.Position = UDim2.new(0, 14, 0, 258)
	LuckToggleButton.Size = UDim2.new(1, -28, 0, 30)
	LuckModeButton.Position = UDim2.new(0, 14, 0, 294)
	LuckModeButton.Size = UDim2.new(1, -28, 0, 30)
	LuckInput.Position = UDim2.new(0, 14, 0, 330)
	LuckInput.Size = UDim2.new(1, -28, 0, 30)
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	UI.FarmDistanceInput.Position = UDim2.new(0, 14, 0, 370)
	UI.FarmDistanceInput.Size = UDim2.new(1 / 2, -19, 0, 34)
	FarmButton.Position = UDim2.new(1 / 2, 5, 0, 370)
	FarmButton.Size = UDim2.new(1 / 2, -19, 0, 34)

	CrystalActionsLabel.Position = UDim2.new(0, 14, 0, 420)
	CrystalActionsLabel.Size = UDim2.new(1, -28, 0, 18)
	DropAllButton.Position = UDim2.new(0, 14, 0, 444)
	DropAllButton.Size = UDim2.new(1, -28, 0, 34)

	UI.MoneyDropLabel.Position = UDim2.new(0, 14, 0, 494)
	UI.MoneyDropLabel.Size = UDim2.new(1, -28, 0, 18)
	UI.MoneyDropInput.Position = UDim2.new(0, 14, 0, 518)
	UI.MoneyDropInput.Size = UDim2.new(1 / 2, -19, 0, 34)
	UI.DropMoneyButton.Position = UDim2.new(1 / 2, 5, 0, 518)
	UI.DropMoneyButton.Size = UDim2.new(1 / 2, -19, 0, 34)

	UI.RuneDropLabel.Position = UDim2.new(0, 14, 0, 568)
	UI.RuneDropLabel.Size = UDim2.new(1, -28, 0, 18)
	UI.RuneDropdownButton.Position = UDim2.new(0, 14, 0, 592)
	UI.RuneDropdownButton.Size = UDim2.new(1, -28, 0, 32)
	UI.RuneDropdownList.Position = UDim2.new(0, 14, 0, 630)
	UI.RuneDropdownList.Size = UDim2.new(1, -28, 0, 102)
	UI.RuneAmountInput.Position = UDim2.new(0, 14, 0, 744)
	UI.RuneAmountInput.Size = UDim2.new(1 / 2, -19, 0, 34)
	UI.DropRuneButton.Position = UDim2.new(1 / 2, 5, 0, 744)
	UI.DropRuneButton.Size = UDim2.new(1 / 2, -19, 0, 34)

	UI.DigReplayButton.Position = UDim2.new(0, 14, 0, 794)
	UI.DigReplayButton.Size = UDim2.new(1 / 2, -19, 0, 34)
	UI.DigBoulderDropdownButton.Position = UDim2.new(1 / 2, 5, 0, 794)
	UI.DigBoulderDropdownButton.Size = UDim2.new(1 / 2, -19, 0, 34)
	UI.DigBoulderDropdownList.Position = UDim2.new(0, 14, 0, 836)
	UI.DigBoulderDropdownList.Size = UDim2.new(1, -28, 0, 102)

	UI.BoulderLevelFarmLabel.Position = UDim2.new(0, 14, 0, 954)
	UI.BoulderLevelFarmLabel.Size = UDim2.new(1, -28, 0, 18)
	UI.BoulderLevelDropdownButton.Position = UDim2.new(0, 14, 0, 978)
	UI.BoulderLevelDropdownButton.Size = UDim2.new(1 / 2, -19, 0, 34)
	UI.BoulderLevelFarmButton.Position = UDim2.new(1 / 2, 5, 0, 978)
	UI.BoulderLevelFarmButton.Size = UDim2.new(1 / 2, -19, 0, 34)
	UI.BoulderLevelDropdownList.Position = UDim2.new(0, 14, 0, 1018)
	UI.BoulderLevelDropdownList.Size = UDim2.new(1, -28, 0, 102)

	PlayerTPLabel.Position = UDim2.new(0, 14, 0, 1138)
	PlayerTPLabel.Size = UDim2.new(1, -28, 0, 18)
	PlayerDropdownButton.Position = UDim2.new(0, 14, 0, 1162)
	PlayerDropdownButton.Size = UDim2.new(1, -28, 0, 32)
	PlayerDropdownList.Position = UDim2.new(0, 14, 0, 1200)
	PlayerDropdownList.Size = UDim2.new(1, -28, 0, 102)
	PlayerTeleportButton.Position = UDim2.new(0, 14, 0, 1314)
	PlayerTeleportButton.Size = UDim2.new(1, -28, 0, 34)

	BoulderTPLabel.Position = UDim2.new(0, 14, 0, 1364)
	BoulderTPLabel.Size = UDim2.new(1, -28, 0, 18)
	BoulderDropdownButton.Position = UDim2.new(0, 14, 0, 1388)
	BoulderDropdownButton.Size = UDim2.new(1, -28, 0, 32)
	BoulderDropdownList.Position = UDim2.new(0, 14, 0, 1426)
	BoulderDropdownList.Size = UDim2.new(1, -28, 0, 102)
	BoulderTeleportButton.Position = UDim2.new(0, 14, 0, 1540)
	BoulderTeleportButton.Size = UDim2.new(1 / 6, -10, 0, 34)
	UI.BoulderNoclipButton.Position = UDim2.new(1 / 6, 10, 0, 1540)
	UI.BoulderNoclipButton.Size = UDim2.new(1 / 6, -10, 0, 34)
	BoulderEspButton.Position = UDim2.new(2 / 6, 6, 0, 1540)
	BoulderEspButton.Size = UDim2.new(1 / 6, -10, 0, 34)
	BoulderPromptButton.Position = UDim2.new(3 / 6, 2, 0, 1540)
	BoulderPromptButton.Size = UDim2.new(1 / 6, -10, 0, 34)
	UI.BoulderHopButton.Position = UDim2.new(4 / 6, -2, 0, 1540)
	UI.BoulderHopButton.Size = UDim2.new(1 / 6, -10, 0, 34)
	UI.BoulderRejoinButton.Position = UDim2.new(5 / 6, -6, 0, 1540)
	UI.BoulderRejoinButton.Size = UDim2.new(1 / 6, -10, 0, 34)
	UI.FloatButton.Position = UDim2.new(0, 14, 0, 1580)
	UI.FloatButton.Size = UDim2.new(1 / 3, -16, 0, 34)
	UI.SpeedButton.Position = UDim2.new(1 / 3, 4, 0, 1580)
	UI.SpeedButton.Size = UDim2.new(1 / 3, -16, 0, 34)
	UI.InfiniteJumpButton.Position = UDim2.new(2 / 3, -6, 0, 1580)
	UI.InfiniteJumpButton.Size = UDim2.new(1 / 3, -16, 0, 34)

	GearShopLabel.Position = UDim2.new(0, 14, 0, 1630)
	GearShopLabel.Size = UDim2.new(1, -28, 0, 18)
	BombDropdownButton.Position = UDim2.new(0, 14, 0, 1654)
	BombDropdownButton.Size = UDim2.new(1, -28, 0, 32)
	UI.BuyAllBombButton.Position = UDim2.new(0, 14, 0, 1694)
	UI.BuyAllBombButton.Size = UDim2.new(1 / 2, -18, 0, 34)
	BuyBombButton.Position = UDim2.new(1 / 2, 4, 0, 1694)
	BuyBombButton.Size = UDim2.new(1 / 2, -18, 0, 34)
	BombDropdownList.Position = UDim2.new(0, 14, 0, 1736)
	BombDropdownList.Size = UDim2.new(1, -28, 0, 102)
	UI.RadarShopLabel.Position = UDim2.new(0, 14, 0, 1850)
	UI.RadarShopLabel.Size = UDim2.new(1, -28, 0, 18)
	UI.RadarDropdownButton.Position = UDim2.new(0, 14, 0, 1874)
	UI.RadarDropdownButton.Size = UDim2.new(1, -28, 0, 32)
	UI.BuyAllRadarButton.Position = UDim2.new(0, 14, 0, 1914)
	UI.BuyAllRadarButton.Size = UDim2.new(1 / 2, -18, 0, 34)
	UI.BuyRadarButton.Position = UDim2.new(1 / 2, 4, 0, 1914)
	UI.BuyRadarButton.Size = UDim2.new(1 / 2, -18, 0, 34)
	UI.RadarDropdownList.Position = UDim2.new(0, 14, 0, 1956)
	UI.RadarDropdownList.Size = UDim2.new(1, -28, 0, 102)
	StatusLabel.Position = UDim2.new(0, 14, 0, 2064)
	StatusLabel.Size = UDim2.new(1, -28, 0, 18)
	State.ApplyContentDensity(UI.IsMobile and 0.78 or 0.86, UI.IsMobile and 0.82 or 0.88, CONTENT_HEIGHT)
end

local function applyHorizontalControlsLayout(width)
	Content.CanvasSize = UDim2.new(0, 0, 0, HORIZONTAL_CONTENT_HEIGHT)

	local margin = UI.IsMobile and 12 or 14
	local gutter = UI.IsMobile and 12 or 14
	local rowGap = 8
	local columnWidth = math.floor((width - (margin * 2) - gutter) / 2)
	local leftX = margin
	local rightX = margin + columnWidth + gutter
	local filterNameWidth = math.floor(columnWidth * 0.42)
	local filterModeWidth = math.floor(columnWidth * 0.28)
	local filterInputWidth = columnWidth - filterNameWidth - filterModeWidth - 20
	local filterModeX = leftX + filterNameWidth + 10
	local filterInputX = filterModeX + filterModeWidth + 10
	local halfWidth = math.floor((columnWidth - 10) / 2)
	local tpButtonWidth = math.min(104, math.max(82, math.floor(columnWidth * 0.32)))
	local playerDropdownWidth = columnWidth - tpButtonWidth - 8
	local boulderActionWidth = math.floor((columnWidth - 50) / 6)
	local runeButtonWidth = math.min(104, math.max(86, math.floor(columnWidth * 0.28)))
	local runeAmountWidth = math.min(72, math.max(58, math.floor(columnWidth * 0.2)))
	local runeDropdownWidth = columnWidth - runeButtonWidth - runeAmountWidth - 16

	setRect(CrystalFarmLabel, leftX, 8, columnWidth, 16)
	setRect(FilterTypeButton, leftX, 32, filterNameWidth, 30)
	setRect(WeightModeButton, filterModeX, 32, filterModeWidth, 30)
	setRect(WeightInput, filterInputX, 32, filterInputWidth, 30)
	setRect(MoneyToggleButton, leftX, 32 + 30 + rowGap, filterNameWidth, 30)
	setRect(MoneyModeButton, filterModeX, 32 + 30 + rowGap, filterModeWidth, 30)
	setRect(MoneyInput, filterInputX, 32 + 30 + rowGap, filterInputWidth, 30)
	setRect(LuckToggleButton, leftX, 32 + ((30 + rowGap) * 2), filterNameWidth, 30)
	setRect(LuckModeButton, filterModeX, 32 + ((30 + rowGap) * 2), filterModeWidth, 30)
	setRect(LuckInput, filterInputX, 32 + ((30 + rowGap) * 2), filterInputWidth, 30)
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	setRect(UI.FarmDistanceInput, leftX, 150, halfWidth, 34)
	setRect(FarmButton, leftX + halfWidth + 10, 150, halfWidth, 34)

	setRect(CrystalActionsLabel, leftX, 204, columnWidth, 16)
	setRect(DropAllButton, leftX, 228, columnWidth, 34)
	setRect(UI.MoneyDropLabel, leftX, 274, columnWidth, 16)
	setRect(UI.MoneyDropInput, leftX, 298, halfWidth, 34)
	setRect(UI.DropMoneyButton, leftX + halfWidth + 10, 298, halfWidth, 34)
	setRect(UI.RuneDropLabel, leftX, 344, columnWidth, 16)
	setRect(UI.RuneDropdownButton, leftX, 368, runeDropdownWidth, 34)
	setRect(UI.RuneAmountInput, leftX + runeDropdownWidth + 8, 368, runeAmountWidth, 34)
	setRect(UI.DropRuneButton, leftX + runeDropdownWidth + runeAmountWidth + 16, 368, runeButtonWidth, 34)
	setRect(UI.RuneDropdownList, leftX, 410, columnWidth, 76)
	setRect(UI.DigReplayButton, leftX, 498, halfWidth, 34)
	setRect(UI.DigBoulderDropdownButton, leftX + halfWidth + 10, 498, halfWidth, 34)
	setRect(UI.DigBoulderDropdownList, leftX, 540, columnWidth, 96)

	setRect(PlayerTPLabel, rightX, 8, columnWidth, 16)
	setRect(PlayerDropdownButton, rightX, 32, playerDropdownWidth, 34)
	setRect(PlayerTeleportButton, rightX + playerDropdownWidth + 8, 32, tpButtonWidth, 34)
	setRect(PlayerDropdownList, rightX, 74, columnWidth, 102)

	setRect(BoulderTPLabel, rightX, 92, columnWidth, 16)
	setRect(BoulderDropdownButton, rightX, 116, columnWidth, 34)
	setRect(BoulderTeleportButton, rightX, 158, boulderActionWidth, 32)
	setRect(UI.BoulderNoclipButton, rightX + boulderActionWidth + 10, 158, boulderActionWidth, 32)
	setRect(BoulderEspButton, rightX + (boulderActionWidth * 2) + 20, 158, boulderActionWidth, 32)
	setRect(BoulderPromptButton, rightX + (boulderActionWidth * 3) + 30, 158, boulderActionWidth, 32)
	setRect(UI.BoulderHopButton, rightX + (boulderActionWidth * 4) + 40, 158, boulderActionWidth, 32)
	setRect(UI.BoulderRejoinButton, rightX + (boulderActionWidth * 5) + 50, 158, boulderActionWidth, 32)
	setRect(BoulderDropdownList, rightX, 198, columnWidth, 108)
	setRect(UI.FloatButton, rightX, 200, math.floor((columnWidth - 20) / 3), 32)
	setRect(UI.SpeedButton, rightX + math.floor((columnWidth - 20) / 3) + 10, 200, math.floor((columnWidth - 20) / 3), 32)
	setRect(UI.InfiniteJumpButton, rightX + (math.floor((columnWidth - 20) / 3) * 2) + 20, 200, columnWidth - (math.floor((columnWidth - 20) / 3) * 2) - 20, 32)
	setRect(UI.BoulderLevelFarmLabel, rightX, 250, columnWidth, 16)
	setRect(UI.BoulderLevelDropdownButton, rightX, 274, halfWidth, 34)
	setRect(UI.BoulderLevelFarmButton, rightX + halfWidth + 10, 274, halfWidth, 34)
	setRect(UI.BoulderLevelDropdownList, rightX, 316, columnWidth, 96)

	setRect(GearShopLabel, rightX, 424, columnWidth, 16)
	setRect(BombDropdownButton, rightX, 448, columnWidth, 34)
	setRect(UI.BuyAllBombButton, rightX, 490, halfWidth, 34)
	setRect(BuyBombButton, rightX + halfWidth + 10, 490, halfWidth, 34)
	setRect(BombDropdownList, rightX, 532, columnWidth, 96)
	setRect(UI.RadarShopLabel, rightX, 642, columnWidth, 16)
	setRect(UI.RadarDropdownButton, rightX, 666, columnWidth, 34)
	setRect(UI.BuyAllRadarButton, rightX, 708, halfWidth, 34)
	setRect(UI.BuyRadarButton, rightX + halfWidth + 10, 708, halfWidth, 34)
	setRect(UI.RadarDropdownList, rightX, 750, columnWidth, 96)
	setRect(StatusLabel, rightX, 854, columnWidth, 40)
	State.ApplyContentDensity(UI.IsMobile and 0.82 or 0.88, UI.IsMobile and 0.86 or 0.9, HORIZONTAL_CONTENT_HEIGHT)
end

local function getCurrentMainPixelSize()
	return State.Collapsed and UI.CollapsedPixelSize or UI.ExpandedPixelSize
end

local function setMainPositionClamped(x, y, mainSize)
	x = tonumber(x) or 0
	y = tonumber(y) or 0
	Main.Position = UDim2.new(
		0,
		math.floor(x + 0.5),
		0,
		math.floor(y + 0.5)
	)
end

local function clampMainToViewport(mainSize)
	local viewport = getViewportSize()
	local x = (viewport.X * Main.Position.X.Scale) + Main.Position.X.Offset
	local y = (viewport.Y * Main.Position.Y.Scale) + Main.Position.Y.Offset
	setMainPositionClamped(x, y, mainSize)
end

local function applyResponsiveLayout(centerMobile)
	local viewport = getViewportSize()
	local mobile = shouldUseMobileLayout(viewport)
	local mobileLandscape = mobile and viewport.X > viewport.Y
	local compactPortrait = mobile and viewport.X < 480 and viewport.X <= viewport.Y
	local horizontalLayout = not compactPortrait
	local headerHeight = mobile and MOBILE_HEADER_HEIGHT or DESKTOP_HEADER_HEIGHT
	local edgeMargin = mobile and 10 or 8
	local safeWidth = math.max(1, viewport.X - (edgeMargin * 2))
	local safeHeight = math.max(headerHeight, viewport.Y - (edgeMargin * 2))
	local width
	local height
	local collapsedWidth

	if horizontalLayout then
		local minimumWidth = mobile and (mobileLandscape and 540 or 600) or 620
		local minimumHeight = math.min(headerHeight + (mobile and 110 or 180), safeHeight)
		width = math.min(mobile and 720 or 760, math.max(minimumWidth, viewport.X - (mobile and 28 or 72)))
		width = math.max(math.min(minimumWidth, safeWidth), math.min(width, safeWidth))
		height = math.min(headerHeight + HORIZONTAL_CONTENT_HEIGHT, math.max(minimumHeight, mobile and math.floor(viewport.Y * (mobileLandscape and 0.82 or 0.78)) or math.min(viewport.Y - 32, headerHeight + 760)))
		height = math.max(minimumHeight, math.min(height, safeHeight))
	else
		local minimumWidth = math.min(260, safeWidth)
		local minimumHeight = math.min(headerHeight + 100, safeHeight)
		width = math.min(mobile and 330 or 350, math.max(220, viewport.X - (mobile and 28 or 24)))
		width = math.max(minimumWidth, math.min(width, safeWidth))
		height = math.min(headerHeight + CONTENT_HEIGHT, math.max(minimumHeight, mobile and math.floor(viewport.Y * 0.74) or math.min(viewport.Y - 32, headerHeight + 780)))
		height = math.max(minimumHeight, math.min(height, safeHeight))
	end
	collapsedWidth = math.min(width, math.max(260, math.min(mobile and MOBILE_COLLAPSED_WIDTH or DESKTOP_COLLAPSED_WIDTH, safeWidth)))

	UI.IsMobile = mobile
	UI.ExpandedPixelSize = Vector2.new(width, height)
	UI.CollapsedPixelSize = Vector2.new(collapsedWidth, headerHeight)
	UI.ExpandedSize = UDim2.new(0, width, 0, height)
	UI.CollapsedSize = UDim2.new(0, collapsedWidth, 0, headerHeight)

	Main.Size = State.Collapsed and UI.CollapsedSize or UI.ExpandedSize
	Header.Size = UDim2.new(1, 0, 0, headerHeight)
	Content.Position = UDim2.new(0, 0, 0, headerHeight)
	Content.Size = UDim2.new(1, 0, 1, -headerHeight)
	Content.ScrollBarThickness = mobile and 5 or 4
	BombDropdownList.ScrollBarThickness = mobile and 5 or 4
	UI.RadarDropdownList.ScrollBarThickness = mobile and 5 or 4
	UI.RuneDropdownList.ScrollBarThickness = mobile and 5 or 4
	UI.DigBoulderDropdownList.ScrollBarThickness = mobile and 5 or 4
	UI.BoulderLevelDropdownList.ScrollBarThickness = mobile and 5 or 4
	PlayerDropdownList.ScrollBarThickness = mobile and 5 or 4
	BoulderDropdownList.ScrollBarThickness = mobile and 5 or 4

	local headerButtonWidth = mobile and 34 or 30
	local headerButtonHeight = mobile and 28 or 26
	local edgePadding = mobile and 7 or 9
	local headerGap = mobile and 6 or 7

	CloseButton.Position = UDim2.new(1, -edgePadding, 0.5, 0)
	CloseButton.Size = UDim2.new(0, headerButtonWidth, 0, headerButtonHeight)
	CollapseButton.Position = UDim2.new(1, -(edgePadding + headerButtonWidth + headerGap), 0.5, 0)
	CollapseButton.Size = UDim2.new(0, headerButtonWidth, 0, headerButtonHeight)
	HeaderTitle.Size = UDim2.new(1, -(edgePadding + (headerButtonWidth * 2) + headerGap + 16), 1, 0)
	HeaderTitle.TextSize = mobile and 14 or 15

	if horizontalLayout then
		applyHorizontalControlsLayout(width)
	else
		applyVerticalControlsLayout()
	end

	if centerMobile or not UI.LayoutInitialized then
		local currentSize = getCurrentMainPixelSize()
		setMainPositionClamped(
			(viewport.X - currentSize.X) / 2,
			(viewport.Y - currentSize.Y) / 2,
			currentSize
		)
	else
		clampMainToViewport(getCurrentMainPixelSize())
	end

	UI.LayoutInitialized = true
end

local function parseNumber(value)
	if type(value) == "number" then
		return value
	end

	local text = tostring(value or ""):gsub(",", ".")
	local direct = tonumber(text)
	if direct then
		return direct
	end

	local parsed = text:match("%d+%.?%d*")
	return parsed and tonumber(parsed) or nil
end

function State.UpdateFarmDistance(value, persist)
	local parsed = parseNumber(value ~= nil and value or (UI.FarmDistanceInput and UI.FarmDistanceInput.Text))
	if not parsed or parsed <= 0 then
		parsed = 100
	end

	Config.FarmDistance = parsed
	if UI.FarmDistanceInput then
		UI.FarmDistanceInput.Text = tostring(parsed)
	end
	if persist ~= false then
		State.SaveConfig()
	end
	return parsed
end

local function parseMoneyNumber(value)
	if type(value) == "number" then
		return value
	end

	local text = tostring(value or ""):gsub(",", ""):gsub("%s+", ""):lower()
	if text == "" then
		return nil
	end

	local numberText, suffix = text:match("^%$?([%d%.]+)([kmbt]?)$")
	local number = tonumber(numberText)
	if not number then
		local parsed, parsedSuffix = text:match("%$?([%d%.]+)([kmbt]?)")
		number = tonumber(parsed)
		suffix = parsedSuffix
	end
	if not number then
		return nil
	end

	local multipliers = {
		k = 1e3,
		m = 1e6,
		b = 1e9,
		t = 1e12
	}

	return number * (multipliers[suffix or ""] or 1)
end

function State.ParseLuckNumber(value)
	if type(value) == "number" then
		return value > 1 and (value / 100) or value
	end

	local text = tostring(value or ""):lower():gsub(",", "."):gsub("%s+", "")
	if text == "" then
		return nil
	end

	local rawMode = text:find("x", 1, true) ~= nil or text:find("raw", 1, true) ~= nil
	text = text:gsub("%%", ""):gsub("%+", ""):gsub("x", ""):gsub("raw", "")

	local parsed = parseNumber(text)
	if not parsed then
		return nil
	end

	return rawMode and parsed or (parsed / 100)
end

local function getNetworking()
	if Networking then
		return Networking
	end

	local sharedModules = ReplicatedStorage:FindFirstChild("SharedModules")
	local networkingModule = sharedModules and sharedModules:FindFirstChild("Networking")
	if not (networkingModule and networkingModule:IsA("ModuleScript")) then
		return nil
	end

	local ok, result = pcall(require, networkingModule)
	if ok then
		Networking = result
		return Networking
	end

	return nil
end

function State.GetCrystalLuckModule()
	if State.CrystalLuckModule ~= nil then
		return State.CrystalLuckModule or nil
	end

	local modules = ReplicatedStorage:FindFirstChild("Modules")
	local crystals = modules and modules:FindFirstChild("Crystals")
	local crystalLuck = crystals and crystals:FindFirstChild("CrystalLuck")
	if not (crystalLuck and crystalLuck:IsA("ModuleScript")) then
		State.CrystalLuckModule = false
		return nil
	end

	local ok, result = pcall(require, crystalLuck)
	if ok and type(result) == "table" then
		State.CrystalLuckModule = result
		return State.CrystalLuckModule
	end

	State.CrystalLuckModule = false
	return nil
end

function State.FormatCompactNumber(value)
	value = tonumber(value) or 0
	if math.abs(value - math.floor(value)) < 0.000001 then
		return tostring(math.floor(value))
	end

	local text = string.format("%.4f", value)
	text = text:gsub("0+$", ""):gsub("%.$", "")
	return text
end

function State.FormatLuckPercent(value)
	local crystalLuck = State.GetCrystalLuckModule()
	if crystalLuck and type(crystalLuck.formatLuckPercent) == "function" then
		local ok, result = pcall(function()
			return crystalLuck.formatLuckPercent(value)
		end)
		if ok and result then
			return tostring(result)
		end
	end

	return "+" .. State.FormatCompactNumber((tonumber(value) or 0) * 100) .. "%"
end

function State.FormatLuckInput(value)
	return State.FormatCompactNumber((tonumber(value) or 0) * 100)
end

local function normalizeFilterType(filterType)
	local text = tostring(filterType or ""):lower()
	if text:find("luck", 1, true)
		or text:find("lucky", 1, true)
		or text:find("fortune", 1, true)
		or text:find("chance", 1, true) then
		return "Luck"
	end

	if text:find("money", 1, true)
		or text:find("cash", 1, true)
		or text:find("coin", 1, true)
		or text:find("price", 1, true)
		or text:find("value", 1, true)
		or text:find("worth", 1, true)
		or text:find("$", 1, true) then
		return "Money"
	end

	return "Weight"
end

local function normalizeComparisonMode(mode)
	local text = tostring(mode or ""):lower()
	return (text:find("below", 1, true)
		or text:find("less", 1, true)
		or text:find("under", 1, true)
		or text:find("<", 1, true)) and "Below" or "Above"
end

local function getFilterEnabledForType(filterType)
	filterType = normalizeFilterType(filterType)
	if filterType == "Money" then
		return Config.MoneyEnabled ~= false
	end
	if filterType == "Luck" then
		return Config.LuckEnabled == true
	end

	return Config.WeightEnabled ~= false
end

local function getFilterModeForType(filterType)
	filterType = normalizeFilterType(filterType)
	if filterType == "Money" then
		return normalizeComparisonMode(Config.MoneyMode or "Above")
	end
	if filterType == "Luck" then
		return normalizeComparisonMode(Config.LuckMode or "Above")
	end

	return normalizeComparisonMode(Config.WeightMode or "Above")
end

local function getFilterThresholdForType(filterType)
	filterType = normalizeFilterType(filterType)
	if filterType == "Money" then
		return parseMoneyNumber(Config.MoneyThreshold) or 0
	end
	if filterType == "Luck" then
		if type(Config.LuckThreshold) == "string" then
			return State.ParseLuckNumber(Config.LuckThreshold) or 0
		end
		return parseNumber(Config.LuckThreshold) or 0
	end

	return parseNumber(Config.WeightThreshold) or 0
end

local function setFilterThresholdForType(filterType, threshold)
	threshold = math.max(0, tonumber(threshold) or 0)
	filterType = normalizeFilterType(filterType)

	if filterType == "Money" then
		Config.MoneyThreshold = threshold
	elseif filterType == "Luck" then
		Config.LuckThreshold = threshold
	else
		Config.WeightThreshold = threshold
	end
end

local function parseFilterThreshold(filterType, value)
	filterType = normalizeFilterType(filterType)
	if filterType == "Money" then
		return parseMoneyNumber(value)
	end
	if filterType == "Luck" then
		return State.ParseLuckNumber(value)
	end

	return parseNumber(value)
end

local function formatFilterThreshold(filterType)
	filterType = normalizeFilterType(filterType)
	local threshold = getFilterThresholdForType(filterType)
	if filterType == "Money" then
		return "$" .. tostring(threshold)
	end
	if filterType == "Luck" then
		return State.FormatLuckPercent(threshold)
	end

	return tostring(threshold) .. " kg"
end

local function getFilterSummary()
	local parts = {}
	for _, filterType in ipairs({ "Weight", "Money", "Luck" }) do
		if getFilterEnabledForType(filterType) then
			local modeText = getFilterModeForType(filterType) == "Below" and "<" or ">"
			table.insert(parts, ("%s %s %s"):format(filterType, modeText, formatFilterThreshold(filterType)))
		end
	end

	if #parts == 0 then
		return "No filters enabled"
	end

	return table.concat(parts, " | ")
end

local function syncFilterControls()
	FilterTypeButton.Text = getFilterEnabledForType("Weight") and "Weight ON" or "Weight OFF"
	WeightModeButton.Text = getFilterModeForType("Weight")
	WeightInput.PlaceholderText = "kg"
	WeightInput.Text = tostring(getFilterThresholdForType("Weight"))
	FilterTypeButton.BackgroundColor3 = getFilterEnabledForType("Weight") and Theme.Button or Theme.ButtonDark

	MoneyToggleButton.Text = getFilterEnabledForType("Money") and "Money ON" or "Money OFF"
	MoneyModeButton.Text = getFilterModeForType("Money")
	MoneyInput.PlaceholderText = "$"
	MoneyInput.Text = tostring(getFilterThresholdForType("Money"))
	MoneyToggleButton.BackgroundColor3 = getFilterEnabledForType("Money") and Theme.Button or Theme.ButtonDark

	LuckToggleButton.Text = getFilterEnabledForType("Luck") and "Luck ON" or "Luck OFF"
	LuckModeButton.Text = getFilterModeForType("Luck")
	LuckInput.PlaceholderText = "luck %"
	LuckInput.Text = State.FormatLuckInput(getFilterThresholdForType("Luck"))
	LuckToggleButton.BackgroundColor3 = getFilterEnabledForType("Luck") and Theme.Button or Theme.ButtonDark
end

local function updateFilterThreshold(filterType, value, persist)
	if type(value) == "boolean" then
		value = nil
	end

	filterType = normalizeFilterType(filterType)
	local currentText
	if filterType == "Money" then
		currentText = MoneyInput.Text
	elseif filterType == "Luck" then
		currentText = LuckInput.Text
	else
		currentText = WeightInput.Text
	end

	local parsed = parseFilterThreshold(filterType, value ~= nil and value or currentText)
	if parsed then
		setFilterThresholdForType(filterType, parsed)
	end

	if filterType == "Money" then
		MoneyInput.Text = tostring(getFilterThresholdForType(filterType))
	elseif filterType == "Luck" then
		LuckInput.Text = State.FormatLuckInput(getFilterThresholdForType(filterType))
	else
		WeightInput.Text = tostring(getFilterThresholdForType(filterType))
	end

	if persist ~= false then
		State.SaveConfig()
	end
end

local function updateWeightThreshold(value, persist)
	updateFilterThreshold("Weight", value, persist)
end

local function updateMoneyThreshold(value, persist)
	updateFilterThreshold("Money", value, persist)
end

local function updateLuckThreshold(value, persist)
	updateFilterThreshold("Luck", value, persist)
end

local function setFilterEnabled(filterType, enabled, persist)
	filterType = normalizeFilterType(filterType)
	if filterType == "Money" then
		Config.MoneyEnabled = enabled == true
	elseif filterType == "Luck" then
		Config.LuckEnabled = enabled == true
	else
		Config.WeightEnabled = enabled == true
	end

	syncFilterControls()
	if persist ~= false then
		State.SaveConfig()
	end
end

local function toggleFilterEnabled(filterType)
	setFilterEnabled(filterType, not getFilterEnabledForType(filterType))
end

local function setFilterMode(filterType, mode, persist)
	filterType = normalizeFilterType(filterType)
	local normalizedMode = normalizeComparisonMode(mode)

	if filterType == "Money" then
		Config.MoneyMode = normalizedMode
	elseif filterType == "Luck" then
		Config.LuckMode = normalizedMode
	else
		Config.WeightMode = normalizedMode
	end

	syncFilterControls()
	if persist ~= false then
		State.SaveConfig()
	end
end

local function toggleFilterMode(filterType)
	filterType = normalizeFilterType(filterType)
	setFilterMode(filterType, getFilterModeForType(filterType) == "Above" and "Below" or "Above")
end

local function setCollapsed(collapsed, persist)
	State.Collapsed = collapsed == true
	Main.Size = State.Collapsed and UI.CollapsedSize or UI.ExpandedSize
	CollapseButton.Text = State.Collapsed and "+" or "-"

	for _, child in ipairs(Main:GetChildren()) do
		if child:IsA("GuiObject") and child ~= Header then
			child.Visible = not State.Collapsed
		end
	end

	if not State.Collapsed then
		PlayerDropdownList.Visible = false
		BoulderDropdownList.Visible = false
		UI.RuneDropdownList.Visible = false
		UI.DigBoulderDropdownList.Visible = false
		UI.BoulderLevelDropdownList.Visible = false
		BombDropdownList.Visible = false
		UI.RadarDropdownList.Visible = false
	end

	clampMainToViewport(getCurrentMainPixelSize())
	if persist ~= false then
		State.SaveConfig()
	end
end

local function setFarming(enabled, persist)
	State.UpdateFarmDistance(nil, false)
	updateWeightThreshold(nil, false)
	updateMoneyThreshold(nil, false)
	updateLuckThreshold(nil, false)
	State.Farming = enabled == true
	if State.Farming then
		FarmButton.Text = "Stop Farm"
		FarmButton.BackgroundColor3 = Theme.Bad
		setStatus("Farm ON | " .. getFilterSummary(), Theme.Good)
		log("Farm ON", getFilterSummary())
	else
		FarmButton.Text = "Start Farm"
		FarmButton.BackgroundColor3 = Theme.Button
		setStatus("Farm stopped", Theme.Muted)
		log("Farm OFF")
	end
	if persist ~= false then
		State.SaveConfig()
	end
end

local updatePlayerDropdownText
local refreshPlayerDropdownOptions
local setPlayerTeleporting
local updateBoulderDropdownText
local refreshBoulderDropdownOptions
local setBoulderTeleporting
local updateBoulderTeleportButton
local setBoulderEspEnabled
local updateBoulderEspButton
local setBoulderPromptEnabled
local updateBoulderPromptButton
local updateBombDropdownText
local refreshBombDropdownOptions
local RuneDrop = {}
local BoulderEspObjects = {}

local function getPlayerDisplayName(player)
	if not player then
		return "Unknown"
	end

	local displayName = tostring(player.DisplayName or "")
	if displayName ~= "" and displayName ~= player.Name then
		return displayName .. " (@" .. player.Name .. ")"
	end

	return player.Name
end

local function getTeleportTargetPlayer()
	if State.SelectedTeleportPlayerUserId then
		for _, player in ipairs(Players:GetPlayers()) do
			if player.UserId == State.SelectedTeleportPlayerUserId then
				return player
			end
		end
	end

	if State.SelectedTeleportPlayerName then
		local player = Players:FindFirstChild(State.SelectedTeleportPlayerName)
		if player and player ~= LocalPlayer then
			return player
		end
	end

	return nil
end

local function getTeleportablePlayers()
	local playerList = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			table.insert(playerList, player)
		end
	end

	table.sort(playerList, function(left, right)
		return getPlayerDisplayName(left):lower() < getPlayerDisplayName(right):lower()
	end)

	return playerList
end

local function setTeleportPlayer(player, persist)
	if not player or player == LocalPlayer then
		return false
	end

	State.SelectedTeleportPlayerUserId = player.UserId
	State.SelectedTeleportPlayerName = player.Name
	PlayerDropdownList.Visible = false

	if updatePlayerDropdownText then
		updatePlayerDropdownText()
	end

	setStatus("Selected TP: " .. getPlayerDisplayName(player), Theme.Muted)
	if persist ~= false then
		State.SaveConfig()
	end
	return true
end

local function getBouldersFolder()
	local mountainDecorations = Workspace:FindFirstChild("MountainDecorations")
	return mountainDecorations and mountainDecorations:FindFirstChild("Boulders") or nil
end

local function getBoulderTargetCFrame(target)
	if not target or not target.Parent then
		return nil
	end

	if target:IsA("Model") then
		local part = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart", true)
		if not part then
			return nil
		end

		local ok, boxCFrame = pcall(function()
			return target:GetBoundingBox()
		end)
		if ok and boxCFrame then
			return boxCFrame
		end

		local ok, pivot = pcall(function()
			return target:GetPivot()
		end)
		return ok and pivot or part.CFrame
	end

	if target:IsA("BasePart") then
		return target.CFrame
	end

	return nil
end

local function getBoulderTargets()
	local folder = getBouldersFolder()
	local targets = {}
	if not folder then
		return targets
	end

	for _, child in ipairs(folder:GetChildren()) do
		if child:IsA("Model") and getBoulderTargetCFrame(child) then
			table.insert(targets, child)
		end
	end

	table.sort(targets, function(left, right)
		local leftName = left.Name:lower()
		local rightName = right.Name:lower()
		if leftName ~= rightName then
			return leftName < rightName
		end

		local leftCFrame = getBoulderTargetCFrame(left)
		local rightCFrame = getBoulderTargetCFrame(right)
		if not leftCFrame then
			return false
		end
		if not rightCFrame then
			return true
		end

		local leftPosition = leftCFrame.Position
		local rightPosition = rightCFrame.Position
		if leftPosition.X ~= rightPosition.X then
			return leftPosition.X < rightPosition.X
		end
		if leftPosition.Y ~= rightPosition.Y then
			return leftPosition.Y < rightPosition.Y
		end
		return leftPosition.Z < rightPosition.Z
	end)

	return targets
end

local function getBoulderAttributeDisplay(target)
	if not target then
		return nil
	end

	local attributeNames = { "Rarity", "Tier", "Level", "Grade" }
	for _, attributeName in ipairs(attributeNames) do
		local value = target:GetAttribute(attributeName)
		if value ~= nil then
			local text = tostring(value)
			if text ~= "" then
				return text
			end
		end
	end

	for _, attributeName in ipairs(attributeNames) do
		local child = target:FindFirstChild(attributeName, true)
		if child then
			local value
			if child:IsA("ValueBase") then
				value = child.Value
			else
				value = child:GetAttribute("Value") or child:GetAttribute(attributeName)
			end

			if value ~= nil then
				local text = tostring(value)
				if text ~= "" then
					return text
				end
			end
		end
	end

	for _, descendant in ipairs(target:GetDescendants()) do
		for _, attributeName in ipairs(attributeNames) do
			local value = descendant:GetAttribute(attributeName)
			if value ~= nil then
				local text = tostring(value)
				if text ~= "" then
					return text
				end
			end
		end
	end

	return nil
end

local function getBoulderOptionLabels(targets)
	local totals = {}
	local seen = {}
	local labels = {}

	for _, target in ipairs(targets) do
		local label = getBoulderAttributeDisplay(target) or target.Name
		totals[label] = (totals[label] or 0) + 1
	end

	for _, target in ipairs(targets) do
		local label = getBoulderAttributeDisplay(target) or target.Name
		seen[label] = (seen[label] or 0) + 1
		labels[target] = totals[label] > 1 and ("%s #%d"):format(label, seen[label]) or label
	end

	return labels
end

local function getBoulderRarityRank(target)
	local text = tostring(getBoulderAttributeDisplay(target) or target and target.Name or ""):lower()
	local order = {
		{ "celestial apex", 100 },
		{ "celestial", 95 },
		{ "divine", 90 },
		{ "secret", 85 },
		{ "mythic", 80 },
		{ "legendary", 70 },
		{ "epic", 60 },
		{ "rare", 50 },
		{ "uncommon", 40 },
		{ "common", 30 }
	}

	for _, entry in ipairs(order) do
		if text:find(entry[1], 1, true) then
			return entry[2]
		end
	end

	local number = tonumber(text:match("%d+"))
	return number or 0
end

local function sortBouldersByDistance(targets)
	local _, root = getCharacterParts(LocalPlayer)

	table.sort(targets, function(left, right)
		local leftCFrame = getBoulderTargetCFrame(left)
		local rightCFrame = getBoulderTargetCFrame(right)
		if not leftCFrame then
			return false
		end
		if not rightCFrame then
			return true
		end

		if root then
			local leftDistance = (leftCFrame.Position - root.Position).Magnitude
			local rightDistance = (rightCFrame.Position - root.Position).Magnitude
			if leftDistance ~= rightDistance then
				return leftDistance < rightDistance
			end
		end

		local leftRank = getBoulderRarityRank(left)
		local rightRank = getBoulderRarityRank(right)
		if leftRank ~= rightRank then
			return leftRank > rightRank
		end

		local leftLabel = tostring(getBoulderAttributeDisplay(left) or left.Name):lower()
		local rightLabel = tostring(getBoulderAttributeDisplay(right) or right.Name):lower()
		if leftLabel ~= rightLabel then
			return leftLabel < rightLabel
		end

		return leftCFrame.Position.Y > rightCFrame.Position.Y
	end)

	return targets
end

local function getDigBoulderTargets()
	return sortBouldersByDistance(getBoulderTargets())
end

local function getSelectedBoulderTarget()
	local target = State.SelectedBoulderTarget
	local folder = getBouldersFolder()
	if target and folder and target.Parent == folder and target:IsA("Model") and getBoulderTargetCFrame(target) then
		return target
	end

	return nil
end

function State.GetSelectedDigBoulderTarget()
	local target = State.SelectedDigBoulderTarget
	local folder = getBouldersFolder()
	if target and folder and target.Parent == folder and target:IsA("Model") and getBoulderTargetCFrame(target) then
		return target
	end

	return nil
end

local function getBoulderTargetDisplayName(target)
	if not target then
		return tostring(State.SelectedBoulderName or "Boulder")
	end

	local targets = getDigBoulderTargets()
	local labels = getBoulderOptionLabels(targets)
	return labels[target] or target.Name
end

local DIG_HOTBAR_KEY_CODES = {
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
	Enum.KeyCode.Four,
	Enum.KeyCode.Five,
	Enum.KeyCode.Six,
	Enum.KeyCode.Seven,
	Enum.KeyCode.Eight,
	Enum.KeyCode.Nine,
	Enum.KeyCode.Zero
}

local DIG_PICKAXE_PRIORITY_NAMES = {
	"The Terminus",
	"Astral Rend",
	"Celestial Apex",
	"Chipped Stone",
	"Copper Pick",
	"DIAMOND Pickaxe",
	"Eclipse Fang",
	"Emerald Carver",
	"Frostbite Pick",
	"Hardened Iron",
	"Nebular Throne",
	"Obsidian Edge",
	"Reinforced Steel",
	"Rusty Scrapper",
	"Singularity",
	"Tempest Pick",
	"Titanium Spike",
	"Voidreign",
	"Volcano Basalt",
	"Weathered Wood"
}

local DIG_PICKAXE_PRIORITY = {}
local DIG_PICKAXE_SCAN_INTERVAL = 0.5
local DIG_TOOL_EQUIP_RETRY_INTERVAL = 0.25
local DIG_WRONG_TOOL_UNEQUIP_INTERVAL = 0.5
local function canonicalDigToolName(value)
	return (tostring(value or ""):lower():gsub("[%s%p_]+", ""))
end

for index, name in ipairs(DIG_PICKAXE_PRIORITY_NAMES) do
	DIG_PICKAXE_PRIORITY[canonicalDigToolName(name)] = index
end

function State.GetPlayerBackpack()
	if not LocalPlayer then
		return nil
	end

	return LocalPlayer:FindFirstChildOfClass("Backpack") or LocalPlayer:FindFirstChild("Backpack")
end

function State.GetToolNameVariants(tool)
	local variants = {}
	local used = {}

	local function add(value)
		local text = tostring(value or ""):match("^%s*(.-)%s*$") or ""
		if text ~= "" and not used[text] then
			used[text] = true
			table.insert(variants, text)
		end
	end

	local name = tostring(tool and tool.Name or "")
	add(name)
	add((name:gsub("%s*%b[]", "")))
	add((name:gsub("%s*%b()", "")))

	if tool then
		for _, attributeName in ipairs({ "DisplayName", "ItemName", "ToolName", "PickaxeName", "Id", "PickaxeId" }) do
			local ok, value = pcall(function()
				return tool:GetAttribute(attributeName)
			end)
			if ok then
				add(value)
			end
		end
	end

	return variants
end

function State.GetHotbarSlotForTool(tool, backpack)
	if not (tool and backpack) then
		return nil
	end

	local slot = 0
	for _, child in ipairs(backpack:GetChildren()) do
		if child:IsA("Tool") then
			slot += 1
			if child == tool then
				return slot <= #DIG_HOTBAR_KEY_CODES and slot or nil
			end
		end
	end

	return nil
end

function State.PressHotbarSlot(slot)
	local keyCode = DIG_HOTBAR_KEY_CODES[slot]
	if not keyCode then
		return false
	end

	if State.VirtualInputManager == nil then
		local ok, service = pcall(function()
			return game:GetService("VirtualInputManager")
		end)
		State.VirtualInputManager = ok and service or false
	end

	local virtualInput = State.VirtualInputManager
	if not virtualInput then
		return false
	end

	local ok = pcall(function()
		virtualInput:SendKeyEvent(true, keyCode, false, game)
		task.wait(0.03)
		virtualInput:SendKeyEvent(false, keyCode, false, game)
	end)
	return ok
end

function State.WaitForToolParent(tool, parent, timeout)
	local deadline = os.clock() + (timeout or 0.2)
	while tool and parent and tool.Parent ~= parent and os.clock() < deadline do
		task.wait()
	end
	return tool and tool.Parent == parent
end

function State.FindToolInCharacterAndBackpack(predicate)
	local character = LocalPlayer and LocalPlayer.Character
	local backpack = State.GetPlayerBackpack and State.GetPlayerBackpack()

	if character then
		for _, child in ipairs(character:GetChildren()) do
			if predicate(child, character) then
				return child
			end
		end
	end

	if backpack then
		for _, child in ipairs(backpack:GetChildren()) do
			if predicate(child, backpack) then
				return child
			end
		end
	end

	return nil
end

function State.GetWhitelistedPickaxeRank(tool)
	if not (tool and tool:IsA("Tool")) then
		return nil
	end

	for _, name in ipairs(State.GetToolNameVariants(tool)) do
		local rank = DIG_PICKAXE_PRIORITY[canonicalDigToolName(name)]
		if rank then
			return rank
		end
	end

	return nil
end

function State.GetWhitelistedPickaxe(forceScan)
	local now = os.clock()
	local character = LocalPlayer and LocalPlayer.Character
	local backpack = State.GetPlayerBackpack and State.GetPlayerBackpack()
	local cachedTool = State.DigToolCache

	if not forceScan and cachedTool and (cachedTool.Parent == character or cachedTool.Parent == backpack) then
		local cachedRank = State.GetWhitelistedPickaxeRank(cachedTool)
		if cachedRank and (cachedRank == 1 or now - (State.DigToolCacheTick or 0) < DIG_PICKAXE_SCAN_INTERVAL) then
			return cachedTool
		end
	end

	if not forceScan and now - (State.DigToolCacheTick or 0) < DIG_PICKAXE_SCAN_INTERVAL then
		return nil
	end

	State.DigToolCacheTick = now
	State.DigToolCache = nil

	local bestTool = nil
	local bestRank = nil

	local function scan(container)
		if not container then
			return
		end

		for _, child in ipairs(container:GetChildren()) do
			local rank = State.GetWhitelistedPickaxeRank(child)
			if rank and (not bestRank or rank < bestRank) then
				bestTool = child
				bestRank = rank
				if rank == 1 then
					return true
				end
			end
		end

		return false
	end

	if scan(character) then
		State.DigToolCache = bestTool
		return bestTool
	end

	scan(backpack)
	State.DigToolCache = bestTool

	return bestTool
end

function State.UnequipNonWhitelistedDigTool(character)
	character = character or (LocalPlayer and LocalPlayer.Character)
	if not character then
		return false
	end

	local hasWrongTool = false
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Tool") and not State.GetWhitelistedPickaxeRank(child) then
			hasWrongTool = true
			break
		end
	end

	if not hasWrongTool then
		return false
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return false
	end

	pcall(function()
		humanoid:UnequipTools()
	end)
	return true
end

function State.GetDigTool(forceScan)
	return State.GetWhitelistedPickaxe and State.GetWhitelistedPickaxe(forceScan) or nil
end

function State.GetGoHomeRemote()
	if State.GoHomeRemote and State.GoHomeRemote.Parent then
		return State.GoHomeRemote
	end

	State.GoHomeRemote = Remotes and Remotes:FindFirstChild("GoHome")
	return State.GoHomeRemote
end

function State.FirePickaxeRecover()
	local now = os.clock()
	if now - (State.LastPickaxeRecoverTick or 0) < (Config.PickaxeRecoverInterval or 1) then
		return false
	end

	local remote = State.GetGoHomeRemote and State.GetGoHomeRemote()
	if not remote then
		if now - (State.LastDigToolStatusTick or 0) > 2 then
			State.LastDigToolStatusTick = now
			setStatus("GoHome remote not found", Theme.Bad)
		end
		return false
	end

	State.LastPickaxeRecoverTick = now
	pcall(function()
		remote:FireServer("sell")
	end)
	setStatus("Pickaxe missing -> GoHome sell", Theme.Muted)
	return true
end

function State.HasPickaxeAtBoulder()
	return State.GetDigTool and State.GetDigTool(true) ~= nil
end

function State.GetDigToolName()
	local tool = State.GetDigTool()
	return tool and tool.Name or nil
end

function State.EnsureDigToolEquipped()
	local tool = State.GetDigTool()
	local character = LocalPlayer and LocalPlayer.Character
	if not tool then
		if State.BoulderLevelFarmEnabled or State.DigReplayEnabled then
			local now = os.clock()
			if now - (State.LastWrongDigToolUnequipTick or 0) >= DIG_WRONG_TOOL_UNEQUIP_INTERVAL then
				State.LastWrongDigToolUnequipTick = now
				State.UnequipNonWhitelistedDigTool(character)
			end
		end
		if State.BoulderLevelFarmEnabled and os.clock() - (State.LastDigToolStatusTick or 0) > 2 then
			State.LastDigToolStatusTick = os.clock()
			setStatus("Pickaxe not found in Backpack/hotbar", Theme.Bad)
		end
		return false
	end

	if not character then
		return false
	end

	if tool.Parent == character then
		return true
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return false
	end

	local now = os.clock()
	if now - (State.LastDigToolEquipAttemptTick or 0) < DIG_TOOL_EQUIP_RETRY_INTERVAL then
		return false
	end
	State.LastDigToolEquipAttemptTick = now

	local backpack = State.GetPlayerBackpack and State.GetPlayerBackpack()
	if backpack and tool.Parent ~= backpack and tool.Parent ~= character then
		pcall(function()
			tool.Parent = backpack
		end)
		task.wait()
	end

	pcall(function()
		humanoid:UnequipTools()
	end)
	task.wait(0.03)

	pcall(function()
		humanoid:EquipTool(tool)
	end)

	if State.WaitForToolParent(tool, character, 0.18) then
		return true
	end

	if backpack and tool.Parent == backpack then
		local slot = State.GetHotbarSlotForTool(tool, backpack)
		if slot and State.PressHotbarSlot(slot) and State.WaitForToolParent(tool, character, 0.18) then
			return true
		end
	end

	if tool.Parent ~= character then
		pcall(function()
			tool.Parent = character
		end)
	end

	local equipped = State.WaitForToolParent(tool, character, 0.18)
	if not equipped and State.BoulderLevelFarmEnabled and os.clock() - (State.LastDigToolStatusTick or 0) > 2 then
		State.LastDigToolStatusTick = os.clock()
		setStatus("Could not equip pickaxe: " .. tostring(tool.Name), Theme.Bad)
	end
	return equipped
end

function State.GetDigBoulderDisplayName(target)
	target = target or State.GetSelectedDigBoulderTarget()
	if not target then
		return tostring(State.SelectedDigBoulderName or "Boulder")
	end

	local targets = getDigBoulderTargets()
	local labels = getBoulderOptionLabels(targets)
	return labels[target] or getBoulderAttributeDisplay(target) or target.Name
end

function State.CanonicalShopToolName(value)
	return canonicalDigToolName(value)
end

function State.AddPickaxeShopName(nameSet, value)
	local text = tostring(value or ""):match("^%s*(.-)%s*$") or ""
	if text == "" then
		return
	end

	local lowerText = text:lower()
	if lowerText == "equip"
		or lowerText == "pickaxe shop"
		or lowerText == "common"
		or lowerText == "uncommon"
		or lowerText == "rare"
		or lowerText == "epic"
		or lowerText == "legendary"
		or lowerText == "mythic"
		or lowerText:find("power", 1, true)
		or lowerText:find("mine size", 1, true) then
		return
	end

	nameSet[State.CanonicalShopToolName(text)] = true
end

function State.CollectPickaxeShopNamesFromTable(nameSet, value, depth)
	if type(value) ~= "table" or (depth or 0) > 4 then
		return
	end

	for key, entry in pairs(value) do
		if type(entry) == "table" then
			State.AddPickaxeShopName(nameSet, key)
			State.AddPickaxeShopName(nameSet, entry.DisplayName or entry.displayName or entry.Name or entry.name or entry.ItemName or entry.itemName)
			State.CollectPickaxeShopNamesFromTable(nameSet, entry, (depth or 0) + 1)
		elseif type(key) == "string" and (type(entry) == "number" or type(entry) == "boolean") then
			State.AddPickaxeShopName(nameSet, key)
		end
	end
end

function State.GetPickaxeShopNameSet()
	if State.PickaxeShopNameSet and (next(State.PickaxeShopNameSet) ~= nil or os.clock() - (State.PickaxeShopNameSetTick or 0) < 10) then
		return State.PickaxeShopNameSet
	end

	local nameSet = {}
	for _, root in ipairs({ ReplicatedStorage:FindFirstChild("Modules"), ReplicatedStorage:FindFirstChild("SharedModules"), ReplicatedStorage }) do
		if root then
			for _, object in ipairs(root:GetDescendants()) do
				if object:IsA("ModuleScript") and tostring(object.Name or ""):lower():find("pickaxe", 1, true) then
					local ok, result = pcall(require, object)
					if ok then
						State.CollectPickaxeShopNamesFromTable(nameSet, result, 0)
					end
				end
			end
		end
	end

	local playerGui = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
	if playerGui then
		for _, object in ipairs(playerGui:GetDescendants()) do
			if tostring(object:GetFullName()):lower():find("pickaxe", 1, true)
				and (object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox")) then
				local ok, text = pcall(function()
					return object.Text
				end)
				if ok then
					State.AddPickaxeShopName(nameSet, text)
				end
			end
		end
	end

	for _, fallbackName in ipairs({ "The Terminus" }) do
		State.AddPickaxeShopName(nameSet, fallbackName)
	end

	State.PickaxeShopNameSet = nameSet
	State.PickaxeShopNameSetTick = os.clock()
	return nameSet
end

function State.IsBlockedDigToolName(name)
	name = tostring(name or "")
	local lowerName = name:lower()
	return lowerName:find("rune", 1, true)
		or lowerName:find("bomb", 1, true)
		or lowerName:find("radar", 1, true)
		or lowerName == "push"
		or lowerName == "luck"
		or lowerName == "colossal"
		or lowerName == "detonation"
		or lowerName == "fortune"
end

function State.IsDigTool(tool, allowBracket)
	if not (tool and tool:IsA("Tool")) then
		return false
	end

	local name = tostring(tool.Name or "")
	return (allowBracket == true or not name:find("[", 1, true))
		and not State.IsBlockedDigToolName(name)
end

function State.IsCrystalInventoryTool(tool)
	if not (tool and tool:IsA("Tool")) then
		return false
	end

	for _, attributeName in ipairs({ "WeightKg", "LuckKg", "CrystalLuck", "Tier", "Mutation", "BombCrystal", "IsBloodCrystal" }) do
		if tool:GetAttribute(attributeName) ~= nil then
			return true
		end
	end

	return false
end

function State.ToolMatchesPickaxeNameSet(tool, nameSet)
	if not nameSet then
		return false
	end

	for _, name in ipairs(State.GetToolNameVariants(tool)) do
		if nameSet[State.CanonicalShopToolName(name)] then
			return true
		end
	end

	return false
end

function State.HasPickaxeNameHint(tool)
	for _, name in ipairs(State.GetToolNameVariants(tool)) do
		local lowerName = name:lower()
		if lowerName:find("pickaxe", 1, true) or lowerName:find("pick axe", 1, true) then
			return true
		end
	end

	return false
end

function State.IsPickaxeShopTool(tool, nameSet)
	if not State.IsDigTool(tool, true) or State.IsCrystalInventoryTool(tool) then
		return false
	end

	if State.ToolMatchesPickaxeNameSet(tool, nameSet) or State.HasPickaxeNameHint(tool) then
		return true
	end

	for _, attributeName in ipairs({ "Power", "MinePower", "MiningPower", "MineSize", "Mine Size", "Pickaxe", "PickaxeId" }) do
		if tool:GetAttribute(attributeName) ~= nil then
			return true
		end
	end

	return false
end

function State.GetBoulderDigName(target)
	if not target then
		return nil
	end

	for _, attributeName in ipairs({ "BoulderName", "OreName", "CrystalName" }) do
		local value = target:GetAttribute(attributeName)
		if value ~= nil then
			local text = tostring(value)
			if text ~= "" then
				return text
			end
		end
	end

	return target.Name
end

function State.GetBoulderDigNames(target)
	local names = {}
	local used = {}

	local function addName(value)
		local text = tostring(value or "")
		if text ~= "" and not used[text] then
			used[text] = true
			table.insert(names, text)
		end
	end

	addName(State.GetDigToolName and State.GetDigToolName())
	addName(getBoulderAttributeDisplay(target))
	addName(State.GetBoulderDigName(target))
	addName(target and target.Name)
	return names
end

function State.GetBoulderDigPosition(target)
	if not target then
		return nil
	end

	for _, attachmentName in ipairs({ "Center", "Attachment" }) do
		local attachment = target:FindFirstChild(attachmentName, true)
		if attachment and attachment:IsA("Attachment") then
			return attachment.WorldPosition
		end
	end

	local targetCFrame = getBoulderTargetCFrame(target)
	return targetCFrame and targetCFrame.Position or nil
end

function State.FireDigRequestAtBoulder(remote, target)
	local position = State.GetBoulderDigPosition(target)
	if not position then
		return false
	end

	if State.EnsureDigToolEquipped then
		State.EnsureDigToolEquipped()
	end

	local fired = false
	for _, digName in ipairs(State.GetBoulderDigNames(target)) do
		fired = true
		pcall(function()
			remote:FireServer(digName, position)
		end)
	end

	return fired
end

function State.GetDigBoulderArgs()
	local target = State.GetSelectedDigBoulderTarget()
	if not target then
		return nil
	end

	local position = State.GetBoulderDigPosition(target)
	if not position then
		return nil
	end

	local digName = getBoulderAttributeDisplay(target) or State.GetBoulderDigName(target)
	return State.PackArgs(digName, position)
end

local function getBoulderEspColor(level)
	local normalized = tostring(level or ""):lower()

	if normalized == "legendary" or normalized == "mythic" then
		return Color3.fromRGB(255, 70, 70)
	end

	if normalized == "epic" then
		return Color3.fromRGB(190, 110, 255)
	end

	return Theme.Good
end

local function getBoulderAdorneePart(target)
	if not target or not target.Parent then
		return nil
	end

	if target:IsA("Model") then
		return target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart", true)
	end

	return target:IsA("BasePart") and target or nil
end

local function destroyBoulderEsp(target)
	local esp = BoulderEspObjects[target]
	if not esp then
		return
	end

	for _, object in pairs(esp) do
		if typeof(object) == "Instance" then
			pcall(function()
				object:Destroy()
			end)
		end
	end

	BoulderEspObjects[target] = nil
end

local function clearBoulderEsp()
	local targets = {}
	for target in pairs(BoulderEspObjects) do
		table.insert(targets, target)
	end

	for _, target in ipairs(targets) do
		destroyBoulderEsp(target)
	end
end

local function createBoulderEsp(target, labelText, espColor)
	local part = getBoulderAdorneePart(target)
	if not part then
		return nil
	end

	espColor = espColor or Theme.Good

	local highlight = create("Highlight", {
		Name = "CrystalToolsBoulderHighlight",
		Adornee = target,
		FillColor = espColor,
		FillTransparency = 0.82,
		OutlineColor = espColor,
		OutlineTransparency = 0,
		DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
		Enabled = true
	}, target)

	local billboard = create("BillboardGui", {
		Name = "CrystalToolsBoulderBillboard",
		Adornee = part,
		AlwaysOnTop = true,
		Enabled = true,
		LightInfluence = 0,
		MaxDistance = Config.BoulderEspMaxDistance,
		Size = UDim2.new(0, 130, 0, 28),
		StudsOffset = Vector3.new(0, 4, 0),
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	}, Gui)

	local label = create("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = labelText,
		TextColor3 = espColor,
		TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
		TextStrokeTransparency = 0.15,
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		TextTruncate = Enum.TextTruncate.AtEnd
	}, billboard)

	local esp = {
		Highlight = highlight,
		Billboard = billboard,
		Label = label
	}
	BoulderEspObjects[target] = esp
	return esp
end

local function refreshBoulderEsp()
	if not State.BoulderEspEnabled then
		clearBoulderEsp()
		return
	end

	local targets = getDigBoulderTargets()
	local labels = getBoulderOptionLabels(targets)
	local liveTargets = {}

	for _, target in ipairs(targets) do
		liveTargets[target] = true
		local part = getBoulderAdorneePart(target)
		if part then
			local levelText = getBoulderAttributeDisplay(target) or target.Name
			local labelText = labels[target] or levelText
			local espColor = getBoulderEspColor(levelText)
			local esp = BoulderEspObjects[target] or createBoulderEsp(target, labelText, espColor)
			if esp then
				if esp.Highlight then
					esp.Highlight.Adornee = target
					esp.Highlight.FillColor = espColor
					esp.Highlight.OutlineColor = espColor
					esp.Highlight.Enabled = true
				end
				if esp.Billboard then
					esp.Billboard.Adornee = part
					esp.Billboard.MaxDistance = Config.BoulderEspMaxDistance
					esp.Billboard.Enabled = true
				end
				if esp.Label then
					esp.Label.Text = labelText
					esp.Label.TextColor3 = espColor
				end
			end
		else
			destroyBoulderEsp(target)
		end
	end

	for target in pairs(BoulderEspObjects) do
		if not liveTargets[target] then
			destroyBoulderEsp(target)
		end
	end
end

local function setBoulderTarget(target, persist)
	local folder = getBouldersFolder()
	if not target or not folder or target.Parent ~= folder then
		return false
	end
	if not target:IsA("Model") or not getBoulderTargetCFrame(target) then
		return false
	end

	State.SelectedBoulderTarget = target
	State.SelectedBoulderName = getBoulderTargetDisplayName(target)
	BoulderDropdownList.Visible = false

	if updateBoulderDropdownText then
		updateBoulderDropdownText()
	end

	setStatus("Selected Boulder TP: " .. getBoulderTargetDisplayName(target), Theme.Muted)
	if persist ~= false then
		State.SaveConfig()
	end
	return true
end

function State.SetDigBoulderTarget(target, persist)
	local folder = getBouldersFolder()
	if not target or not folder or target.Parent ~= folder then
		return false
	end
	if not target:IsA("Model") or not getBoulderTargetCFrame(target) then
		return false
	end

	State.SelectedDigBoulderTarget = target
	State.SelectedDigBoulderName = State.GetDigBoulderDisplayName(target)
	UI.DigBoulderDropdownList.Visible = false

	if State.UpdateDigBoulderDropdownText then
		State.UpdateDigBoulderDropdownText()
	end

	setStatus("Selected Dig Boulder: " .. State.GetDigBoulderDisplayName(target), Theme.Muted)
	if persist ~= false then
		State.SaveConfig()
	end
	return true
end

function State.UpdateDigBoulderDropdownText()
	local target = State.GetSelectedDigBoulderTarget()
	if target then
		UI.DigBoulderDropdownButton.Text = "Dig: " .. State.GetDigBoulderDisplayName(target)
	elseif State.SelectedDigBoulderName then
		UI.DigBoulderDropdownButton.Text = "Dig gone: " .. tostring(State.SelectedDigBoulderName)
	else
		UI.DigBoulderDropdownButton.Text = "Select Dig Boulder"
	end
end

function State.RefreshDigBoulderDropdownOptions()
	for _, child in ipairs(UI.DigBoulderDropdownList:GetChildren()) do
		if child.Name == "DigBoulderOption" or child.Name == "DigBoulderEmptyOption" then
			child:Destroy()
		end
	end

	local targets = getDigBoulderTargets()
	local optionHeight = UI.IsMobile and 32 or 26
	local optionStep = optionHeight + 4

	if #targets == 0 then
		create("TextLabel", {
			Name = "DigBoulderEmptyOption",
			Size = UDim2.new(1, -12, 0, optionHeight),
			BackgroundTransparency = 1,
			Text = "No boulders found",
			TextColor3 = Theme.Muted,
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 8
		}, UI.DigBoulderDropdownList)
		UI.DigBoulderDropdownList.CanvasSize = UDim2.new(0, 0, 0, optionHeight + 12)
		State.UpdateDigBoulderDropdownText()
		return
	end

	local labels = getBoulderOptionLabels(targets)
	for index, target in ipairs(targets) do
		local selected = State.SelectedDigBoulderTarget == target
		local levelText = getBoulderAttributeDisplay(target) or target.Name
		local textColor = getBoulderEspColor(levelText)
		local option = create("TextButton", {
			Name = "DigBoulderOption",
			LayoutOrder = index,
			Size = UDim2.new(1, -12, 0, optionHeight),
			BackgroundColor3 = selected and Theme.Button or Theme.ButtonDark,
			BorderSizePixel = 0,
			Text = (selected and "> " or "") .. labels[target],
			TextColor3 = textColor,
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 8
		}, UI.DigBoulderDropdownList)
		styleSurface(option, 5, Theme.Accent)
		create("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8)
		}, option)

		connect(option.Activated, function()
			State.SetDigBoulderTarget(target)
		end)
	end

	UI.DigBoulderDropdownList.CanvasSize = UDim2.new(0, 0, 0, (#targets * optionStep) + 12)
	State.UpdateDigBoulderDropdownText()
end

function State.GetBoulderLevelName(target)
	local rawLevel = getBoulderAttributeDisplay(target)
	if not rawLevel and target then
		local targetName = tostring(target.Name or ""):lower()
		for _, levelName in ipairs({ "Celestial Apex", "Celestial", "Divine", "Secret", "Mythic", "Legendary", "Epic", "Rare", "Uncommon", "Common" }) do
			if targetName:find(levelName:lower(), 1, true) then
				rawLevel = levelName
				break
			end
		end
	end

	local text = tostring(rawLevel or "Unknown"):match("^%s*(.-)%s*$") or "Unknown"
	return text ~= "" and text or "Unknown"
end

function State.GetBoulderLevelRankText(level)
	local text = tostring(level or ""):lower()
	for _, entry in ipairs({
		{ "celestial apex", 100 },
		{ "celestial", 95 },
		{ "divine", 90 },
		{ "secret", 85 },
		{ "mythic", 80 },
		{ "legendary", 70 },
		{ "epic", 60 },
		{ "rare", 50 },
		{ "uncommon", 40 },
		{ "common", 30 }
	}) do
		if text:find(entry[1], 1, true) then
			return entry[2]
		end
	end

	return tonumber(text:match("%d+")) or 0
end

function State.GetBoulderLevelOptions()
	local counts = {}
	local levels = {}
	for _, target in ipairs(getDigBoulderTargets()) do
		local level = State.GetBoulderLevelName(target)
		if not counts[level] then
			table.insert(levels, level)
		end
		counts[level] = (counts[level] or 0) + 1
	end

	table.sort(levels, function(left, right)
		local leftRank = State.GetBoulderLevelRankText(left)
		local rightRank = State.GetBoulderLevelRankText(right)
		if leftRank ~= rightRank then
			return leftRank > rightRank
		end
		return tostring(left):lower() < tostring(right):lower()
	end)

	table.insert(levels, 1, "All")
	counts.All = #getDigBoulderTargets()
	return levels, counts
end

function State.GetSelectedBoulderLevelNames()
	State.SelectedBoulderLevels = State.SelectedBoulderLevels or {}
	if State.SelectedBoulderLevels.All then
		return { "All" }
	end

	local levels = {}
	for levelName, selected in pairs(State.SelectedBoulderLevels) do
		if selected and tostring(levelName) ~= "All" then
			table.insert(levels, tostring(levelName))
		end
	end

	table.sort(levels, function(left, right)
		local leftRank = State.GetBoulderLevelRankText(left)
		local rightRank = State.GetBoulderLevelRankText(right)
		if leftRank ~= rightRank then
			return leftRank > rightRank
		end
		return tostring(left):lower() < tostring(right):lower()
	end)

	if #levels == 0 then
		State.SelectedBoulderLevels.All = true
		return { "All" }
	end
	return levels
end

function State.GetBoulderLevelSummary()
	local levels = State.GetSelectedBoulderLevelNames()
	if #levels == 1 then
		return levels[1]
	end
	if #levels == 2 then
		return levels[1] .. ", " .. levels[2]
	end
	return tostring(#levels) .. " selected"
end

function State.UpdateBoulderLevelDropdownText()
	if UI.BoulderLevelDropdownButton then
		if not State.IsLockedScriptUnlocked() then
			UI.BoulderLevelDropdownButton.Text = "Level: LOCKED"
			return
		end
		UI.BoulderLevelDropdownButton.Text = "Level: " .. State.GetBoulderLevelSummary()
	end
end

function State.UpdateBoulderLevelFarmButton()
	if not UI.BoulderLevelFarmButton then
		return
	end

	if not State.IsLockedScriptUnlocked() then
		UI.BoulderLevelFarmButton.Text = "LEVEL LOCKED"
		UI.BoulderLevelFarmButton.BackgroundColor3 = Theme.ButtonDark
		return
	end

	if State.BoulderLevelFarmEnabled then
		UI.BoulderLevelFarmButton.Text = "LEVEL FARM ON"
		UI.BoulderLevelFarmButton.BackgroundColor3 = Theme.Good
	else
		UI.BoulderLevelFarmButton.Text = "LEVEL FARM OFF"
		UI.BoulderLevelFarmButton.BackgroundColor3 = Theme.ButtonDark
	end
end

function State.SetBoulderLevelFarmLevel(level, persist, selected)
	if not State.IsLockedScriptUnlocked() then
		return State.ShowLockedScriptMessage()
	end

	level = tostring(level or "All"):match("^%s*(.-)%s*$") or "All"
	if level == "" then
		level = "All"
	end

	State.SelectedBoulderLevels = State.SelectedBoulderLevels or {}
	if level == "All" then
		State.SelectedBoulderLevels = { All = true }
	elseif selected == nil then
		State.SelectedBoulderLevels[level] = not State.SelectedBoulderLevels[level] or nil
		State.SelectedBoulderLevels.All = nil
	elseif selected == true then
		State.SelectedBoulderLevels[level] = true
		State.SelectedBoulderLevels.All = nil
	else
		State.SelectedBoulderLevels[level] = nil
	end

	if next(State.SelectedBoulderLevels) == nil then
		State.SelectedBoulderLevels.All = true
	end

	State.SelectedBoulderLevel = State.GetBoulderLevelSummary()
	Config.BoulderLevelFarmLevel = State.SelectedBoulderLevel
	Config.BoulderLevelFarmLevels = State.GetSelectedBoulderLevelNames()
	State.BoulderHopNoTargetSince = nil
	State.LastBoulderHopTick = 0
	State.BoulderRejoinNoTargetSince = nil
	State.LastBoulderRejoinTick = 0
	State.UpdateBoulderLevelDropdownText()
	if persist ~= false then
		State.SaveConfig()
	end
	return Config.BoulderLevelFarmLevels
end

function State.RefreshBoulderLevelDropdownOptions()
	for _, child in ipairs(UI.BoulderLevelDropdownList:GetChildren()) do
		if child.Name == "BoulderLevelOption" or child.Name == "BoulderLevelEmptyOption" then
			child:Destroy()
		end
	end

	if not State.IsLockedScriptUnlocked() then
		create("TextLabel", {
			Name = "BoulderLevelEmptyOption",
			Size = UDim2.new(1, -12, 0, 26),
			BackgroundTransparency = 1,
			Text = "Locked",
			TextColor3 = Theme.Bad,
			TextSize = 12,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 8
		}, UI.BoulderLevelDropdownList)
		UI.BoulderLevelDropdownList.CanvasSize = UDim2.new(0, 0, 0, 38)
		State.UpdateBoulderLevelDropdownText()
		return
	end

	local levels, counts = State.GetBoulderLevelOptions()
	local optionHeight = UI.IsMobile and 32 or 26
	local optionStep = optionHeight + 4
	if #levels <= 1 then
		create("TextLabel", {
			Name = "BoulderLevelEmptyOption",
			Size = UDim2.new(1, -12, 0, optionHeight),
			BackgroundTransparency = 1,
			Text = "No boulder levels found",
			TextColor3 = Theme.Muted,
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 8
		}, UI.BoulderLevelDropdownList)
		UI.BoulderLevelDropdownList.CanvasSize = UDim2.new(0, 0, 0, optionHeight + 12)
		State.UpdateBoulderLevelDropdownText()
		return
	end

	for index, level in ipairs(levels) do
		local selected = State.SelectedBoulderLevels and State.SelectedBoulderLevels[level] == true
		local countText = counts[level] and (" x" .. tostring(counts[level])) or ""
		local option = create("TextButton", {
			Name = "BoulderLevelOption",
			LayoutOrder = index,
			Size = UDim2.new(1, -12, 0, optionHeight),
			BackgroundColor3 = selected and Theme.Button or Theme.ButtonDark,
			BorderSizePixel = 0,
			Text = (selected and "[x] " or "[ ] ") .. tostring(level) .. countText,
			TextColor3 = Theme.Text,
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 8
		}, UI.BoulderLevelDropdownList)
		styleSurface(option, 5, Theme.Accent)
		create("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8)
		}, option)

		connect(option.Activated, function()
			State.SetBoulderLevelFarmLevel(level)
			State.RefreshBoulderLevelDropdownOptions()
		end)
	end

	UI.BoulderLevelDropdownList.CanvasSize = UDim2.new(0, 0, 0, (#levels * optionStep) + 12)
	State.UpdateBoulderLevelDropdownText()
end

function State.IsBoulderLevelFarmMatch(target)
	if not target or not target.Parent then
		return false
	end

	if not State.SelectedBoulderLevels or State.SelectedBoulderLevels.All then
		return true
	end

	return State.SelectedBoulderLevels[State.GetBoulderLevelName(target)] == true
end

function State.GetBoulderLevelFarmPosition(target)
	if target and target:IsA("Model") then
		local ok, boxCFrame, boxSize = pcall(function()
			return target:GetBoundingBox()
		end)
		if ok and boxCFrame and boxSize then
			local underOffset = tonumber(Config.BoulderLevelFarmUnderOffset) or 6
			return boxCFrame.Position - Vector3.new(0, (boxSize.Y * 0.5) + underOffset, 0)
		end
	end

	local cframe = getBoulderTargetCFrame(target)
	return cframe and (cframe.Position - Vector3.new(0, tonumber(Config.BoulderLevelFarmUnderOffset) or 6, 0)) or nil
end

function State.GetNextBoulderLevelFarmTarget()
	local _, root = getCharacterParts(LocalPlayer)
	local nearestTarget = nil
	local nearestDistance = math.huge
	local fallbackTarget = nil

	for _, target in ipairs(getDigBoulderTargets()) do
		if State.IsBoulderLevelFarmMatch(target) then
			if not fallbackTarget then
				fallbackTarget = target
			end

			if root then
				local position = State.GetBoulderLevelFarmPosition(target)
				if position then
					local distance = (root.Position - position).Magnitude
					if distance < nearestDistance then
						nearestDistance = distance
						nearestTarget = target
					end
				end
			end
		end
	end

	return nearestTarget or fallbackTarget
end

function State.TweenBoulderLevelFarmToPosition(position)
	if not State.BoulderLevelFarmEnabled then
		return false
	end

	local _, root, humanoid = getCharacterParts(LocalPlayer)
	if not root or not position then
		return false
	end
	if humanoid then
		humanoid.Sit = false
	end

	local distance = (root.Position - position).Magnitude
	local duration = math.max(0.05, distance / math.max(1, tonumber(Config.BoulderLevelFarmSpeed) or 500))
	local tween = game:GetService("TweenService"):Create(
		root,
		TweenInfo.new(duration, Enum.EasingStyle.Linear),
		{ CFrame = CFrame.new(position, position + root.CFrame.LookVector) }
	)

	State.BoulderLevelFarmTween = tween
	tween:Play()
	local playbackState = tween.Completed:Wait()
	if State.BoulderLevelFarmTween == tween then
		State.BoulderLevelFarmTween = nil
	end
	return State.BoulderLevelFarmEnabled and playbackState == Enum.PlaybackState.Completed
end

function State.PrimeBoulderLevelFarmRoute()
	if State.BoulderLevelFarmPrimed then
		return true
	end

	local _, root = getCharacterParts(LocalPlayer)
	if not root then
		return false
	end
	if not State.TweenBoulderLevelFarmToPosition(root.Position + Vector3.new(0, Config.BoulderLevelFarmUpDistance or 300, 0)) then
		return false
	end

	_, root = getCharacterParts(LocalPlayer)
	if not root then
		return false
	end
	if not State.TweenBoulderLevelFarmToPosition(root.Position + (root.CFrame.LookVector * (Config.BoulderLevelFarmForwardDistance or 1800))) then
		return false
	end

	State.BoulderLevelFarmPrimed = true
	return true
end

function State.TweenBoulderLevelFarmToTarget(target)
	if not State.PrimeBoulderLevelFarmRoute() then
		return false
	end

	return State.TweenBoulderLevelFarmToPosition(State.GetBoulderLevelFarmPosition(target))
end

function State.RunBoulderLevelFarmLoop()
	if State.BoulderLevelFarmThreadRunning then
		return
	end

	State.BoulderLevelFarmThreadRunning = true
	task.spawn(function()
		while State.BoulderLevelFarmEnabled do
			if State.BoulderLevelFarmPrimed or State.PrimeBoulderLevelFarmRoute() then
				local target = State.GetNextBoulderLevelFarmTarget()
				if target then
					State.BoulderLevelFarmTarget = target
					State.SetDigBoulderTarget(target, false)
					if State.EnsureDigToolEquipped then
						State.EnsureDigToolEquipped()
					end
					setStatus("Tween to " .. State.GetDigBoulderDisplayName(target), Theme.Muted)
					State.TweenBoulderLevelFarmToTarget(target)
					while State.BoulderLevelFarmEnabled and State.GetSelectedDigBoulderTarget() == target and target.Parent and State.IsBoulderLevelFarmMatch(target) do
						if State.EnsureDigToolEquipped then
							State.EnsureDigToolEquipped()
						end
						local _, root = getCharacterParts(LocalPlayer)
						local position = State.GetBoulderLevelFarmPosition(target)
						if not position then
							break
						end

						if root then
							local distance = (root.Position - position).Magnitude
							if distance > (Config.BoulderLevelFarmReturnDistance or 25) then
								if State.DigReplayEnabled then
									State.SetDigReplayEnabled(false, false)
									setStatus("Returning to " .. State.GetDigBoulderDisplayName(target), Theme.Muted)
								end
							elseif not (State.HasPickaxeAtBoulder and State.HasPickaxeAtBoulder()) then
								if State.DigReplayEnabled then
									State.SetDigReplayEnabled(false, false)
								end
								if State.FirePickaxeRecover then
									State.FirePickaxeRecover()
								end
							elseif not State.DigReplayEnabled then
								State.SetDigReplayEnabled(true, false)
								setStatus("Level farm dig -> " .. State.GetDigBoulderDisplayName(target), Theme.Good)
							end
						end

						if not State.TweenBoulderLevelFarmToPosition(position) and not State.BoulderLevelFarmEnabled then
							break
						end

						if State.BoulderLevelFarmEnabled and State.GetSelectedDigBoulderTarget() == target and target.Parent and State.IsBoulderLevelFarmMatch(target) then
							if not (State.HasPickaxeAtBoulder and State.HasPickaxeAtBoulder()) then
								if State.DigReplayEnabled then
									State.SetDigReplayEnabled(false, false)
								end
								if State.FirePickaxeRecover then
									State.FirePickaxeRecover()
								end
							elseif not State.DigReplayEnabled then
								State.SetDigReplayEnabled(true, false)
								setStatus("Level farm dig -> " .. State.GetDigBoulderDisplayName(target), Theme.Good)
							end
						end

						task.wait(Config.BoulderLevelFarmTweenInterval or 0.1)
					end
					State.SetDigReplayEnabled(false, false)
					if State.BoulderLevelFarmEnabled and State.GetSelectedDigBoulderTarget() ~= target then
						setStatus("Boulder gone, waiting before next", Theme.Muted)
						task.wait(Config.BoulderLevelFarmNextDelay or 1.5)
					end
				else
					State.SetDigReplayEnabled(false, false)
					setStatus("No boulder level: " .. State.GetBoulderLevelSummary(), Theme.Muted)
					task.wait(1)
				end
			else
				State.SetDigReplayEnabled(false, false)
				task.wait(0.5)
			end
			task.wait(0.1)
		end

		State.SetDigReplayEnabled(false, false)
		State.BoulderLevelFarmTarget = nil
		State.BoulderLevelFarmThreadRunning = false
	end)
end

function State.SetBoulderLevelFarmEnabled(enabled, persist)
	if enabled == true and not State.IsLockedScriptUnlocked() then
		State.BoulderLevelFarmEnabled = false
		State.UpdateBoulderLevelFarmButton()
		return State.ShowLockedScriptMessage()
	end

	State.BoulderLevelFarmEnabled = enabled == true
	if not State.BoulderLevelFarmEnabled then
		if State.BoulderLevelFarmTween then
			pcall(function()
				State.BoulderLevelFarmTween:Cancel()
			end)
			State.BoulderLevelFarmTween = nil
		end
		State.SetDigReplayEnabled(false, false)
	else
		if State.PlayerTeleporting then
			setPlayerTeleporting(false, false)
		end
		if State.BoulderTeleporting then
			setBoulderTeleporting(false, false)
		end
		State.BoulderLevelFarmPrimed = false
		State.RunBoulderLevelFarmLoop()
	end

	State.UpdateBoulderLevelFarmButton()
	setStatus(State.BoulderLevelFarmEnabled and ("Boulder level farm ON -> " .. State.GetBoulderLevelSummary()) or "Boulder level farm OFF", State.BoulderLevelFarmEnabled and Theme.Good or Theme.Muted)
	if persist ~= false then
		State.SaveConfig()
	end
	return State.BoulderLevelFarmEnabled
end

function State.UpdateBoulderHopButton()
	if not UI.BoulderHopButton then
		return
	end

	if not State.IsLockedScriptUnlocked() then
		UI.BoulderHopButton.Text = "HOP LOCK"
		UI.BoulderHopButton.BackgroundColor3 = Theme.ButtonDark
		return
	end

	if State.BoulderHopEnabled then
		UI.BoulderHopButton.Text = "HOP ON"
		UI.BoulderHopButton.BackgroundColor3 = Theme.Good
	else
		UI.BoulderHopButton.Text = "HOP OFF"
		UI.BoulderHopButton.BackgroundColor3 = Theme.ButtonDark
	end
end

function State.UpdateBoulderRejoinButton()
	if not UI.BoulderRejoinButton then
		return
	end

	if not State.IsLockedScriptUnlocked() then
		UI.BoulderRejoinButton.Text = "RJ LOCK"
		UI.BoulderRejoinButton.BackgroundColor3 = Theme.ButtonDark
		return
	end

	if State.BoulderRejoinEnabled then
		UI.BoulderRejoinButton.Text = "RJ ON"
		UI.BoulderRejoinButton.BackgroundColor3 = Theme.Good
	else
		UI.BoulderRejoinButton.Text = "RJ OFF"
		UI.BoulderRejoinButton.BackgroundColor3 = Theme.ButtonDark
	end
end

function State.SetBoulderHopEnabled(enabled, persist)
	if enabled == true and not State.IsLockedScriptUnlocked() then
		State.BoulderHopEnabled = false
		State.BoulderHopTeleporting = false
		State.BoulderHopNoTargetSince = nil
		State.UpdateBoulderHopButton()
		return State.ShowLockedScriptMessage()
	end

	if enabled == true and State.BoulderRejoinEnabled then
		State.SetBoulderRejoinEnabled(false, false)
	end

	State.BoulderHopEnabled = enabled == true
	State.BoulderHopTeleporting = false
	State.BoulderHopNoTargetSince = nil
	State.LastBoulderHopTick = 0
	State.UpdateBoulderHopButton()
	setStatus(State.BoulderHopEnabled and "Boulder empty hop ON" or "Boulder empty hop OFF", State.BoulderHopEnabled and Theme.Good or Theme.Muted)
	if persist ~= false then
		State.SaveConfig()
	end
	return State.BoulderHopEnabled
end

function State.SetBoulderRejoinEnabled(enabled, persist)
	if enabled == true and not State.IsLockedScriptUnlocked() then
		State.BoulderRejoinEnabled = false
		State.BoulderRejoining = false
		State.BoulderRejoinNoTargetSince = nil
		State.UpdateBoulderRejoinButton()
		return State.ShowLockedScriptMessage()
	end

	if enabled == true and State.BoulderHopEnabled then
		State.SetBoulderHopEnabled(false, false)
	end

	State.BoulderRejoinEnabled = enabled == true
	State.BoulderRejoining = false
	State.BoulderRejoinNoTargetSince = nil
	State.LastBoulderRejoinTick = 0
	State.UpdateBoulderRejoinButton()
	setStatus(State.BoulderRejoinEnabled and "Boulder empty rejoin ON" or "Boulder empty rejoin OFF", State.BoulderRejoinEnabled and Theme.Good or Theme.Muted)
	if persist ~= false then
		State.SaveConfig()
	end
	return State.BoulderRejoinEnabled
end

function State.HopServer(sort)
	if not State.IsLockedScriptUnlocked() then
		return State.ShowLockedScriptMessage()
	end

	if State.BoulderHopTeleporting then
		return false
	end

	local httprequest = http_request or request
	if type(httprequest) ~= "function" and type(syn) == "table" then
		httprequest = syn.request
	end
	if type(httprequest) ~= "function" and type(http) == "table" then
		httprequest = http.request
	end
	if type(httprequest) ~= "function" then
		setStatus("http_request not found", Theme.Bad)
		return false
	end

	State.BoulderHopTeleporting = true
	local placeId = game.PlaceId
	local ok, requestResult = pcall(function()
		return httprequest({
			Url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=%s&limit=100&excludeFullGames=true", placeId, tostring(sort or Config.BoulderHopSort or "Asc"))
		})
	end)
	if not ok then
		State.BoulderHopTeleporting = false
		setStatus("Server hop request failed", Theme.Bad)
		return false
	end

	local bodyText = type(requestResult) == "table" and (requestResult.Body or requestResult.body) or tostring(requestResult or "")
	ok, requestResult = pcall(function()
		return game:GetService("HttpService"):JSONDecode(bodyText)
	end)
	if not ok or type(requestResult) ~= "table" or type(requestResult.data) ~= "table" then
		State.BoulderHopTeleporting = false
		setStatus("Server hop decode failed", Theme.Bad)
		return false
	end

	for _, server in next, requestResult.data do
		if type(server) == "table"
			and tonumber(server.playing)
			and tonumber(server.maxPlayers)
			and server.playing < server.maxPlayers
			and server.id ~= game.JobId then
			task.wait(0.2)
			ok = pcall(function()
				game:GetService("TeleportService"):TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
			end)
			if ok then
				return true
			end
		end
	end

	State.BoulderHopTeleporting = false
	setStatus("No hop server found", Theme.Muted)
	return false
end

function State.CountBoulderLevelFarmMatches()
	local matchingTargets = 0
	for _, target in ipairs(getDigBoulderTargets()) do
		if State.IsBoulderLevelFarmMatch(target) then
			matchingTargets += 1
		end
	end
	return matchingTargets
end

function State.TryBoulderEmptyHop()
	if not State.BoulderHopEnabled or State.BoulderHopTeleporting then
		return
	end

	local matchingTargets = State.CountBoulderLevelFarmMatches()
	if matchingTargets > 0 then
		State.BoulderHopNoTargetSince = nil
		return
	end

	local now = os.clock()
	if not State.BoulderHopNoTargetSince then
		State.BoulderHopNoTargetSince = now
		setStatus("No " .. State.GetBoulderLevelSummary() .. " boulder, waiting before hop", Theme.Muted)
		return
	end
	if now - State.BoulderHopNoTargetSince < (Config.BoulderHopEmptyDelay or 2) then
		return
	end

	setStatus(State.GetBoulderLevelSummary() .. " boulders empty, hopping server", Theme.Good)
	task.spawn(function()
		local ok, result = pcall(function()
			return State.HopServer(Config.BoulderHopSort or "Asc")
		end)
		if not ok or result ~= true then
			State.BoulderHopTeleporting = false
			State.BoulderHopNoTargetSince = os.clock()
		end
	end)
end

function State.RejoinCurrentServer()
	if not State.IsLockedScriptUnlocked() then
		return State.ShowLockedScriptMessage()
	end

	if State.BoulderRejoining then
		return false
	end

	State.BoulderRejoining = true
	setStatus("Rejoining in 2s...", Theme.Good)
	pcall(function()
		LocalPlayer:Kick("Rejoining...")
	end)
	task.wait(2)

	local ok = pcall(function()
		TeleportService:Teleport(game.PlaceId, LocalPlayer)
	end)
	if not ok then
		State.BoulderRejoining = false
		setStatus("Rejoin teleport failed", Theme.Bad)
		return false
	end

	return true
end

function State.TryBoulderEmptyRejoin()
	if not State.BoulderRejoinEnabled or State.BoulderRejoining then
		return
	end

	local matchingTargets = State.CountBoulderLevelFarmMatches()
	if matchingTargets > 0 then
		State.BoulderRejoinNoTargetSince = nil
		return
	end

	local now = os.clock()
	if not State.BoulderRejoinNoTargetSince then
		State.BoulderRejoinNoTargetSince = now
		setStatus("No " .. State.GetBoulderLevelSummary() .. " boulder, waiting before rejoin", Theme.Muted)
		return
	end
	if now - State.BoulderRejoinNoTargetSince < (Config.BoulderHopEmptyDelay or 2) then
		return
	end

	setStatus(State.GetBoulderLevelSummary() .. " boulders empty, rejoining", Theme.Good)
	task.spawn(function()
		local ok, result = pcall(function()
			return State.RejoinCurrentServer()
		end)
		if not ok or result ~= true then
			State.BoulderRejoining = false
			State.BoulderRejoinNoTargetSince = os.clock()
		end
	end)
end

function State.BoulderHopHeartbeat()
	if not State.BoulderHopEnabled then
		return
	end

	local now = os.clock()
	if now - State.LastBoulderHopTick < (Config.BoulderHopInterval or 1) then
		return
	end
	State.LastBoulderHopTick = now
	State.TryBoulderEmptyHop()
end

function State.BoulderRejoinHeartbeat()
	if not State.BoulderRejoinEnabled then
		return
	end

	local now = os.clock()
	if now - State.LastBoulderRejoinTick < (Config.BoulderHopInterval or 1) then
		return
	end
	State.LastBoulderRejoinTick = now
	State.TryBoulderEmptyRejoin()
end

local function getSelectedBombNames()
	local names = {}
	for itemName, selected in pairs(State.SelectedBombItems) do
		if selected then
			table.insert(names, itemName)
		end
	end
	table.sort(names)
	return names
end

local function syncBombSelectionConfig()
	local names = getSelectedBombNames()
	Config.BombItemNames = names
	Config.BombItemName = names[1]
	return names
end

local function setBombSelected(itemName, selected)
	itemName = tostring(itemName or "")
	if itemName == "" then
		return
	end

	State.SelectedBombItems[itemName] = selected == true or nil
	syncBombSelectionConfig()
	State.SaveGearShopConfig()
	if updateBombDropdownText then
		updateBombDropdownText()
	end
end

function State.GetSelectedRadarNames()
	local names = {}
	for itemName, selected in pairs(State.SelectedRadarItems or {}) do
		if selected then
			table.insert(names, itemName)
		end
	end
	table.sort(names)
	return names
end

function State.SyncRadarSelectionConfig()
	local names = State.GetSelectedRadarNames()
	Config.RadarItemNames = names
	Config.RadarItemName = names[1]
	return names
end

function State.SetRadarSelected(itemName, selected)
	itemName = tostring(itemName or "")
	if itemName == "" then
		return
	end

	State.SelectedRadarItems[itemName] = selected == true or nil
	State.SyncRadarSelectionConfig()
	State.SaveGearShopConfig()
	if State.UpdateRadarDropdownText then
		State.UpdateRadarDropdownText()
	end
end

function RuneDrop.IsRuneItemName(itemName)
	local text = tostring(itemName or ""):match("^%s*(.-)%s*$") or ""
	if text == "" then
		return false
	end

	local lowerText = text:lower()
	return lowerText == "rune" or lowerText:match("%s+rune$") ~= nil
end

function RuneDrop.GetInventoryTools()
	local tools = {}
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	local character = LocalPlayer.Character

	if backpack then
		for _, item in ipairs(backpack:GetChildren()) do
			if item:IsA("Tool") then
				table.insert(tools, item)
			end
		end
	end

	if character then
		for _, item in ipairs(character:GetChildren()) do
			if item:IsA("Tool") then
				table.insert(tools, item)
			end
		end
	end

	return tools
end

function RuneDrop.GetToolUses(item)
	if not item then
		return 1, false
	end

	for _, attributeName in ipairs({ "Uses", "uses", "Use", "Count", "Amount", "Quantity", "Stack", "Stacks", "Charges" }) do
		local value = item:GetAttribute(attributeName)
		local amount = tonumber(value)
		if amount and amount > 0 then
			return math.floor(amount), true
		end
	end

	for _, child in ipairs(item:GetDescendants()) do
		local childName = tostring(child.Name or ""):lower()
		if childName == "uses" or childName == "use" or childName == "count" or childName == "amount" or childName == "quantity" or childName == "stack" or childName == "stacks" or childName == "charges" then
			if child:IsA("ValueBase") then
				local amount = tonumber(child.Value)
				if amount and amount > 0 then
					return math.floor(amount), true
				end
			elseif child:IsA("TextLabel") or child:IsA("TextBox") then
				local amount = tonumber(tostring(child.Text or ""):match("(%d+)"))
				if amount and amount > 0 then
					return math.floor(amount), true
				end
			end
		end
	end

	return 1, false
end

function RuneDrop.GetInventoryCounts()
	local counts = {}
	for _, item in ipairs(RuneDrop.GetInventoryTools()) do
		local itemName = tostring(item and item.Name or "")
		if RuneDrop.IsRuneItemName(itemName) then
			local uses = RuneDrop.GetToolUses(item)
			counts[itemName] = (counts[itemName] or 0) + uses
		end
	end
	return counts
end

function RuneDrop.GetInventoryNames()
	local counts = RuneDrop.GetInventoryCounts()
	local names = {}
	for itemName in pairs(counts) do
		table.insert(names, itemName)
	end
	table.sort(names, function(left, right)
		return left:lower() < right:lower()
	end)
	return names, counts
end

function RuneDrop.GetSelectedNames()
	local names = {}
	for itemName, selected in pairs(State.SelectedRuneItems) do
		if selected then
			table.insert(names, itemName)
		end
	end
	table.sort(names, function(left, right)
		return left:lower() < right:lower()
	end)
	return names
end

function RuneDrop.SetSelected(itemName, selected)
	itemName = tostring(itemName or "")
	if itemName == "" then
		return
	end

	State.SelectedRuneItems[itemName] = selected == true or nil
	if RuneDrop.UpdateDropdownText then
		RuneDrop.UpdateDropdownText()
	end
	State.SaveConfig()
end

function RuneDrop.UpdateAmount(value)
	local amount = math.floor(tonumber(value or UI.RuneAmountInput.Text) or State.RuneDropAmount or 1)
	amount = math.max(1, amount)
	State.RuneDropAmount = amount
	UI.RuneAmountInput.Text = tostring(amount)
	State.SaveConfig()
	return amount
end

local function getBombShopConfig()
	if BombShopConfig then
		return BombShopConfig
	end

	local modules = ReplicatedStorage:FindFirstChild("Modules")
	local configModule = modules and modules:FindFirstChild("BombShopConfig")
	if not (configModule and configModule:IsA("ModuleScript")) then
		return nil
	end

	local ok, result = pcall(require, configModule)
	if ok and type(result) == "table" then
		BombShopConfig = result
		return BombShopConfig
	end

	return nil
end

local function getBombShopStock(forceRefresh)
	local now = os.clock()
	if not forceRefresh and LastBombShopStockQuery > 0 and BombShopStockCache and now - LastBombShopStockQuery < Config.BombStockRefreshInterval then
		return BombShopStockCache
	end

	local queryRemote = Remotes and Remotes:FindFirstChild("BombShopQuery")
	if queryRemote and queryRemote:IsA("RemoteFunction") then
		local ok, result = pcall(function()
			return queryRemote:InvokeServer()
		end)

		if ok and type(result) == "table" and type(result.stock) == "table" then
			BombShopStockCache = result.stock
			LastBombShopStockQuery = now
			return BombShopStockCache
		end
	end

	return BombShopStockCache or {}
end

local function getBombDisplayName(itemName)
	local config = getBombShopConfig()
	local bombConfig = config and config.BOMBS and config.BOMBS[itemName]
	return (bombConfig and bombConfig.displayName) or itemName
end

local function getLegacyGearShopItemsFolder()
	local stockValues = ReplicatedStorage:FindFirstChild("StockValues")
	local gearShop = stockValues and stockValues:FindFirstChild("GearShop")
	return gearShop and gearShop:FindFirstChild("Items")
end

local function isBombStockItem(item)
	if not item then
		return false
	end

	local itemName = item.Name:lower()
	return itemName:find("bomb", 1, true) ~= nil
		or itemName:find("dynamite", 1, true) ~= nil
		or itemName:find("explosive", 1, true) ~= nil
end

local function getBombShopUiHolder()
	local ui = ReplicatedStorage:FindFirstChild("UI")
	local bombShop = ui and ui:FindFirstChild("BombShop")
	local main = bombShop and bombShop:FindFirstChild("Main")
	local bombFrame = main and main:FindFirstChild("BombFrame")
	return bombFrame and bombFrame:FindFirstChild("Holder")
end

local function sortBombItems(bombItems)
	table.sort(bombItems, function(left, right)
		if left.Price and right.Price and left.Price ~= right.Price then
			return left.Price < right.Price
		end

		return tostring(left.DisplayName or left.Name):lower() < tostring(right.DisplayName or right.Name):lower()
	end)
	return bombItems
end

local function getBombStockValueObjects(forceRefresh)
	local bombItems = {}
	local config = getBombShopConfig()
	local stock = getBombShopStock(forceRefresh)

	if config and type(config.BOMBS) == "table" then
		for itemName, itemConfig in pairs(config.BOMBS) do
			if itemConfig.enabled ~= false then
				table.insert(bombItems, {
					Name = itemName,
					DisplayName = itemConfig.displayName or itemName,
					Stock = tonumber(stock[itemName]) or 0,
					Price = itemConfig.cashPrice,
					Rarity = itemConfig.rarity
				})
			end
		end

		return sortBombItems(bombItems)
	end

	local holder = getBombShopUiHolder()
	if holder then
		for _, item in ipairs(holder:GetChildren()) do
			if item:IsA("CanvasGroup") and isBombStockItem(item) then
				local nameLabel = item:FindFirstChild("BombName", true)
				local stockLabel = item:FindFirstChild("StockAmount", true)
				table.insert(bombItems, {
					Name = item.Name,
					DisplayName = nameLabel and nameLabel.Text or item.Name,
					Stock = stockLabel and parseNumber(stockLabel.Text) or nil
				})
			end
		end

		if #bombItems > 0 then
			return sortBombItems(bombItems)
		end
	end

	local legacyItems = getLegacyGearShopItemsFolder()
	if legacyItems then
		for _, item in ipairs(legacyItems:GetChildren()) do
			if isBombStockItem(item) then
				local stockValue = item:IsA("ValueBase") and tonumber(item.Value) or nil
				table.insert(bombItems, {
					Name = item.Name,
					DisplayName = item.Name,
					Stock = stockValue,
					Instance = item
				})
			end
		end
	end

	return sortBombItems(bombItems)
end

local function getBombStock(valueObject)
	if type(valueObject) == "table" then
		return valueObject.Stock, valueObject
	end

	if valueObject and valueObject:IsA("ValueBase") then
		return tonumber(valueObject.Value) or 0, valueObject
	end

	return nil, valueObject
end

local function getSelectedBombStockObjects(forceRefresh)
	local selectedNames = getSelectedBombNames()
	if #selectedNames == 0 then
		return {}, "No bombs selected"
	end

	local availableItems = getBombStockValueObjects(forceRefresh)
	if #availableItems == 0 then
		return {}, "Bomb stock not found"
	end

	local selectedItems = {}
	for _, selectedName in ipairs(selectedNames) do
		for _, item in ipairs(availableItems) do
			if item.Name == selectedName or item.DisplayName == selectedName then
				table.insert(selectedItems, item)
				break
			end
		end
	end

	if #selectedItems == 0 then
		return selectedItems, "Selected bombs not found"
	end

	return selectedItems
end

function State.GetGearShopPurchaseItems(forceRefresh)
	if State.GearShopBuyAll then
		local availableItems = getBombStockValueObjects(forceRefresh)
		if #availableItems == 0 then
			return {}, "Gear shop stock not found"
		end
		return availableItems
	end

	return getSelectedBombStockObjects(forceRefresh)
end

function State.GetRadarShopConfig()
	if State.RadarShopConfig then
		return State.RadarShopConfig
	end

	local modules = ReplicatedStorage:FindFirstChild("Modules")
	local configModule = modules and modules:FindFirstChild("RadarShopConfig")
	if not (configModule and configModule:IsA("ModuleScript")) then
		return nil
	end

	local ok, result = pcall(require, configModule)
	if ok and type(result) == "table" then
		State.RadarShopConfig = result
		return State.RadarShopConfig
	end

	return nil
end

function State.GetRadarShopStock(forceRefresh)
	local now = os.clock()
	if not forceRefresh and State.LastRadarShopStockQuery > 0 and State.RadarShopStockCache and now - State.LastRadarShopStockQuery < (Config.RadarStockRefreshInterval or Config.BombStockRefreshInterval or 1) then
		return State.RadarShopStockCache
	end

	local queryRemote = Remotes and Remotes:FindFirstChild("RadarShopQuery")
	if queryRemote and queryRemote:IsA("RemoteFunction") then
		local ok, result = pcall(function()
			return queryRemote:InvokeServer()
		end)

		if ok and type(result) == "table" and type(result.stock) == "table" then
			State.RadarShopStockCache = result.stock
			State.LastRadarShopStockQuery = now
			return State.RadarShopStockCache
		end
	end

	return State.RadarShopStockCache or {}
end

function State.GetRadarDisplayName(itemName)
	local config = State.GetRadarShopConfig()
	local radarConfig = config and config.RADARS and config.RADARS[itemName]
	return (radarConfig and radarConfig.displayName) or itemName
end

function State.SortRadarItems(radarItems)
	table.sort(radarItems, function(left, right)
		if left.Price and right.Price and left.Price ~= right.Price then
			return left.Price < right.Price
		end

		return tostring(left.DisplayName or left.Name):lower() < tostring(right.DisplayName or right.Name):lower()
	end)
	return radarItems
end

function State.GetRadarShopUiHolder()
	local ui = ReplicatedStorage:FindFirstChild("UI")
	local radarShop = ui and ui:FindFirstChild("RadarShop")
	local main = radarShop and radarShop:FindFirstChild("Main")
	local radarFrame = main and main:FindFirstChild("RadarFrame")
	return radarFrame and radarFrame:FindFirstChild("Holder")
end

function State.GetRadarStockValueObjects(forceRefresh)
	local radarItems = {}
	local config = State.GetRadarShopConfig()
	local stock = State.GetRadarShopStock(forceRefresh)

	if config and type(config.RADARS) == "table" then
		for itemName, itemConfig in pairs(config.RADARS) do
			if itemConfig.enabled ~= false then
				table.insert(radarItems, {
					Name = itemName,
					DisplayName = itemConfig.displayName or itemName,
					Stock = tonumber(stock[itemName]) or 0,
					Price = itemConfig.cashPrice,
					Rarity = itemConfig.rarity
				})
			end
		end

		return State.SortRadarItems(radarItems)
	end

	local holder = State.GetRadarShopUiHolder()
	if holder then
		for _, item in ipairs(holder:GetChildren()) do
			if item:IsA("CanvasGroup") and tostring(item.Name or ""):lower():find("radar", 1, true) then
				local nameLabel = item:FindFirstChild("BombName", true)
				local stockLabel = item:FindFirstChild("StockAmount", true)
				table.insert(radarItems, {
					Name = item.Name,
					DisplayName = nameLabel and nameLabel.Text or item.Name,
					Stock = stockLabel and parseNumber(stockLabel.Text) or nil
				})
			end
		end
	end

	return State.SortRadarItems(radarItems)
end

function State.GetRadarStock(valueObject)
	if type(valueObject) == "table" then
		return valueObject.Stock, valueObject
	end

	if valueObject and valueObject:IsA("ValueBase") then
		return tonumber(valueObject.Value) or 0, valueObject
	end

	return nil, valueObject
end

function State.GetSelectedRadarStockObjects(forceRefresh)
	local selectedNames = State.GetSelectedRadarNames()
	if #selectedNames == 0 then
		return {}, "No radar selected"
	end

	local availableItems = State.GetRadarStockValueObjects(forceRefresh)
	if #availableItems == 0 then
		return {}, "Radar stock not found"
	end

	local selectedItems = {}
	for _, selectedName in ipairs(selectedNames) do
		for _, item in ipairs(availableItems) do
			if item.Name == selectedName or item.DisplayName == selectedName then
				table.insert(selectedItems, item)
				break
			end
		end
	end

	if #selectedItems == 0 then
		return selectedItems, "Selected radar not found"
	end

	return selectedItems
end

function State.GetRadarShopPurchaseItems(forceRefresh)
	if State.RadarShopBuyAll then
		local availableItems = State.GetRadarStockValueObjects(forceRefresh)
		if #availableItems == 0 then
			return {}, "Radar shop stock not found"
		end
		return availableItems
	end

	return State.GetSelectedRadarStockObjects(forceRefresh)
end

function State.UpdateRadarDropdownText()
	if State.RadarShopBuyAll then
		UI.RadarDropdownButton.Text = "Radar: Buy All"
		return
	end

	local names = State.SyncRadarSelectionConfig()
	if #names == 0 then
		UI.RadarDropdownButton.Text = "Select Radar"
	elseif #names == 1 then
		UI.RadarDropdownButton.Text = "Radar: " .. State.GetRadarDisplayName(names[1])
	else
		UI.RadarDropdownButton.Text = ("Radar: %d selected"):format(#names)
	end
end

function State.RefreshRadarDropdownOptions()
	for _, child in ipairs(UI.RadarDropdownList:GetChildren()) do
		if child.Name == "RadarOption" or child.Name == "RadarEmptyOption" then
			child:Destroy()
		end
	end

	local radarItems = State.GetRadarStockValueObjects(true)
	local optionHeight = UI.IsMobile and 32 or 26
	local optionStep = optionHeight + 4
	if #radarItems == 0 then
		create("TextLabel", {
			Name = "RadarEmptyOption",
			Size = UDim2.new(1, -12, 0, optionHeight),
			BackgroundTransparency = 1,
			Text = "No radar stock found",
			TextColor3 = Theme.Muted,
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 8
		}, UI.RadarDropdownList)
		UI.RadarDropdownList.CanvasSize = UDim2.new(0, 0, 0, optionHeight + 12)
		State.UpdateRadarDropdownText()
		return
	end

	for index, item in ipairs(radarItems) do
		local itemName = item.Name
		local displayName = item.DisplayName or State.GetRadarDisplayName(itemName)
		local selected = State.SelectedRadarItems[itemName] == true
		local stock = State.GetRadarStock(item)
		local stockText = stock ~= nil and (" | stock " .. tostring(stock)) or ""
		local option = create("TextButton", {
			Name = "RadarOption",
			LayoutOrder = index,
			Size = UDim2.new(1, -12, 0, optionHeight),
			BackgroundColor3 = selected and Theme.Button or Theme.ButtonDark,
			BorderSizePixel = 0,
			Text = (selected and "[x] " or "[ ] ") .. displayName .. stockText,
			TextColor3 = Theme.Text,
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 8
		}, UI.RadarDropdownList)
		styleSurface(option, 5, Theme.Accent)
		create("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8)
		}, option)

		connect(option.Activated, function()
			State.SetRadarSelected(itemName, not State.SelectedRadarItems[itemName])
			State.RefreshRadarDropdownOptions()
		end)
	end

	UI.RadarDropdownList.CanvasSize = UDim2.new(0, 0, 0, (#radarItems * optionStep) + 12)
	State.UpdateRadarDropdownText()
end

function State.GetRadarPurchaseRemote()
	return Remotes and Remotes:FindFirstChild("RadarBuyRequest")
end

function State.FireRadarPurchase(itemName)
	local purchase = State.GetRadarPurchaseRemote()
	if not purchase then
		return false, "Radar purchase remote not found"
	end

	if purchase:IsA("RemoteEvent") then
		return pcall(function()
			purchase:FireServer(itemName)
		end)
	end

	if purchase:IsA("RemoteFunction") then
		local ok, result = pcall(function()
			return purchase:InvokeServer(itemName)
		end)
		if not ok then
			return false, result
		end
		if result == false then
			return false, "Purchase rejected"
		end
		if type(result) == "table" and (result.ok == false or result.success == false) then
			return false, result.message or result.error or "Purchase rejected"
		end
		return true, result
	end

	return false, "Unsupported radar purchase remote type: " .. tostring(purchase.ClassName)
end

function State.SetBuyRadarStatus(text, color, force)
	if force or State.LastBuyRadarStatus ~= text then
		State.LastBuyRadarStatus = text
		setStatus(text, color)
	end
end

function State.UpdateRadarShopBuyAllButton()
	if State.RadarShopBuyAll and State.BuyingRadar then
		UI.BuyAllRadarButton.Text = "Buy All Radar ON"
		UI.BuyAllRadarButton.BackgroundColor3 = Theme.Good
	else
		UI.BuyAllRadarButton.Text = "Buy All Radar OFF"
		UI.BuyAllRadarButton.BackgroundColor3 = Theme.ButtonDark
	end
end

function State.SetRadarShopBuyAll(enabled, persist)
	State.RadarShopBuyAll = enabled == true
	Config.RadarShopBuyAll = State.RadarShopBuyAll
	State.UpdateRadarShopBuyAllButton()
	State.UpdateBuyRadarButtonText()
	State.UpdateRadarDropdownText()
	if UI.RadarDropdownList.Visible then
		State.RefreshRadarDropdownOptions()
	end
	if persist ~= false then
		State.SaveGearShopConfig()
	end

	return State.RadarShopBuyAll
end

function State.UpdateBuyRadarButtonText()
	if State.BuyingRadar then
		UI.BuyRadarButton.Text = "Stop Buying Radar"
		UI.BuyRadarButton.BackgroundColor3 = Theme.Bad
	else
		UI.BuyRadarButton.Text = "Start Buy Radar"
		UI.BuyRadarButton.BackgroundColor3 = Theme.Button
	end
end

function State.SetBuyingRadar(enabled, persist)
	State.LastBuyRadarStatus = nil
	local purchaseItems, selectionReason
	if enabled == true then
		purchaseItems, selectionReason = State.GetRadarShopPurchaseItems(true)
	end

	if enabled == true and #purchaseItems == 0 then
		State.BuyingRadar = false
		State.RadarShopBuyAll = false
		Config.RadarShopBuyAll = false
		Config.RadarShopAutoBuyEnabled = false
		Config.RadarShopStartBuy = false
		State.UpdateRadarShopBuyAllButton()
		State.UpdateBuyRadarButtonText()
		State.UpdateRadarDropdownText()
		State.RefreshRadarDropdownOptions()
		UI.RadarDropdownList.Visible = true
		State.SetBuyRadarStatus(selectionReason or "Select radar before starting", Theme.Bad, true)
		if persist ~= false then
			State.SaveGearShopConfig()
		end
		return
	end

	State.BuyingRadar = enabled == true
	if not State.BuyingRadar and State.RadarShopBuyAll then
		State.RadarShopBuyAll = false
		Config.RadarShopBuyAll = false
	end
	Config.RadarShopAutoBuyEnabled = State.BuyingRadar
	Config.RadarShopStartBuy = State.BuyingRadar
	State.UpdateRadarShopBuyAllButton()
	State.UpdateBuyRadarButtonText()
	State.UpdateRadarDropdownText()

	if State.BuyingRadar then
		State.LastBuyRadarTick = 0
		UI.RadarDropdownList.Visible = false
		local modeText = State.RadarShopBuyAll and "all radar" or ("%d selected"):format(#purchaseItems)
		State.SetBuyRadarStatus("Auto Radar Shop ON | " .. modeText, Theme.Good, true)
		log("Auto Radar Shop ON", State.RadarShopBuyAll and "BuyAll" or table.concat(State.GetSelectedRadarNames(), ", "))
	else
		State.SetBuyRadarStatus("Auto Radar Shop stopped", Theme.Muted, true)
		log("Auto Radar Shop OFF")
	end

	if persist ~= false then
		State.SaveGearShopConfig()
	end
end

updatePlayerDropdownText = function()
	local player = getTeleportTargetPlayer()
	if player then
		PlayerDropdownButton.Text = "Player: " .. getPlayerDisplayName(player)
	elseif State.SelectedTeleportPlayerName then
		PlayerDropdownButton.Text = "Player left: " .. tostring(State.SelectedTeleportPlayerName)
	else
		PlayerDropdownButton.Text = "Select player"
	end
end

refreshPlayerDropdownOptions = function()
	for _, child in ipairs(PlayerDropdownList:GetChildren()) do
		if child.Name == "PlayerOption" or child.Name == "PlayerEmptyOption" then
			child:Destroy()
		end
	end

	local playerList = getTeleportablePlayers()
	local optionHeight = UI.IsMobile and 32 or 26
	local optionStep = optionHeight + 4

	if #playerList == 0 then
		create("TextLabel", {
			Name = "PlayerEmptyOption",
			Size = UDim2.new(1, -12, 0, optionHeight),
			BackgroundTransparency = 1,
			Text = "No other players",
			TextColor3 = Theme.Muted,
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 8
		}, PlayerDropdownList)
		PlayerDropdownList.CanvasSize = UDim2.new(0, 0, 0, optionHeight + 12)
		updatePlayerDropdownText()
		return
	end

	for index, player in ipairs(playerList) do
		local selected = State.SelectedTeleportPlayerUserId == player.UserId
		local option = create("TextButton", {
			Name = "PlayerOption",
			LayoutOrder = index,
			Size = UDim2.new(1, -12, 0, optionHeight),
			BackgroundColor3 = selected and Theme.Button or Theme.ButtonDark,
			BorderSizePixel = 0,
			Text = (selected and "> " or "") .. getPlayerDisplayName(player),
			TextColor3 = Theme.Text,
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 8
		}, PlayerDropdownList)
		styleSurface(option, 5, Theme.Accent)
		create("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8)
		}, option)

		connect(option.Activated, function()
			setTeleportPlayer(player)
		end)
	end

	PlayerDropdownList.CanvasSize = UDim2.new(0, 0, 0, (#playerList * optionStep) + 12)
	updatePlayerDropdownText()
end

updateBoulderDropdownText = function()
	local target = getSelectedBoulderTarget()
	if target then
		BoulderDropdownButton.Text = "Boulder: " .. getBoulderTargetDisplayName(target)
	elseif State.SelectedBoulderName then
		BoulderDropdownButton.Text = "Boulder gone: " .. tostring(State.SelectedBoulderName)
	else
		BoulderDropdownButton.Text = "Select boulder"
	end
end

refreshBoulderDropdownOptions = function()
	for _, child in ipairs(BoulderDropdownList:GetChildren()) do
		if child.Name == "BoulderOption" or child.Name == "BoulderEmptyOption" then
			child:Destroy()
		end
	end

	local targets = getDigBoulderTargets()
	local optionHeight = UI.IsMobile and 32 or 26
	local optionStep = optionHeight + 4

	if #targets == 0 then
		create("TextLabel", {
			Name = "BoulderEmptyOption",
			Size = UDim2.new(1, -12, 0, optionHeight),
			BackgroundTransparency = 1,
			Text = "No boulders found",
			TextColor3 = Theme.Muted,
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 8
		}, BoulderDropdownList)
		BoulderDropdownList.CanvasSize = UDim2.new(0, 0, 0, optionHeight + 12)
		updateBoulderDropdownText()
		return
	end

	local labels = getBoulderOptionLabels(targets)
	for index, target in ipairs(targets) do
		local selected = State.SelectedBoulderTarget == target
		local levelText = getBoulderAttributeDisplay(target) or target.Name
		local textColor = getBoulderEspColor(levelText)
		local option = create("TextButton", {
			Name = "BoulderOption",
			LayoutOrder = index,
			Size = UDim2.new(1, -12, 0, optionHeight),
			BackgroundColor3 = selected and Theme.Button or Theme.ButtonDark,
			BorderSizePixel = 0,
			Text = (selected and "> " or "") .. labels[target],
			TextColor3 = textColor,
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 8
		}, BoulderDropdownList)
		styleSurface(option, 5, Theme.Accent)
		create("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8)
		}, option)

		connect(option.Activated, function()
			setBoulderTarget(target)
		end)
	end

	BoulderDropdownList.CanvasSize = UDim2.new(0, 0, 0, (#targets * optionStep) + 12)
	updateBoulderDropdownText()
end

updateBombDropdownText = function()
	if State.GearShopBuyAll then
		BombDropdownButton.Text = "Gear: Buy All"
		return
	end

	local names = syncBombSelectionConfig()
	if #names == 0 then
		BombDropdownButton.Text = "Select gear"
	elseif #names == 1 then
		BombDropdownButton.Text = "Gear: " .. getBombDisplayName(names[1])
	else
		BombDropdownButton.Text = ("Gear: %d selected"):format(#names)
	end
end

refreshBombDropdownOptions = function()
	for _, child in ipairs(BombDropdownList:GetChildren()) do
		if child.Name == "BombOption" or child.Name == "BombEmptyOption" then
			child:Destroy()
		end
	end

	local bombItems = getBombStockValueObjects(true)
	local optionHeight = UI.IsMobile and 32 or 26
	local optionStep = optionHeight + 4
	if #bombItems == 0 then
		create("TextLabel", {
			Name = "BombEmptyOption",
			Size = UDim2.new(1, -12, 0, optionHeight),
			BackgroundTransparency = 1,
			Text = "No bomb stock found",
			TextColor3 = Theme.Muted,
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 8
		}, BombDropdownList)
		BombDropdownList.CanvasSize = UDim2.new(0, 0, 0, optionHeight + 12)
		updateBombDropdownText()
		return
	end

	for index, item in ipairs(bombItems) do
		local itemName = item.Name
		local displayName = item.DisplayName or getBombDisplayName(itemName)
		local selected = State.SelectedBombItems[itemName] == true
		local stock = getBombStock(item)
		local stockText = stock ~= nil and (" | stock " .. tostring(stock)) or ""
		local option = create("TextButton", {
			Name = "BombOption",
			LayoutOrder = index,
			Size = UDim2.new(1, -12, 0, optionHeight),
			BackgroundColor3 = selected and Theme.Button or Theme.ButtonDark,
			BorderSizePixel = 0,
			Text = (selected and "[x] " or "[ ] ") .. displayName .. stockText,
			TextColor3 = Theme.Text,
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 8
		}, BombDropdownList)
		styleSurface(option, 5, Theme.Accent)
		create("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8)
		}, option)

		connect(option.Activated, function()
			setBombSelected(itemName, not State.SelectedBombItems[itemName])
			refreshBombDropdownOptions()
		end)
	end

	BombDropdownList.CanvasSize = UDim2.new(0, 0, 0, (#bombItems * optionStep) + 12)
	updateBombDropdownText()
end

function RuneDrop.UpdateDropdownText()
	local names = RuneDrop.GetSelectedNames()
	if #names == 0 then
		UI.RuneDropdownButton.Text = "Select Rune"
	elseif #names == 1 then
		UI.RuneDropdownButton.Text = "Rune: " .. names[1]
	else
		UI.RuneDropdownButton.Text = ("Runes: %d selected"):format(#names)
	end
end

function RuneDrop.RefreshDropdownOptions()
	for _, child in ipairs(UI.RuneDropdownList:GetChildren()) do
		if child.Name == "RuneOption" or child.Name == "RuneEmptyOption" then
			child:Destroy()
		end
	end

	local runeNames, counts = RuneDrop.GetInventoryNames()
	local optionHeight = UI.IsMobile and 32 or 26
	local optionStep = optionHeight + 4
	if #runeNames == 0 then
		create("TextLabel", {
			Name = "RuneEmptyOption",
			Size = UDim2.new(1, -12, 0, optionHeight),
			BackgroundTransparency = 1,
			Text = "No Rune in backpack",
			TextColor3 = Theme.Muted,
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 8
		}, UI.RuneDropdownList)
		UI.RuneDropdownList.CanvasSize = UDim2.new(0, 0, 0, optionHeight + 12)
		RuneDrop.UpdateDropdownText()
		return
	end

	for index, itemName in ipairs(runeNames) do
		local selected = State.SelectedRuneItems[itemName] == true
		local countText = " x" .. tostring(counts[itemName] or 0)
		local option = create("TextButton", {
			Name = "RuneOption",
			LayoutOrder = index,
			Size = UDim2.new(1, -12, 0, optionHeight),
			BackgroundColor3 = selected and Theme.Button or Theme.ButtonDark,
			BorderSizePixel = 0,
			Text = (selected and "[x] " or "[ ] ") .. itemName .. countText,
			TextColor3 = Theme.Text,
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 8
		}, UI.RuneDropdownList)
		styleSurface(option, 5, Theme.Accent)
		create("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8)
		}, option)

		connect(option.Activated, function()
			RuneDrop.SetSelected(itemName, not State.SelectedRuneItems[itemName])
			RuneDrop.RefreshDropdownOptions()
		end)
	end

	UI.RuneDropdownList.CanvasSize = UDim2.new(0, 0, 0, (#runeNames * optionStep) + 12)
	RuneDrop.UpdateDropdownText()
end

local function getBombPurchaseRemote()
	local bombBuyRequest = Remotes and Remotes:FindFirstChild("BombBuyRequest")
	if bombBuyRequest then
		return bombBuyRequest
	end

	local networking = getNetworking()
	local gearShop = networking and networking.GearShop
	local purchase = gearShop and gearShop.PurchaseGear
	if purchase then
		return purchase
	end

	return Remotes and Remotes:FindFirstChild("PurchaseGear")
end

local function fireBombPurchase(itemName)
	local purchase = getBombPurchaseRemote()
	if not purchase then
		return false, "Bomb purchase remote not found"
	end

	if type(purchase) == "table" and type(purchase.Fire) == "function" then
		return pcall(function()
			return purchase:Fire(itemName)
		end)
	end

	if type(purchase) == "table" and type(purchase.FireServer) == "function" then
		return pcall(function()
			return purchase:FireServer(itemName)
		end)
	end

	if typeof(purchase) == "Instance" then
		if purchase:IsA("RemoteEvent") then
			return pcall(function()
				purchase:FireServer(itemName)
			end)
		end

		if purchase:IsA("RemoteFunction") then
			local ok, result = pcall(function()
				return purchase:InvokeServer(itemName)
			end)
			if not ok then
				return false, result
			end
			if type(result) == "table" and result.ok == false then
				return false, result.message or result.error or "Purchase rejected"
			end
			return true, result
		end
	end

	return false, "Unsupported bomb purchase remote type: " .. tostring(type(purchase))
end

local function setBuyBombStatus(text, color, force)
	if force or State.LastBuyBombStatus ~= text then
		State.LastBuyBombStatus = text
		setStatus(text, color)
	end
end

function State.UpdateGearShopBuyAllButton()
	if State.GearShopBuyAll and State.BuyingBomb then
		UI.BuyAllBombButton.Text = "Buy All ON"
		UI.BuyAllBombButton.BackgroundColor3 = Theme.Good
	else
		UI.BuyAllBombButton.Text = "Buy All OFF"
		UI.BuyAllBombButton.BackgroundColor3 = Theme.ButtonDark
	end
end

function State.SetGearShopBuyAll(enabled, persist)
	State.GearShopBuyAll = enabled == true
	Config.GearShopBuyAll = State.GearShopBuyAll
	State.UpdateGearShopBuyAllButton()
	State.UpdateBuyBombButtonText()
	updateBombDropdownText()
	if BombDropdownList.Visible then
		refreshBombDropdownOptions()
	end
	if persist ~= false then
		State.SaveGearShopConfig()
	end

	return State.GearShopBuyAll
end

function State.UpdateBuyBombButtonText()
	if State.BuyingBomb then
		BuyBombButton.Text = "Stop Buying"
		BuyBombButton.BackgroundColor3 = Theme.Bad
	else
		BuyBombButton.Text = "Start Buy Selected"
		BuyBombButton.BackgroundColor3 = Theme.Button
	end
end

local function setBuyingBomb(enabled, persist)
	State.LastBuyBombStatus = nil
	local purchaseItems, selectionReason
	if enabled == true then
		purchaseItems, selectionReason = State.GetGearShopPurchaseItems(true)
	end

	if enabled == true and #purchaseItems == 0 then
		State.BuyingBomb = false
		State.GearShopBuyAll = false
		Config.GearShopBuyAll = false
		Config.GearShopAutoBuyEnabled = false
		Config.GearShopStartBuy = false
		State.UpdateGearShopBuyAllButton()
		State.UpdateBuyBombButtonText()
		updateBombDropdownText()
		refreshBombDropdownOptions()
		UI.RuneDropdownList.Visible = false
		BombDropdownList.Visible = true
		setBuyBombStatus(selectionReason or "Select gear before starting", Theme.Bad, true)
		if persist ~= false then
			State.SaveGearShopConfig()
		end
		return
	end

	State.BuyingBomb = enabled == true
	if not State.BuyingBomb and State.GearShopBuyAll then
		State.GearShopBuyAll = false
		Config.GearShopBuyAll = false
	end
	Config.GearShopAutoBuyEnabled = State.BuyingBomb
	Config.GearShopStartBuy = State.BuyingBomb
	State.UpdateGearShopBuyAllButton()
	State.UpdateBuyBombButtonText()
	updateBombDropdownText()

	if State.BuyingBomb then
		State.LastBuyBombTick = 0
		BombDropdownList.Visible = false
		local modeText = State.GearShopBuyAll and "all gear" or ("%d selected"):format(#purchaseItems)
		setBuyBombStatus("Auto Gear Shop ON | " .. modeText, Theme.Good, true)
		log("Auto Gear Shop ON", State.GearShopBuyAll and "BuyAll" or table.concat(getSelectedBombNames(), ", "))
	else
		setBuyBombStatus("Auto Gear Shop stopped", Theme.Muted, true)
		log("Auto Gear Shop OFF")
	end

	if persist ~= false then
		State.SaveGearShopConfig()
	end
end

local function getCharacterPivot(character, root)
	local ok, pivot = pcall(function()
		return character:GetPivot()
	end)
	if ok and pivot then
		return pivot
	end
	return root and root.CFrame or nil
end

local function teleportLocalCharacter(cframe)
	local character, root, humanoid = getCharacterParts(LocalPlayer)
	if not character or not root or not cframe then
		return false
	end

	if humanoid then
		humanoid.Sit = false
	end

	pcall(function()
		character:PivotTo(cframe)
	end)

	pcall(function()
		root.CFrame = cframe
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end)

	return true
end

function State.SetBoulderNoclipEnabled(enabled)
	State.BoulderNoclipParts = State.BoulderNoclipParts or {}

	if enabled then
		local character = LocalPlayer.Character
		if not character then
			return
		end

		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				if State.BoulderNoclipParts[part] == nil then
					State.BoulderNoclipParts[part] = part.CanCollide
				end

				part.CanCollide = false
			end
		end

		return
	end

	for part, canCollide in pairs(State.BoulderNoclipParts) do
		if typeof(part) == "Instance" and part.Parent and part:IsA("BasePart") then
			pcall(function()
				part.CanCollide = canCollide
			end)
		end
	end

	State.BoulderNoclipParts = {}
end

function State.BoulderNoclipHeartbeat()
	if State.NoclipEnabled or (State.BoulderTeleporting and Config.BoulderNoclipEnabled ~= false) then
		State.SetBoulderNoclipEnabled(true)
	elseif next(State.BoulderNoclipParts or {}) ~= nil then
		State.SetBoulderNoclipEnabled(false)
	end
end

function State.RefreshNoclip()
	State.BoulderNoclipHeartbeat()
end

function State.UpdateNoclipButton()
	if not UI.BoulderNoclipButton then
		return
	end

	if State.NoclipEnabled then
		UI.BoulderNoclipButton.Text = "NC ON"
		UI.BoulderNoclipButton.BackgroundColor3 = Theme.Good
	else
		UI.BoulderNoclipButton.Text = "NC OFF"
		UI.BoulderNoclipButton.BackgroundColor3 = Theme.ButtonDark
	end
end

function State.SetNoclipEnabled(enabled, persist)
	State.NoclipEnabled = enabled == true
	State.UpdateNoclipButton()
	State.RefreshNoclip()

	if State.NoclipEnabled then
		setStatus("Noclip ON", Theme.Good)
		log("Noclip ON")
	else
		setStatus("Noclip OFF", Theme.Muted)
		log("Noclip OFF")
	end

	if persist ~= false then
		State.SaveConfig()
	end
	return State.NoclipEnabled
end

function State.UpdateFloatButton()
	if not UI.FloatButton then
		return
	end

	if State.Floating then
		UI.FloatButton.Text = "FLOAT ON"
		UI.FloatButton.BackgroundColor3 = Theme.Good
	else
		UI.FloatButton.Text = "FLOAT OFF"
		UI.FloatButton.BackgroundColor3 = Theme.ButtonDark
	end
end

function State.ClearFloatVelocity()
	if State.FloatVelocity then
		pcall(function()
			State.FloatVelocity:Destroy()
		end)
		State.FloatVelocity = nil
	end
end

function State.ApplyFloat()
	if not State.Floating then
		State.ClearFloatVelocity()
		return
	end

	local character, root, humanoid = getCharacterParts(LocalPlayer)
	if not character or not root then
		State.ClearFloatVelocity()
		return
	end

	if humanoid and ((tonumber(humanoid.Health) or 0) <= 0 or humanoid.Sit) then
		State.ClearFloatVelocity()
		return
	end

	if not State.FloatVelocity or State.FloatVelocity.Parent ~= root then
		State.ClearFloatVelocity()
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Name = "FloatVelocity"
		bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
		bodyVelocity.Velocity = Vector3.new(0, 0, 0)
		bodyVelocity.Parent = root
		State.FloatVelocity = bodyVelocity
	end
end

function State.SetFloatEnabled(enabled, persist)
	State.Floating = enabled == true
	State.FloatHeight = nil
	State.FloatCharacter = nil
	if State.Floating then
		State.ApplyFloat()
	else
		State.ClearFloatVelocity()
	end

	State.UpdateFloatButton()
	setStatus(State.Floating and "Float ON" or "Float OFF", State.Floating and Theme.Good or Theme.Muted)
	log(State.Floating and "Float ON" or "Float OFF")
	if persist ~= false then
		State.SaveConfig()
	end
	return State.Floating
end

function State.ToggleFloat(state)
	if state == nil then
		return State.SetFloatEnabled(not State.Floating)
	end

	return State.SetFloatEnabled(state)
end

function State.FloatHeartbeat()
	State.ApplyFloat()
end

function State.UpdateSpeedButton()
	if not UI.SpeedButton then
		return
	end

	if State.SpeedHackEnabled then
		UI.SpeedButton.Text = "SPEED ON"
		UI.SpeedButton.BackgroundColor3 = Theme.Good
	else
		UI.SpeedButton.Text = "SPEED OFF"
		UI.SpeedButton.BackgroundColor3 = Theme.ButtonDark
	end
end

function State.ApplySpeedHack(enabled)
	local _, root, humanoid = getCharacterParts(LocalPlayer)

	if enabled then
		if not humanoid or not root then
			return
		end

		if State.SpeedHackHumanoid ~= humanoid then
			State.SpeedHackHumanoid = humanoid
			State.SpeedHackOriginalWalkSpeed = humanoid.WalkSpeed
		end

		humanoid.WalkSpeed = Config.SpeedHackSpeed
		local velocity = root.AssemblyLinearVelocity
		local moveDirection = humanoid.MoveDirection
		local targetVelocity = Vector3.new(
			moveDirection.X * Config.SpeedHackSpeed,
			velocity.Y,
			moveDirection.Z * Config.SpeedHackSpeed
		)
		root.AssemblyLinearVelocity = targetVelocity
		root.Velocity = targetVelocity
		return
	end

	if State.SpeedHackHumanoid and typeof(State.SpeedHackHumanoid) == "Instance" and State.SpeedHackHumanoid.Parent then
		pcall(function()
			State.SpeedHackHumanoid.WalkSpeed = Config.SpeedHackDefaultSpeed
		end)
	end

	State.SpeedHackHumanoid = nil
	State.SpeedHackOriginalWalkSpeed = nil
end

function State.SetSpeedHackEnabled(enabled, persist)
	local wasEnabled = State.SpeedHackEnabled
	State.SpeedHackEnabled = enabled == true

	if State.SpeedHackEnabled then
		if not wasEnabled then
			State.SpeedHackHumanoid = nil
			State.SpeedHackOriginalWalkSpeed = nil
		end
		State.ApplySpeedHack(true)
	else
		State.ApplySpeedHack(false)
	end

	State.UpdateSpeedButton()
	setStatus(State.SpeedHackEnabled and ("Speed " .. tostring(Config.SpeedHackSpeed) .. " ON") or "Speed OFF", State.SpeedHackEnabled and Theme.Good or Theme.Muted)
	log(State.SpeedHackEnabled and ("Speed " .. tostring(Config.SpeedHackSpeed) .. " ON") or "Speed OFF")
	if persist ~= false then
		State.SaveConfig()
	end
	return State.SpeedHackEnabled
end

function State.SpeedHackHeartbeat()
	if State.SpeedHackEnabled then
		State.ApplySpeedHack(true)
	end
end

function State.UpdateInfiniteJumpButton()
	if not UI.InfiniteJumpButton then
		return
	end

	if State.InfiniteJumpEnabled then
		UI.InfiniteJumpButton.Text = "JUMP ON"
		UI.InfiniteJumpButton.BackgroundColor3 = Theme.Good
	else
		UI.InfiniteJumpButton.Text = "JUMP OFF"
		UI.InfiniteJumpButton.BackgroundColor3 = Theme.ButtonDark
	end
end

function State.SetInfiniteJumpEnabled(enabled, persist)
	State.InfiniteJumpEnabled = enabled == true
	State.UpdateInfiniteJumpButton()
	setStatus(State.InfiniteJumpEnabled and "Infinite Jump ON" or "Infinite Jump OFF", State.InfiniteJumpEnabled and Theme.Good or Theme.Muted)
	log(State.InfiniteJumpEnabled and "Infinite Jump ON" or "Infinite Jump OFF")
	if persist ~= false then
		State.SaveConfig()
	end
	return State.InfiniteJumpEnabled
end

function State.InfiniteJumpRequest()
	if not State.InfiniteJumpEnabled then
		return
	end

	local _, _, humanoid = getCharacterParts(LocalPlayer)
	if not humanoid or (tonumber(humanoid.Health) or 0) <= 0 then
		return
	end

	pcall(function()
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end)
end

local function updatePlayerTeleportButton()
	if State.PlayerTeleporting then
		PlayerTeleportButton.Text = "Stop TP"
		PlayerTeleportButton.BackgroundColor3 = Theme.Bad
	else
		PlayerTeleportButton.Text = "Start TP"
		PlayerTeleportButton.BackgroundColor3 = Theme.Button
	end
end

updateBoulderTeleportButton = function()
	if State.BoulderTeleporting then
		BoulderTeleportButton.Text = "TP ON"
		BoulderTeleportButton.BackgroundColor3 = Theme.Bad
	else
		BoulderTeleportButton.Text = "TP OFF"
		BoulderTeleportButton.BackgroundColor3 = Theme.Button
	end
end

updateBoulderEspButton = function()
	if State.BoulderEspEnabled then
		BoulderEspButton.Text = "ESP ON"
		BoulderEspButton.BackgroundColor3 = Theme.Good
	else
		BoulderEspButton.Text = "ESP OFF"
		BoulderEspButton.BackgroundColor3 = Theme.ButtonDark
	end
end

updateBoulderPromptButton = function()
	if State.BoulderPromptEnabled then
		BoulderPromptButton.Text = "RUNE ON"
		BoulderPromptButton.BackgroundColor3 = Theme.Good
	else
		BoulderPromptButton.Text = "RUNE OFF"
		BoulderPromptButton.BackgroundColor3 = Theme.ButtonDark
	end
end

setBoulderEspEnabled = function(enabled, persist)
	State.BoulderEspEnabled = enabled == true
	updateBoulderEspButton()
	refreshBoulderEsp()

	if State.BoulderEspEnabled then
		setStatus(("Boulder ESP ON | %d shown"):format(#getBoulderTargets()), Theme.Good)
		log("Boulder ESP ON")
	else
		setStatus("Boulder ESP stopped", Theme.Muted)
		log("Boulder ESP OFF")
	end
	if persist ~= false then
		State.SaveConfig()
	end
end

setBoulderPromptEnabled = function(enabled, persist)
	State.BoulderPromptEnabled = enabled == true
	updateBoulderPromptButton()

	if State.BoulderPromptEnabled then
		State.LastBoulderPromptTick = 0
		setStatus("Rune FirePrompt ON", Theme.Good)
		log("Rune FirePrompt ON")
	else
		setStatus("Rune FirePrompt stopped", Theme.Muted)
		log("Rune FirePrompt OFF")
	end
	if persist ~= false then
		State.SaveConfig()
	end
end

setPlayerTeleporting = function(enabled, persist)
	if enabled == true then
		if State.BoulderLevelFarmEnabled then
			State.SetBoulderLevelFarmEnabled(false, false)
		end
		if State.BoulderTeleporting then
			State.BoulderTeleporting = false
			updateBoulderTeleportButton()
			State.RefreshNoclip()
		end

		local target = getTeleportTargetPlayer()
		if not target then
			State.PlayerTeleporting = false
			updatePlayerTeleportButton()
			refreshPlayerDropdownOptions()
			UI.RuneDropdownList.Visible = false
			PlayerDropdownList.Visible = true
			setStatus("Select a player before starting TP", Theme.Bad)
			if persist ~= false then
				State.SaveConfig()
			end
			return
		end
	end

	State.PlayerTeleporting = enabled == true
	updatePlayerTeleportButton()

	if State.PlayerTeleporting then
		State.LastPlayerTeleportTick = 0
		PlayerDropdownList.Visible = false
		setStatus("TP ON -> " .. getPlayerDisplayName(getTeleportTargetPlayer()), Theme.Good)
		log("Player TP ON", State.SelectedTeleportPlayerName or State.SelectedTeleportPlayerUserId)
	else
		setStatus("TP stopped", Theme.Muted)
		log("Player TP OFF")
	end
	if persist ~= false then
		State.SaveConfig()
	end
end

local function playerTeleportHeartbeat()
	if not State.PlayerTeleporting then
		return
	end

	local now = os.clock()
	if now - State.LastPlayerTeleportTick < Config.PlayerTeleportInterval then
		return
	end
	State.LastPlayerTeleportTick = now

	local target = getTeleportTargetPlayer()
	if not target then
		State.PlayerTeleporting = false
		updatePlayerTeleportButton()
		updatePlayerDropdownText()
		setStatus("TP target not found", Theme.Bad)
		return
	end

	local _, targetRoot = getCharacterParts(target)
	if not targetRoot then
		setStatus("Waiting for " .. target.Name .. " character", Theme.Muted)
		return
	end

	if not teleportLocalCharacter(targetRoot.CFrame * Config.PlayerTeleportOffset) then
		setStatus("Character not found for player TP", Theme.Bad)
	end
end

local function getBoulderTeleportCFrame(target)
	local targetCFrame = getBoulderTargetCFrame(target)
	if not targetCFrame then
		return nil
	end

	local offset = Config.BoulderTeleportOffset or Vector3.new(0, 0, 0)
	return CFrame.new(targetCFrame.Position + offset)
end

setBoulderTeleporting = function(enabled, persist)
	if enabled == true then
		if State.BoulderLevelFarmEnabled then
			State.SetBoulderLevelFarmEnabled(false, false)
		end
		if State.PlayerTeleporting then
			State.PlayerTeleporting = false
			updatePlayerTeleportButton()
		end

		local target = getSelectedBoulderTarget()
		if not target then
			State.BoulderTeleporting = false
			State.RefreshNoclip()
			updateBoulderTeleportButton()
			refreshBoulderDropdownOptions()
			UI.RuneDropdownList.Visible = false
			BoulderDropdownList.Visible = true
			setStatus("Select a boulder before starting TP", Theme.Bad)
			if persist ~= false then
				State.SaveConfig()
			end
			return
		end
	end

	State.BoulderTeleporting = enabled == true
	updateBoulderTeleportButton()

	if State.BoulderTeleporting then
		State.RefreshNoclip()
		State.LastBoulderTeleportTick = 0
		BoulderDropdownList.Visible = false
		setStatus("Boulder TP ON center -> " .. getBoulderTargetDisplayName(getSelectedBoulderTarget()), Theme.Good)
		log("Boulder TP ON", State.SelectedBoulderName)
	else
		State.RefreshNoclip()
		setStatus("Boulder TP stopped", Theme.Muted)
		log("Boulder TP OFF")
	end
	if persist ~= false then
		State.SaveConfig()
	end
end

local function boulderTeleportHeartbeat()
	if not State.BoulderTeleporting then
		return
	end

	local now = os.clock()
	if now - State.LastBoulderTeleportTick < Config.BoulderTeleportInterval then
		return
	end
	State.LastBoulderTeleportTick = now

	local target = getSelectedBoulderTarget()
	if not target then
		local targetName = State.SelectedBoulderName or "selected boulder"
		State.BoulderTeleporting = false
		State.SelectedBoulderTarget = nil
		State.RefreshNoclip()
		updateBoulderTeleportButton()
		updateBoulderDropdownText()
		setStatus("Boulder target gone: " .. tostring(targetName), Theme.Bad)
		return
	end

	local teleportCFrame = getBoulderTeleportCFrame(target)
	if not teleportCFrame then
		setStatus("Boulder has no center: " .. target.Name, Theme.Bad)
		return
	end

	State.RefreshNoclip()
	if not teleportLocalCharacter(teleportCFrame) then
		setStatus("Character not found for Boulder TP", Theme.Bad)
	end
end

local BoulderRefreshQueued = false

local function validateBoulderSelection()
	if not State.SelectedBoulderTarget then
		return
	end

	if getSelectedBoulderTarget() then
		return
	end

	local targetName = State.SelectedBoulderName or "selected boulder"
	State.SelectedBoulderTarget = nil
	if State.BoulderTeleporting then
		State.BoulderTeleporting = false
		State.RefreshNoclip()
		updateBoulderTeleportButton()
		setStatus("Boulder target gone: " .. tostring(targetName), Theme.Bad)
	end
end

function State.ValidateDigBoulderSelection()
	if not State.SelectedDigBoulderTarget then
		return
	end

	if State.GetSelectedDigBoulderTarget() then
		return
	end

	local targetName = State.SelectedDigBoulderName or "selected dig boulder"
	State.SelectedDigBoulderTarget = nil
	State.SelectedDigBoulderName = nil
	if State.DigReplayEnabled then
		State.SetDigReplayEnabled(false)
		setStatus("Dig Boulder gone: " .. tostring(targetName), Theme.Bad)
	end
end

local function refreshBoulderUi()
	validateBoulderSelection()
	State.ValidateDigBoulderSelection()
	updateBoulderDropdownText()
	State.UpdateDigBoulderDropdownText()
	refreshBoulderEsp()
	if BoulderDropdownList.Visible then
		refreshBoulderDropdownOptions()
	end
	if UI.DigBoulderDropdownList.Visible then
		State.RefreshDigBoulderDropdownOptions()
	end
	if UI.BoulderLevelDropdownList.Visible then
		State.RefreshBoulderLevelDropdownOptions()
	end
end

local function queueBoulderRefresh()
	if BoulderRefreshQueued then
		return
	end

	BoulderRefreshQueued = true
	task.defer(function()
		BoulderRefreshQueued = false
		refreshBoulderUi()
	end)
end

local function isBoulderPathObject(object)
	if not object then
		return false
	end

	if object.Name == "MountainDecorations" and object.Parent == Workspace then
		return true
	end

	local parent = object.Parent
	if object.Name == "Boulders" and parent and parent.Name == "MountainDecorations" and parent.Parent == Workspace then
		return true
	end

	local folder = getBouldersFolder()
	return folder and (object == folder or parent == folder or object:IsDescendantOf(folder))
end

local function getCrystalFolders()
	local folders = {}
	local things = Workspace:FindFirstChild("Things")
	local crystals = things and things:FindFirstChild("Crystals")
	local droppedCrystals = Workspace:FindFirstChild("DroppedCrystals")

	if crystals then
		table.insert(folders, crystals)
	end
	if droppedCrystals then
		table.insert(folders, droppedCrystals)
	end

	return folders
end

local function getPromptPosition(prompt)
	if not prompt or not prompt.Parent then
		return nil
	end

	if prompt.Parent:IsA("Attachment") then
		return prompt.Parent.WorldPosition
	end

	if prompt.Parent:IsA("BasePart") then
		return prompt.Parent.Position
	end

	local part = prompt.Parent:FindFirstChildWhichIsA("BasePart", true)
	return part and part.Position or nil
end

local function getNumericCrystalField(crystal, names, parser)
	parser = parser or parseNumber
	if not crystal then
		return nil
	end

	for _, name in ipairs(names) do
		local parsed = parser(crystal:GetAttribute(name))
		if parsed then
			return parsed
		end
	end

	for _, name in ipairs(names) do
		local value = crystal:FindFirstChild(name, true)
		if value and value:IsA("ValueBase") then
			local parsed = parser(value.Value)
			if parsed then
				return parsed
			end
		elseif value and (value:IsA("TextLabel") or value:IsA("TextBox") or value:IsA("TextButton")) then
			local ok, text = pcall(function()
				return value.Text
			end)
			local parsed = ok and parser(text) or nil
			if parsed then
				return parsed
			end

			ok, text = pcall(function()
				return value.ContentText
			end)
			parsed = ok and parser(text) or nil
			if parsed then
				return parsed
			end
		end
	end

	return nil
end

local function getCrystalWeight(crystal, prompt)
	local weight = getNumericCrystalField(crystal, { "WeightKg", "Weight", "Kg", "Mass" })
	if weight then
		return weight
	end

	local text = prompt and tostring((prompt.ObjectText or "") .. " " .. (prompt.ActionText or "")):lower() or ""
	local parsed = text:match("([%d%.,]+)%s*kg")
	if parsed then
		return parseNumber(parsed)
	end

	return nil
end

function State.GetComputedCrystalLuck(crystal)
	if not crystal then
		return nil
	end

	local crystalLuck = State.GetCrystalLuckModule()
	if not (crystalLuck and type(crystalLuck.crystalLuck) == "function") then
		return nil
	end

	local ok, result = pcall(function()
		if crystal:GetAttribute("Tier") == nil and type(crystalLuck.sumPlotLuck) == "function" then
			return crystalLuck.sumPlotLuck(crystal)
		end

		local tier = tonumber(crystal:GetAttribute("Tier")) or 1
		local luckKg = tonumber(crystal:GetAttribute("LuckKg") or crystal:GetAttribute("WeightKg")) or 0
		local mutation = crystal:GetAttribute("Mutation")
		local bombCrystal = crystal:GetAttribute("BombCrystal") == true
		local luckMult

		if type(crystalLuck.combinedCrystalLuckMult) == "function" then
			luckMult = crystalLuck.combinedCrystalLuckMult(crystal)
		elseif type(crystalLuck.combinedLuckMultFrom) == "function" then
			luckMult = crystalLuck.combinedLuckMultFrom(
				crystal:GetAttribute("Mutation"),
				crystal:GetAttribute("MutationLuckRoll"),
				crystal:GetAttribute("ExtraMutations"),
				crystal:GetAttribute("IsBloodCrystal") == true
			)
		end

		return crystalLuck.crystalLuck(tier, luckKg, mutation, bombCrystal, luckMult)
	end)

	return ok and tonumber(result) or nil
end

function State.GetFallbackCrystalLuck(crystal, prompt)
	local luckFieldNames = {
		"Luck",
		"LuckKg",
		"Lucky",
		"CrystalLuck",
		"LuckValue",
		"LuckBonus",
		"LuckMultiplier",
		"LuckyChance",
		"DropLuck",
		"Fortune",
		"Chance"
	}

	local luck = getNumericCrystalField(crystal, luckFieldNames)
		or getNumericCrystalField(prompt, luckFieldNames)
		or getNumericCrystalField(prompt and prompt.Parent, luckFieldNames)
	if luck then
		return luck
	end

	local text = prompt and tostring((prompt.ObjectText or "") .. " " .. (prompt.ActionText or "")):lower() or ""
	local parsed = text:match("luck%s*[:=]?%s*x?%s*([%d%.,]+)")
		or text:match("lucky%s*[:=]?%s*x?%s*([%d%.,]+)")
		or text:match("fortune%s*[:=]?%s*x?%s*([%d%.,]+)")
		or text:match("chance%s*[:=]?%s*x?%s*([%d%.,]+)")
		or text:match("x%s*([%d%.,]+)%s*luck")
		or text:match("x%s*([%d%.,]+)%s*lucky")
		or text:match("([%d%.,]+)%s*x?%s*luck")
		or text:match("([%d%.,]+)%s*x?%s*lucky")
		or text:match("([%d%.,]+)%s*x?%s*fortune")
		or text:match("([%d%.,]+)%s*%%%s*chance")
	if parsed then
		return parseNumber(parsed)
	end

	return nil
end

local function getCrystalLuck(crystal, prompt)
	return State.GetComputedCrystalLuck(crystal)
		or State.GetComputedCrystalLuck(prompt and prompt.Parent)
		or State.GetFallbackCrystalLuck(crystal, prompt)
end

local function getCrystalMoney(crystal, prompt)
	local money = getNumericCrystalField(crystal, {
		"Money",
		"Cash",
		"Coins",
		"Value",
		"Worth",
		"Price",
		"SellValue",
		"SellPrice",
		"Reward",
		"Payout"
	}, parseMoneyNumber)
	if money then
		return money
	end

	local text = prompt and tostring((prompt.ObjectText or "") .. " " .. (prompt.ActionText or "")):lower() or ""
	local parsed = text:match("%$%s*([%d%.,kmbt]+)")
		or text:match("([%d%.,kmbt]+)%s*%$")
		or text:match("([%d%.,kmbt]+)%s*cash")
		or text:match("([%d%.,kmbt]+)%s*coins")
		or text:match("([%d%.,kmbt]+)%s*money")
		or text:match("([%d%.,kmbt]+)%s*value")
		or text:match("([%d%.,kmbt]+)%s*worth")
		or text:match("([%d%.,kmbt]+)%s*price")
	if parsed then
		return parseMoneyNumber(parsed)
	end

	return nil
end

local function getCrystalFilterValues(crystal, prompt)
	return getCrystalWeight(crystal, prompt), getCrystalMoney(crystal, prompt), getCrystalLuck(crystal, prompt)
end

local function passesSingleFilter(enabled, mode, threshold, value)
	if not enabled then
		return false
	end

	if value == nil then
		return threshold <= 0
	end

	if mode == "Below" then
		return value < threshold
	end

	return value > threshold
end

local function passesCrystalFilter(weight, money, luck)
	if passesSingleFilter(
		getFilterEnabledForType("Weight"),
		getFilterModeForType("Weight"),
		getFilterThresholdForType("Weight"),
		weight
	) then
		return true
	end

	if passesSingleFilter(
		getFilterEnabledForType("Money"),
		getFilterModeForType("Money"),
		getFilterThresholdForType("Money"),
		money
	) then
		return true
	end

	if passesSingleFilter(
		getFilterEnabledForType("Luck"),
		getFilterModeForType("Luck"),
		getFilterThresholdForType("Luck"),
		luck
	) then
		return true
	end

	return false
end

local function fireCrystalPrompt(prompt)
	if not prompt then
		return false
	end

	pcall(function()
		prompt.Enabled = true
	end)
	pcall(function()
		prompt.RequiresLineOfSight = false
	end)
	pcall(function()
		prompt.HoldDuration = 0
	end)
	pcall(function()
		prompt.MaxActivationDistance = math.max(tonumber(prompt.MaxActivationDistance) or 0, 1000)
	end)

	local holdDuration = tonumber(prompt.HoldDuration) or 0
	if type(fireproximityprompt) == "function" then
		pcall(function()
			fireproximityprompt(prompt)
		end)
		pcall(function()
			fireproximityprompt(prompt, holdDuration)
		end)
	else
		pcall(function()
			prompt:InputHoldBegin()
			task.wait(math.max(holdDuration, 0.05))
			prompt:InputHoldEnd()
		end)
	end

	return true
end

local function isRuneWorkspaceChild(instance)
	if not instance or instance.Parent ~= Workspace then
		return false
	end

	local name = tostring(instance.Name or ""):lower()
	return name:sub(-4) == "rune"
end

local function getRuneRoots()
	local roots = {}
	local droppedRunes = Workspace:FindFirstChild("DroppedRunes")
	if droppedRunes then
		table.insert(roots, droppedRunes)
	end

	for _, child in ipairs(Workspace:GetChildren()) do
		if isRuneWorkspaceChild(child) then
			table.insert(roots, child)
		end
	end

	table.sort(roots, function(left, right)
		return tostring(left:GetFullName()):lower() < tostring(right:GetFullName()):lower()
	end)

	return roots
end

local function getRunePrompts()
	local prompts = {}
	local seen = {}
	for _, runeRoot in ipairs(getRuneRoots()) do
		for _, descendant in ipairs(runeRoot:GetDescendants()) do
			if descendant:IsA("ProximityPrompt") and not seen[descendant] then
				seen[descendant] = true
				table.insert(prompts, descendant)
			end
		end
	end

	table.sort(prompts, function(left, right)
		return tostring(left:GetFullName()):lower() < tostring(right:GetFullName()):lower()
	end)

	return prompts
end

local function isPromptWithinDistance(prompt, origin, maxDistance)
	if not (prompt and origin) then
		return false
	end

	local position = getPromptPosition(prompt)
	if not position then
		return false
	end

	return (position - origin.Position).Magnitude <= maxDistance
end

local function boulderPromptHeartbeat()
	if not State.BoulderPromptEnabled then
		return
	end

	local _, root = getCharacterParts(LocalPlayer)
	if not root then
		return
	end

	local now = os.clock()
	if now - State.LastBoulderPromptTick < Config.BoulderPromptInterval then
		return
	end
	State.LastBoulderPromptTick = now

	local fired = 0
	local prompts = getRunePrompts()
	for _, prompt in ipairs(prompts) do
		if prompt and prompt.Parent and isPromptWithinDistance(prompt, root, 100) and fireCrystalPrompt(prompt) then
			fired += 1
		end
	end

	if fired > 0 then
		setStatus(("Rune FirePrompt fired %d"):format(fired), Theme.Good)
	else
		setStatus("No Rune ProximityPrompt found", Theme.Muted)
	end
end

local function runFarmCycle()
	if not State.Farming then
		return
	end

	local _, root = getCharacterParts(LocalPlayer)
	local folders = getCrystalFolders()
	if not root or #folders == 0 then
		return
	end

	local fired = 0
	for _, folder in ipairs(folders) do
		for _, crystal in ipairs(folder:GetChildren()) do
			local prompt = crystal:FindFirstChildWhichIsA("ProximityPrompt", true)
			if prompt then
				local position = getPromptPosition(prompt)
				if position then
					local distance = (position - root.Position).Magnitude
					if distance <= Config.FarmDistance then
						local weight, money, luck = getCrystalFilterValues(crystal, prompt)
						if passesCrystalFilter(weight, money, luck) and fireCrystalPrompt(prompt) then
							fired += 1
						end
					end
				end
			end
		end
	end

	if fired > 0 then
		setStatus(("Farm fired %d | %s"):format(fired, getFilterSummary()), Theme.Good)
	end
end

local function farmHeartbeat()
	if not State.Farming then
		return
	end

	local now = os.clock()
	if now - State.LastFarmTick < Config.FarmInterval then
		return
	end
	State.LastFarmTick = now
	runFarmCycle()
end

local function buyBombCycle()
	if not State.BuyingBomb then
		return
	end

	local purchaseItems, reason = State.GetGearShopPurchaseItems()
	if #purchaseItems == 0 then
		setBuyBombStatus(reason or "No gear items found", Theme.Muted)
		return
	end

	local bought = 0
	local outOfStock = 0
	local failedItem
	local failedReason

	for _, stockObject in ipairs(purchaseItems) do
		local stock = getBombStock(stockObject)
		if stock ~= nil and stock <= 0 then
			outOfStock += 1
		else
			local itemName = stockObject.Name
			local ok, result = fireBombPurchase(itemName)
			if ok then
				bought += 1
				if type(result) == "table" and result.remaining ~= nil then
					BombShopStockCache[itemName] = tonumber(result.remaining) or result.remaining
					LastBombShopStockQuery = os.clock()
				end
			else
				failedItem = itemName
				failedReason = result
			end
		end
	end

	if bought > 0 then
		local modeText = State.GearShopBuyAll and "all gear" or "selected gear"
		setBuyBombStatus(("Buying %d/%d %s"):format(bought, #purchaseItems, modeText), Theme.Good)
	elseif failedItem then
		setBuyBombStatus("Buy failed " .. failedItem .. ": " .. tostring(failedReason), Theme.Bad)
	elseif outOfStock > 0 then
		setBuyBombStatus(State.GearShopBuyAll and "All gear out of stock" or "Selected gear out of stock", Theme.Muted)
	end
end

local function buyBombHeartbeat()
	if not State.BuyingBomb then
		return
	end

	local now = os.clock()
	if now - State.LastBuyBombTick < Config.BuyBombInterval then
		return
	end
	State.LastBuyBombTick = now
	buyBombCycle()
end

function State.BuyRadarCycle()
	if not State.BuyingRadar then
		return
	end

	local purchaseItems, reason = State.GetRadarShopPurchaseItems()
	if #purchaseItems == 0 then
		State.SetBuyRadarStatus(reason or "No radar items found", Theme.Muted)
		return
	end

	local bought = 0
	local outOfStock = 0
	local failedItem
	local failedReason

	for _, stockObject in ipairs(purchaseItems) do
		local stock = State.GetRadarStock(stockObject)
		if stock ~= nil and stock <= 0 then
			outOfStock += 1
		else
			local itemName = stockObject.Name
			local ok, result = State.FireRadarPurchase(itemName)
			if ok then
				bought += 1
				if type(result) == "table" and result.remaining ~= nil then
					State.RadarShopStockCache[itemName] = tonumber(result.remaining) or result.remaining
					State.LastRadarShopStockQuery = os.clock()
				elseif State.RadarShopStockCache[itemName] ~= nil then
					State.RadarShopStockCache[itemName] = math.max(0, (tonumber(State.RadarShopStockCache[itemName]) or 1) - 1)
					State.LastRadarShopStockQuery = os.clock()
				end
			else
				failedItem = itemName
				failedReason = result
			end
		end
	end

	if bought > 0 then
		local modeText = State.RadarShopBuyAll and "all radar" or "selected radar"
		State.SetBuyRadarStatus(("Buying %d/%d %s"):format(bought, #purchaseItems, modeText), Theme.Good)
	elseif failedItem then
		State.SetBuyRadarStatus("Buy radar failed " .. failedItem .. ": " .. tostring(failedReason), Theme.Bad)
	elseif outOfStock > 0 then
		State.SetBuyRadarStatus(State.RadarShopBuyAll and "All radar out of stock" or "Selected radar out of stock", Theme.Muted)
	end
end

function State.BuyRadarHeartbeat()
	if not State.BuyingRadar then
		return
	end

	local now = os.clock()
	if now - State.LastBuyRadarTick < (Config.BuyRadarInterval or Config.BuyBombInterval or 0.1) then
		return
	end
	State.LastBuyRadarTick = now
	State.BuyRadarCycle()
end

function State.CollectDropItems()
	local items = {}
	local skippedRunes = 0

	for _, item in ipairs(RuneDrop.GetInventoryTools()) do
		if RuneDrop.IsRuneItemName(item.Name) then
			skippedRunes += 1
		else
			table.insert(items, item)
		end
	end

	return items, skippedRunes
end

function State.UpdateMoneyDropThreshold(value)
	local text = tostring(value or UI.MoneyDropInput.Text or ""):match("^%s*(.-)%s*$") or ""
	if text == "" then
		State.MoneyDropThresholdText = ""
		UI.MoneyDropInput.Text = ""
		State.SaveConfig()
		setStatus("Enter money amount first", Theme.Muted)
		return nil
	end

	local threshold = parseMoneyNumber(text)
	if not threshold then
		setStatus("Money drop input invalid", Theme.Bad)
		return nil
	end

	State.MoneyDropThresholdText = text
	UI.MoneyDropInput.Text = text
	State.SaveConfig()
	return threshold
end

function State.IsMoneyDropCrystalTool(item)
	if not (item and item:IsA("Tool")) then
		return false
	end

	local itemName = tostring(item.Name or "")
	if RuneDrop.IsRuneItemName(itemName) then
		return false
	end

	local lowerName = itemName:lower()
	if lowerName:find("rune", 1, true) then
		return false
	end
	if lowerName:find("crystal", 1, true) then
		return true
	end
	if lowerName:find("bomb", 1, true) then
		return false
	end

	for _, attributeName in ipairs({ "WeightKg", "LuckKg", "CrystalLuck", "Tier", "Mutation", "BombCrystal", "IsBloodCrystal" }) do
		if item:GetAttribute(attributeName) ~= nil then
			return true
		end
	end

	return getNumericCrystalField(item, { "WeightKg", "Weight", "Kg", "Mass", "LuckKg", "CrystalLuck", "Tier" }) ~= nil
end

function State.GetMoneyDropCrystalMoney(item)
	local money = getCrystalMoney(item, nil)
	if money then
		return money
	end

	local text = tostring(item and item.Name or ""):lower()
	local parsed = text:match("%$%s*([%d%.,]+%s*[kmbt]?)")
		or text:match("([%d%.,]+%s*[kmbt])%s*%$")
		or text:match("([%d%.,]+%s*[kmbt])%s*cash")
		or text:match("([%d%.,]+%s*[kmbt])%s*coins")
		or text:match("([%d%.,]+%s*[kmbt])%s*money")
		or text:match("([%d%.,]+%s*[kmbt])%s*value")
		or text:match("([%d%.,]+%s*[kmbt])%s*worth")
		or text:match("%f[%d]([%d%.,]+%s*[kmbt])%f[%A]")
	if parsed then
		return parseMoneyNumber(parsed)
	end

	return nil
end

function State.FormatMoneyDropValue(value)
	value = tonumber(value) or 0
	local absolute = math.abs(value)
	if absolute >= 1e12 then
		return (("%.2fT"):format(value / 1e12):gsub("%.00", ""))
	elseif absolute >= 1e9 then
		return (("%.2fB"):format(value / 1e9):gsub("%.00", ""))
	elseif absolute >= 1e6 then
		return (("%.2fM"):format(value / 1e6):gsub("%.00", ""))
	elseif absolute >= 1e3 then
		return (("%.2fK"):format(value / 1e3):gsub("%.00", ""))
	end
	return tostring(math.floor(value + 0.5))
end

function State.CollectMoneyDropCrystals(targetMoney)
	local entries = {}
	local skippedRunes = 0
	local skippedUnknown = 0
	local availableMoney = 0

	for _, item in ipairs(RuneDrop.GetInventoryTools()) do
		if RuneDrop.IsRuneItemName(item.Name) then
			skippedRunes += 1
		elseif State.IsMoneyDropCrystalTool(item) then
			local money = State.GetMoneyDropCrystalMoney(item)
			if money and money > 0 then
				availableMoney += money
				table.insert(entries, {
					Tool = item,
					Money = money,
					Name = item.Name
				})
			elseif not money then
				skippedUnknown += 1
			end
		end
	end

	table.sort(entries, function(left, right)
		if left.Money == right.Money then
			return tostring(left.Name):lower() < tostring(right.Name):lower()
		end
		return left.Money > right.Money
	end)

	local plan = {}
	local plannedMoney = 0
	for _, entry in ipairs(entries) do
		if plannedMoney >= targetMoney then
			break
		end
		table.insert(plan, entry)
		plannedMoney += entry.Money
	end

	return plan, skippedRunes, skippedUnknown, availableMoney, plannedMoney
end

function State.DropMoneyCrystals(value)
	if State.DroppingMoneyCrystals then
		setStatus("Already dropping money crystals", Theme.Muted)
		return 0
	end

	if not CrystalDropRequest then
		setStatus("CrystalDropRequest remote not found", Theme.Bad)
		return 0
	end

	local threshold = State.UpdateMoneyDropThreshold(value)
	if not threshold then
		return 0
	end

	local plan, skippedRunes, skippedUnknown, availableMoney = State.CollectMoneyDropCrystals(threshold)
	if #plan == 0 then
		local detail = skippedRunes > 0 and (" | skipped " .. tostring(skippedRunes) .. " Rune") or ""
		if skippedUnknown > 0 then
			detail ..= " | " .. tostring(skippedUnknown) .. " crystal unknown value"
		end
		setStatus("No crystal value found for target " .. State.MoneyDropThresholdText .. detail, Theme.Muted)
		return 0
	end

	local availableMoneyText = State.FormatMoneyDropValue(availableMoney)
	if availableMoney < threshold then
		local skippedText = skippedRunes > 0 and (" | skipped " .. tostring(skippedRunes) .. " Rune") or ""
		setStatus("Not enough: bag " .. availableMoneyText .. "/" .. State.MoneyDropThresholdText .. skippedText, Theme.Bad)
		return 0
	end

	State.DroppingMoneyCrystals = true
	UI.DropMoneyButton.Text = "Dropping..."
	local dropped = 0
	local droppedMoney = 0

	for _, entry in ipairs(plan) do
		local item = entry.Tool
		if item and item.Parent then
			local itemName = item.Name
			local ok = pcall(function()
				CrystalDropRequest:FireServer(itemName)
			end)
			if ok then
				dropped += 1
				droppedMoney += entry.Money
			end
			task.wait(0.08)
		end
	end

	UI.DropMoneyButton.Text = "Drop Crystal"
	State.DroppingMoneyCrystals = false
	local skippedText = skippedRunes > 0 and (" | skipped " .. tostring(skippedRunes) .. " Rune") or ""
	local droppedMoneyText = State.FormatMoneyDropValue(droppedMoney)
	if droppedMoney < threshold then
		setStatus("Drop incomplete: " .. droppedMoneyText .. "/" .. State.MoneyDropThresholdText .. " (bag " .. availableMoneyText .. ")" .. skippedText, Theme.Bad)
	else
		setStatus("Dropped " .. tostring(dropped) .. "/" .. tostring(#plan) .. " crystals = " .. droppedMoneyText .. "/" .. State.MoneyDropThresholdText .. skippedText, dropped > 0 and Theme.Good or Theme.Bad)
	end
	return dropped
end

function State.DropAllBackpackItems()
	if State.Dropping then
		setStatus("Already dropping backpack items", Theme.Muted)
		return 0
	end

	if not CrystalDropRequest then
		setStatus("CrystalDropRequest remote not found", Theme.Bad)
		return 0
	end

	local items, skippedRunes = State.CollectDropItems()
	if #items == 0 then
		if skippedRunes and skippedRunes > 0 then
			setStatus("No non-Rune items to drop (" .. tostring(skippedRunes) .. " Rune skipped)", Theme.Muted)
		else
			setStatus("No backpack items to drop", Theme.Muted)
		end
		return 0
	end

	State.Dropping = true
	DropAllButton.Text = "Dropping..."
	local dropped = 0
	for _, item in ipairs(items) do
		if item and item.Parent then
			local itemName = item.Name
			local ok = pcall(function()
				CrystalDropRequest:FireServer(itemName)
			end)
			if ok then
				dropped += 1
			end
			task.wait(0.08)
		end
	end

	DropAllButton.Text = "Drop All Backpack"
	State.Dropping = false
	local skippedText = skippedRunes > 0 and (" | skipped " .. tostring(skippedRunes) .. " Rune") or ""
	setStatus("Dropped " .. tostring(dropped) .. "/" .. tostring(#items) .. " backpack items" .. skippedText, dropped > 0 and Theme.Good or Theme.Bad)
	log("Dropped backpack items", dropped, "/", #items, "skipped runes", skippedRunes)
	return dropped
end

function RuneDrop.CollectDropPlan(selectedNames, amountPerRune)
	local selectedSet = {}
	for _, itemName in ipairs(selectedNames) do
		selectedSet[itemName] = true
	end

	local byName = {}
	for _, item in ipairs(RuneDrop.GetInventoryTools()) do
		local itemName = tostring(item and item.Name or "")
		if selectedSet[itemName] and RuneDrop.IsRuneItemName(itemName) then
			byName[itemName] = byName[itemName] or {
				Tools = {},
				Uses = 0,
				UnknownUses = false
			}
			table.insert(byName[itemName].Tools, item)
			local uses, exactUses = RuneDrop.GetToolUses(item)
			byName[itemName].Uses += uses
			if not exactUses then
				byName[itemName].UnknownUses = true
			end
		end
	end

	local plan = {}
	local targetCount = 0
	for _, itemName in ipairs(selectedNames) do
		local entry = byName[itemName]
		if entry and #entry.Tools > 0 then
			local dropCount = entry.UnknownUses and amountPerRune or math.min(amountPerRune, entry.Uses)
			table.insert(plan, {
				Name = itemName,
				DropCount = dropCount
			})
			targetCount += dropCount
		end
	end

	return plan, targetCount
end

function RuneDrop.DropSelectedItems()
	if State.DroppingRunes then
		setStatus("Already dropping Rune items", Theme.Muted)
		return 0
	end

	if not CrystalDropRequest then
		setStatus("CrystalDropRequest remote not found", Theme.Bad)
		return 0
	end

	local selectedNames = RuneDrop.GetSelectedNames()
	if #selectedNames == 0 then
		RuneDrop.RefreshDropdownOptions()
		UI.RuneDropdownList.Visible = true
		setStatus("Select Rune first", Theme.Muted)
		return 0
	end

	local amountPerRune = RuneDrop.UpdateAmount()
	local plan, targetCount = RuneDrop.CollectDropPlan(selectedNames, amountPerRune)
	if targetCount <= 0 then
		RuneDrop.RefreshDropdownOptions()
		setStatus("Selected Rune not found in backpack", Theme.Bad)
		return 0
	end

	State.DroppingRunes = true
	UI.DropRuneButton.Text = "Dropping..."
	local dropped = 0

	for _, entry in ipairs(plan) do
		for index = 1, entry.DropCount do
			local ok = pcall(function()
				CrystalDropRequest:FireServer(entry.Name)
			end)
			if ok then
				dropped += 1
			end
			task.wait(0.03)
		end
	end

	UI.DropRuneButton.Text = "Drop Rune"
	State.DroppingRunes = false
	RuneDrop.RefreshDropdownOptions()
	RuneDrop.UpdateDropdownText()
	setStatus("Dropped " .. tostring(dropped) .. "/" .. tostring(targetCount) .. " Rune items", dropped > 0 and Theme.Good or Theme.Bad)
	log("Dropped Rune items", dropped, "/", targetCount, "amount each", amountPerRune)
	return dropped
end

function State.BindCameraViewport()
	if State.CameraViewportConnection then
		pcall(function()
			State.CameraViewportConnection:Disconnect()
		end)
		State.CameraViewportConnection = nil
	end

	local camera = Workspace.CurrentCamera
	if camera then
		State.CameraViewportConnection = connect(camera:GetPropertyChangedSignal("ViewportSize"), function()
			task.defer(applyResponsiveLayout)
		end)
	end
end

State.BindCameraViewport()
connect(Workspace:GetPropertyChangedSignal("CurrentCamera"), function()
	State.BindCameraViewport()
	task.defer(applyResponsiveLayout)
end)
State.UpdateFarmDistance(Config.FarmDistance, false)
syncFilterControls()
applyResponsiveLayout(true)

connect(RunService.Heartbeat, farmHeartbeat)
connect(RunService.Heartbeat, buyBombHeartbeat)
connect(RunService.Heartbeat, playerTeleportHeartbeat)
connect(RunService.Stepped, State.BoulderNoclipHeartbeat)
connect(RunService.Stepped, State.FloatHeartbeat)
connect(RunService.RenderStepped, State.SpeedHackHeartbeat)
connect(UserInputService.JumpRequest, State.InfiniteJumpRequest)
connect(RunService.Heartbeat, boulderTeleportHeartbeat)
connect(RunService.Heartbeat, boulderPromptHeartbeat)
connect(RunService.Heartbeat, State.BoulderHopHeartbeat)
connect(RunService.Heartbeat, State.BoulderRejoinHeartbeat)
connect(RunService.Heartbeat, State.BuyRadarHeartbeat)

connect(Workspace.DescendantAdded, function(object)
	if isBoulderPathObject(object) then
		queueBoulderRefresh()
	end
end)

connect(Workspace.DescendantRemoving, function(object)
	if isBoulderPathObject(object) then
		queueBoulderRefresh()
	end
end)

connect(Players.PlayerAdded, function()
	if PlayerDropdownList.Visible then
		refreshPlayerDropdownOptions()
	end
	updatePlayerDropdownText()
end)

connect(Players.PlayerRemoving, function(player)
	if State.SelectedTeleportPlayerUserId == player.UserId then
		if State.PlayerTeleporting then
			State.PlayerTeleporting = false
			updatePlayerTeleportButton()
			setStatus("TP target left: " .. player.Name, Theme.Bad)
		end
		task.defer(updatePlayerDropdownText)
	end

	if PlayerDropdownList.Visible then
		task.defer(refreshPlayerDropdownOptions)
	end
end)

connect(CollapseButton.Activated, function()
	setCollapsed(not State.Collapsed)
end)

connect(FilterTypeButton.Activated, function()
	toggleFilterEnabled("Weight")
end)

connect(MoneyToggleButton.Activated, function()
	toggleFilterEnabled("Money")
end)

connect(LuckToggleButton.Activated, function()
	toggleFilterEnabled("Luck")
end)

connect(WeightModeButton.Activated, function()
	toggleFilterMode("Weight")
end)

connect(MoneyModeButton.Activated, function()
	toggleFilterMode("Money")
end)

connect(LuckModeButton.Activated, function()
	toggleFilterMode("Luck")
end)

connect(WeightInput.FocusLost, function()
	updateWeightThreshold()
end)

connect(MoneyInput.FocusLost, function()
	updateMoneyThreshold()
end)

connect(UI.MoneyDropInput.FocusLost, function()
	State.UpdateMoneyDropThreshold()
end)

connect(LuckInput.FocusLost, function()
	updateLuckThreshold()
end)

connect(UI.FarmDistanceInput.FocusLost, function()
	State.UpdateFarmDistance()
end)

connect(UI.RuneAmountInput.FocusLost, function()
	RuneDrop.UpdateAmount()
end)

connect(FarmButton.Activated, function()
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	PlayerDropdownList.Visible = false
	BoulderDropdownList.Visible = false
	UI.RuneDropdownList.Visible = false
	UI.DigBoulderDropdownList.Visible = false
	UI.BoulderLevelDropdownList.Visible = false
	BombDropdownList.Visible = false
	setFarming(not State.Farming)
end)

connect(DropAllButton.Activated, function()
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	PlayerDropdownList.Visible = false
	BoulderDropdownList.Visible = false
	UI.RuneDropdownList.Visible = false
	UI.DigBoulderDropdownList.Visible = false
	UI.BoulderLevelDropdownList.Visible = false
	BombDropdownList.Visible = false
	task.spawn(State.DropAllBackpackItems)
end)

connect(UI.DropMoneyButton.Activated, function()
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	PlayerDropdownList.Visible = false
	BoulderDropdownList.Visible = false
	UI.RuneDropdownList.Visible = false
	UI.DigBoulderDropdownList.Visible = false
	UI.BoulderLevelDropdownList.Visible = false
	BombDropdownList.Visible = false
	task.spawn(State.DropMoneyCrystals)
end)

connect(UI.RuneDropdownButton.Activated, function()
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	PlayerDropdownList.Visible = false
	BoulderDropdownList.Visible = false
	UI.DigBoulderDropdownList.Visible = false
	UI.BoulderLevelDropdownList.Visible = false
	BombDropdownList.Visible = false
	UI.RuneDropdownList.Visible = not UI.RuneDropdownList.Visible
	if UI.RuneDropdownList.Visible then
		RuneDrop.RefreshDropdownOptions()
	end
end)

connect(UI.DropRuneButton.Activated, function()
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	PlayerDropdownList.Visible = false
	BoulderDropdownList.Visible = false
	UI.DigBoulderDropdownList.Visible = false
	UI.BoulderLevelDropdownList.Visible = false
	BombDropdownList.Visible = false
	task.spawn(RuneDrop.DropSelectedItems)
end)

connect(UI.DigReplayButton.Activated, function()
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	PlayerDropdownList.Visible = false
	BoulderDropdownList.Visible = false
	UI.RuneDropdownList.Visible = false
	UI.DigBoulderDropdownList.Visible = false
	UI.BoulderLevelDropdownList.Visible = false
	BombDropdownList.Visible = false
	State.SetDigReplayEnabled(not State.DigReplayEnabled)
end)

connect(UI.DigBoulderDropdownButton.Activated, function()
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	PlayerDropdownList.Visible = false
	BoulderDropdownList.Visible = false
	UI.RuneDropdownList.Visible = false
	UI.BoulderLevelDropdownList.Visible = false
	BombDropdownList.Visible = false
	UI.DigBoulderDropdownList.Visible = not UI.DigBoulderDropdownList.Visible
	if UI.DigBoulderDropdownList.Visible then
		State.RefreshDigBoulderDropdownOptions()
	end
end)

connect(UI.BoulderLevelDropdownButton.Activated, function()
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	PlayerDropdownList.Visible = false
	BoulderDropdownList.Visible = false
	UI.RuneDropdownList.Visible = false
	UI.DigBoulderDropdownList.Visible = false
	BombDropdownList.Visible = false
	if not State.IsLockedScriptUnlocked() then
		UI.BoulderLevelDropdownList.Visible = false
		State.ShowLockedScriptMessage()
		return
	end
	UI.BoulderLevelDropdownList.Visible = not UI.BoulderLevelDropdownList.Visible
	if UI.BoulderLevelDropdownList.Visible then
		State.RefreshBoulderLevelDropdownOptions()
	end
end)

connect(UI.BoulderLevelFarmButton.Activated, function()
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	PlayerDropdownList.Visible = false
	BoulderDropdownList.Visible = false
	UI.RuneDropdownList.Visible = false
	UI.DigBoulderDropdownList.Visible = false
	UI.BoulderLevelDropdownList.Visible = false
	BombDropdownList.Visible = false
	State.SetBoulderLevelFarmEnabled(not State.BoulderLevelFarmEnabled)
end)

connect(PlayerDropdownButton.Activated, function()
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	BoulderDropdownList.Visible = false
	UI.RuneDropdownList.Visible = false
	UI.DigBoulderDropdownList.Visible = false
	UI.BoulderLevelDropdownList.Visible = false
	BombDropdownList.Visible = false
	PlayerDropdownList.Visible = not PlayerDropdownList.Visible
	if PlayerDropdownList.Visible then
		refreshPlayerDropdownOptions()
	end
end)

connect(PlayerTeleportButton.Activated, function()
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	PlayerDropdownList.Visible = false
	BoulderDropdownList.Visible = false
	UI.RuneDropdownList.Visible = false
	UI.DigBoulderDropdownList.Visible = false
	UI.BoulderLevelDropdownList.Visible = false
	BombDropdownList.Visible = false
	setPlayerTeleporting(not State.PlayerTeleporting)
end)

connect(BoulderDropdownButton.Activated, function()
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	PlayerDropdownList.Visible = false
	UI.RuneDropdownList.Visible = false
	UI.DigBoulderDropdownList.Visible = false
	UI.BoulderLevelDropdownList.Visible = false
	BombDropdownList.Visible = false
	BoulderDropdownList.Visible = not BoulderDropdownList.Visible
	if BoulderDropdownList.Visible then
		refreshBoulderDropdownOptions()
	end
end)

connect(BoulderTeleportButton.Activated, function()
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	PlayerDropdownList.Visible = false
	BoulderDropdownList.Visible = false
	UI.RuneDropdownList.Visible = false
	UI.DigBoulderDropdownList.Visible = false
	UI.BoulderLevelDropdownList.Visible = false
	BombDropdownList.Visible = false
	setBoulderTeleporting(not State.BoulderTeleporting)
end)

connect(UI.BoulderNoclipButton.Activated, function()
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	PlayerDropdownList.Visible = false
	BoulderDropdownList.Visible = false
	UI.RuneDropdownList.Visible = false
	UI.DigBoulderDropdownList.Visible = false
	UI.BoulderLevelDropdownList.Visible = false
	BombDropdownList.Visible = false
	State.SetNoclipEnabled(not State.NoclipEnabled)
end)

connect(UI.FloatButton.Activated, function()
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	PlayerDropdownList.Visible = false
	BoulderDropdownList.Visible = false
	UI.RuneDropdownList.Visible = false
	UI.DigBoulderDropdownList.Visible = false
	UI.BoulderLevelDropdownList.Visible = false
	BombDropdownList.Visible = false
	State.ToggleFloat()
end)

connect(UI.SpeedButton.Activated, function()
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	PlayerDropdownList.Visible = false
	BoulderDropdownList.Visible = false
	UI.RuneDropdownList.Visible = false
	UI.DigBoulderDropdownList.Visible = false
	UI.BoulderLevelDropdownList.Visible = false
	BombDropdownList.Visible = false
	State.SetSpeedHackEnabled(not State.SpeedHackEnabled)
end)

connect(UI.InfiniteJumpButton.Activated, function()
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	PlayerDropdownList.Visible = false
	BoulderDropdownList.Visible = false
	UI.RuneDropdownList.Visible = false
	UI.DigBoulderDropdownList.Visible = false
	UI.BoulderLevelDropdownList.Visible = false
	BombDropdownList.Visible = false
	State.SetInfiniteJumpEnabled(not State.InfiniteJumpEnabled)
end)

connect(BoulderEspButton.Activated, function()
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	PlayerDropdownList.Visible = false
	BoulderDropdownList.Visible = false
	UI.RuneDropdownList.Visible = false
	UI.DigBoulderDropdownList.Visible = false
	UI.BoulderLevelDropdownList.Visible = false
	BombDropdownList.Visible = false
	setBoulderEspEnabled(not State.BoulderEspEnabled)
end)

connect(BoulderPromptButton.Activated, function()
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	PlayerDropdownList.Visible = false
	BoulderDropdownList.Visible = false
	UI.RuneDropdownList.Visible = false
	UI.DigBoulderDropdownList.Visible = false
	UI.BoulderLevelDropdownList.Visible = false
	BombDropdownList.Visible = false
	UI.RadarDropdownList.Visible = false
	setBoulderPromptEnabled(not State.BoulderPromptEnabled)
end)

connect(UI.BoulderHopButton.Activated, function()
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	PlayerDropdownList.Visible = false
	BoulderDropdownList.Visible = false
	UI.RuneDropdownList.Visible = false
	UI.DigBoulderDropdownList.Visible = false
	UI.BoulderLevelDropdownList.Visible = false
	BombDropdownList.Visible = false
	UI.RadarDropdownList.Visible = false
	State.SetBoulderHopEnabled(not State.BoulderHopEnabled)
end)

connect(UI.BoulderRejoinButton.Activated, function()
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	PlayerDropdownList.Visible = false
	BoulderDropdownList.Visible = false
	UI.RuneDropdownList.Visible = false
	UI.DigBoulderDropdownList.Visible = false
	UI.BoulderLevelDropdownList.Visible = false
	BombDropdownList.Visible = false
	UI.RadarDropdownList.Visible = false
	State.SetBoulderRejoinEnabled(not State.BoulderRejoinEnabled)
end)

connect(BombDropdownButton.Activated, function()
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	PlayerDropdownList.Visible = false
	BoulderDropdownList.Visible = false
	UI.RuneDropdownList.Visible = false
	UI.DigBoulderDropdownList.Visible = false
	UI.BoulderLevelDropdownList.Visible = false
	UI.RadarDropdownList.Visible = false
	BombDropdownList.Visible = not BombDropdownList.Visible
	if BombDropdownList.Visible then
		refreshBombDropdownOptions()
	end
end)

connect(UI.BuyAllBombButton.Activated, function()
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	PlayerDropdownList.Visible = false
	BoulderDropdownList.Visible = false
	UI.RuneDropdownList.Visible = false
	UI.DigBoulderDropdownList.Visible = false
	UI.BoulderLevelDropdownList.Visible = false
	BombDropdownList.Visible = false
	UI.RadarDropdownList.Visible = false
	if State.BuyingBomb and State.GearShopBuyAll then
		setBuyingBomb(false)
	else
		State.SetGearShopBuyAll(true, false)
		setBuyingBomb(true)
	end
end)

connect(BuyBombButton.Activated, function()
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	PlayerDropdownList.Visible = false
	BoulderDropdownList.Visible = false
	UI.RuneDropdownList.Visible = false
	UI.DigBoulderDropdownList.Visible = false
	UI.BoulderLevelDropdownList.Visible = false
	BombDropdownList.Visible = false
	UI.RadarDropdownList.Visible = false
	setBuyingBomb(not State.BuyingBomb)
end)

connect(UI.RadarDropdownButton.Activated, function()
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	PlayerDropdownList.Visible = false
	BoulderDropdownList.Visible = false
	UI.RuneDropdownList.Visible = false
	UI.DigBoulderDropdownList.Visible = false
	UI.BoulderLevelDropdownList.Visible = false
	BombDropdownList.Visible = false
	UI.RadarDropdownList.Visible = not UI.RadarDropdownList.Visible
	if UI.RadarDropdownList.Visible then
		State.RefreshRadarDropdownOptions()
	end
end)

connect(UI.BuyAllRadarButton.Activated, function()
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	PlayerDropdownList.Visible = false
	BoulderDropdownList.Visible = false
	UI.RuneDropdownList.Visible = false
	UI.DigBoulderDropdownList.Visible = false
	UI.BoulderLevelDropdownList.Visible = false
	BombDropdownList.Visible = false
	UI.RadarDropdownList.Visible = false
	if State.BuyingRadar and State.RadarShopBuyAll then
		State.SetBuyingRadar(false)
	else
		State.SetRadarShopBuyAll(true, false)
		State.SetBuyingRadar(true)
	end
end)

connect(UI.BuyRadarButton.Activated, function()
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	PlayerDropdownList.Visible = false
	BoulderDropdownList.Visible = false
	UI.RuneDropdownList.Visible = false
	UI.DigBoulderDropdownList.Visible = false
	UI.BoulderLevelDropdownList.Visible = false
	BombDropdownList.Visible = false
	UI.RadarDropdownList.Visible = false
	State.SetBuyingRadar(not State.BuyingRadar)
end)

connect(CloseButton.Activated, function()
	setFarming(false)
	setBuyingBomb(false)
	State.SetBuyingRadar(false)
	State.SetDigReplayEnabled(false)
	setPlayerTeleporting(false)
	setBoulderTeleporting(false)
	State.SetNoclipEnabled(false)
	State.SetFloatEnabled(false)
	State.SetSpeedHackEnabled(false)
	State.SetInfiniteJumpEnabled(false)
	setBoulderEspEnabled(false)
	setBoulderPromptEnabled(false)
	State.SetBoulderLevelFarmEnabled(false)
	State.SetBoulderHopEnabled(false)
	State.SetBoulderRejoinEnabled(false)
	FilterTypeList.Visible = false
	WeightModeList.Visible = false
	PlayerDropdownList.Visible = false
	BoulderDropdownList.Visible = false
	UI.RuneDropdownList.Visible = false
	UI.DigBoulderDropdownList.Visible = false
	UI.BoulderLevelDropdownList.Visible = false
	BombDropdownList.Visible = false
	UI.RadarDropdownList.Visible = false
	Gui.Enabled = false
end)

State.Dragging = false
State.DragInput = nil
State.DragStart = nil
State.DragStartPosition = nil

connect(Header.InputBegan, function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		State.Dragging = true
		State.DragInput = input
		State.DragStart = input.Position
		State.DragStartPosition = Main.Position
		connect(input.Changed, function()
			if input.UserInputState == Enum.UserInputState.End then
				State.Dragging = false
				State.DragInput = nil
			end
		end)
	end
end)

connect(Header.InputChanged, function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		State.DragInput = input
	end
end)

connect(UserInputService.InputChanged, function(input)
	if State.Dragging and input == State.DragInput and State.DragStart and State.DragStartPosition then
		local delta = input.Position - State.DragStart
		local viewport = getViewportSize()
		setMainPositionClamped(
			(viewport.X * State.DragStartPosition.X.Scale) + State.DragStartPosition.X.Offset + delta.X,
			(viewport.Y * State.DragStartPosition.Y.Scale) + State.DragStartPosition.Y.Offset + delta.Y,
			getCurrentMainPixelSize()
		)
	end
end)

connect(UserInputService.InputEnded, function(input)
	if input == State.DragInput then
		State.Dragging = false
		State.DragInput = nil
	end
end)

function State.Stop()
	setFarming(false)
	setBuyingBomb(false)
	State.SetBuyingRadar(false)
	State.SetDigReplayEnabled(false)
	setPlayerTeleporting(false)
	setBoulderTeleporting(false)
	State.SetNoclipEnabled(false)
	State.SetFloatEnabled(false)
	State.SetSpeedHackEnabled(false)
	State.SetInfiniteJumpEnabled(false)
	setBoulderEspEnabled(false)
	setBoulderPromptEnabled(false)
	State.SetBoulderLevelFarmEnabled(false)
	State.SetBoulderHopEnabled(false)
	State.SetBoulderRejoinEnabled(false)
end

function State.StartFarm(mode, threshold)
	return State.StartWeightFarm(mode, threshold)
end

function State.StartWeightFarm(mode, threshold)
	setFilterEnabled("Weight", true)
	if mode ~= nil then
		setFilterMode("Weight", mode)
	end
	if threshold ~= nil then
		updateWeightThreshold(threshold)
	end
	setFarming(true)
	return State.Farming
end

function State.StartMoneyFarm(mode, threshold)
	setFilterEnabled("Money", true)
	if mode ~= nil then
		setFilterMode("Money", mode)
	end
	if threshold ~= nil then
		updateMoneyThreshold(threshold)
	end
	setFarming(true)
	return State.Farming
end

function State.StartLuckFarm(mode, threshold)
	setFilterEnabled("Luck", true)
	if mode ~= nil then
		setFilterMode("Luck", mode)
	end
	if threshold ~= nil then
		updateLuckThreshold(threshold)
	end
	setFarming(true)
	return State.Farming
end

function State.StopFarm()
	setFarming(false)
end

function State.SetWeightEnabled(enabled)
	setFilterEnabled("Weight", enabled)
	return getFilterEnabledForType("Weight")
end

function State.SetMoneyEnabled(enabled)
	setFilterEnabled("Money", enabled)
	return getFilterEnabledForType("Money")
end

function State.SetLuckEnabled(enabled)
	setFilterEnabled("Luck", enabled)
	return getFilterEnabledForType("Luck")
end

function State.SetWeightMode(mode)
	setFilterMode("Weight", mode)
	return getFilterModeForType("Weight")
end

function State.SetMoneyMode(mode)
	setFilterMode("Money", mode)
	return getFilterModeForType("Money")
end

function State.SetLuckMode(mode)
	setFilterMode("Luck", mode)
	return getFilterModeForType("Luck")
end

function State.SetWeightThreshold(threshold)
	updateWeightThreshold(threshold)
	return getFilterThresholdForType("Weight")
end

function State.SetMoneyThreshold(threshold)
	updateMoneyThreshold(threshold)
	return getFilterThresholdForType("Money")
end

function State.SetLuckThreshold(threshold)
	updateLuckThreshold(threshold)
	return getFilterThresholdForType("Luck")
end

function State.SetFilterType(filterType)
	filterType = normalizeFilterType(filterType)
	setFilterEnabled(filterType, true)
	return getFilterEnabledForType(filterType)
end

function State.SetFilterMode(mode)
	setFilterMode("Weight", mode)
	return getFilterModeForType("Weight")
end

function State.SetFilterThreshold(threshold)
	updateWeightThreshold(threshold)
	return getFilterThresholdForType("Weight")
end

function State.SetFarmDistance(distance)
	return State.UpdateFarmDistance(distance)
end

function State.DropAll()
	return State.DropAllBackpackItems()
end

function State.SetMoneyDropThreshold(threshold)
	return State.UpdateMoneyDropThreshold(threshold)
end

function State.DropCrystalsByMoney(threshold)
	return State.DropMoneyCrystals(threshold)
end

function State.SetRuneSelection(itemNames)
	State.SelectedRuneItems = {}

	if type(itemNames) == "table" then
		for _, itemName in ipairs(itemNames) do
			if itemName and RuneDrop.IsRuneItemName(itemName) then
				State.SelectedRuneItems[tostring(itemName)] = true
			end
		end
	elseif itemNames and RuneDrop.IsRuneItemName(itemNames) then
		State.SelectedRuneItems[tostring(itemNames)] = true
	end

	RuneDrop.UpdateDropdownText()
	if UI.RuneDropdownList.Visible then
		RuneDrop.RefreshDropdownOptions()
	end
	State.SaveConfig()
	return RuneDrop.GetSelectedNames()
end

function State.DropRunes(itemNames, amount)
	if itemNames ~= nil then
		State.SetRuneSelection(itemNames)
	end
	if amount ~= nil then
		RuneDrop.UpdateAmount(amount)
	end
	return RuneDrop.DropSelectedItems()
end

function State.SetDigReplay(enabled)
	return State.SetDigReplayEnabled(enabled)
end

function State.SetDigBoulder(modelNameOrIndex, persist)
	local wanted = tostring(modelNameOrIndex or "")
	if wanted == "" then
		return false
	end

	local wantedIndex = tonumber(wanted)
	local targets = getDigBoulderTargets()
	local labels = getBoulderOptionLabels(targets)
	for index, target in ipairs(targets) do
		local label = labels[target] or target.Name
		local level = getBoulderAttributeDisplay(target) or ""
		local boulderName = tostring(target:GetAttribute("BoulderName") or target.Name)
		if index == wantedIndex
			or target.Name:lower() == wanted:lower()
			or label:lower() == wanted:lower()
			or level:lower() == wanted:lower()
			or boulderName:lower() == wanted:lower() then
			return State.SetDigBoulderTarget(target, persist)
		end
	end

	setStatus("Dig Boulder not found: " .. wanted, Theme.Bad)
	return false
end

function State.StartDigReplay()
	return State.SetDigReplayEnabled(true)
end

function State.StopDigReplay()
	return State.SetDigReplayEnabled(false)
end

function State.SetTeleportPlayer(playerNameOrUserId, persist)
	local wanted = tostring(playerNameOrUserId or "")
	if wanted == "" then
		return false
	end

	local wantedNumber = tonumber(wanted)
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			if player.UserId == wantedNumber or player.Name:lower() == wanted:lower() or player.DisplayName:lower() == wanted:lower() then
				return setTeleportPlayer(player, persist)
			end
		end
	end

	setStatus("Player not found: " .. wanted, Theme.Bad)
	return false
end

function State.StartPlayerTP(playerNameOrUserId)
	if playerNameOrUserId ~= nil and not State.SetTeleportPlayer(playerNameOrUserId) then
		return false
	end

	setPlayerTeleporting(true)
	return State.PlayerTeleporting
end

function State.StopPlayerTP()
	setPlayerTeleporting(false)
end

function State.SetBoulderTarget(modelNameOrIndex, persist)
	local wanted = tostring(modelNameOrIndex or "")
	if wanted == "" then
		return false
	end

	local wantedIndex = tonumber(wanted)
	local targets = getBoulderTargets()
	local labels = getBoulderOptionLabels(targets)
	for index, target in ipairs(targets) do
		local label = labels[target] or target.Name
		if index == wantedIndex or target.Name:lower() == wanted:lower() or label:lower() == wanted:lower() then
			return setBoulderTarget(target, persist)
		end
	end

	setStatus("Boulder not found: " .. wanted, Theme.Bad)
	return false
end

function State.StartBoulderTP(modelNameOrIndex)
	if modelNameOrIndex ~= nil and not State.SetBoulderTarget(modelNameOrIndex) then
		return false
	end

	setBoulderTeleporting(true)
	return State.BoulderTeleporting
end

function State.StopBoulderTP()
	setBoulderTeleporting(false)
end

function State.SetBoulderESP(enabled)
	setBoulderEspEnabled(enabled)
	return State.BoulderEspEnabled
end

function State.StartBoulderESP()
	setBoulderEspEnabled(true)
	return State.BoulderEspEnabled
end

function State.StopBoulderESP()
	setBoulderEspEnabled(false)
end

function State.SetBoulderLevelFarm(levelOrEnabled, enabled)
	if type(levelOrEnabled) == "string" then
		State.SetBoulderLevelFarmLevel(levelOrEnabled)
		return State.SetBoulderLevelFarmEnabled(enabled ~= false)
	end

	return State.SetBoulderLevelFarmEnabled(levelOrEnabled)
end

function State.StartBoulderLevelFarm(level)
	if level ~= nil then
		State.SetBoulderLevelFarmLevel(level)
	end
	return State.SetBoulderLevelFarmEnabled(true)
end

function State.StopBoulderLevelFarm()
	return State.SetBoulderLevelFarmEnabled(false)
end

function State.SetBoulderHop(enabled)
	return State.SetBoulderHopEnabled(enabled)
end

function State.StartBoulderHop()
	return State.SetBoulderHopEnabled(true)
end

function State.StopBoulderHop()
	return State.SetBoulderHopEnabled(false)
end

function State.SetBoulderRejoin(enabled)
	return State.SetBoulderRejoinEnabled(enabled)
end

function State.StartBoulderRejoin()
	return State.SetBoulderRejoinEnabled(true)
end

function State.StopBoulderRejoin()
	return State.SetBoulderRejoinEnabled(false)
end

function State.SetRuneFirePrompt(enabled)
	setBoulderPromptEnabled(enabled)
	return State.BoulderPromptEnabled
end

function State.StartRuneFirePrompt()
	setBoulderPromptEnabled(true)
	return State.BoulderPromptEnabled
end

function State.StopRuneFirePrompt()
	setBoulderPromptEnabled(false)
end

function State.SetBoulderFirePrompt(enabled)
	return State.SetRuneFirePrompt(enabled)
end

function State.StartBoulderFirePrompt()
	return State.StartRuneFirePrompt()
end

function State.StopBoulderFirePrompt()
	return State.StopRuneFirePrompt()
end

function State.SetNoclip(enabled)
	return State.SetNoclipEnabled(enabled)
end

function State.StartNoclip()
	return State.SetNoclipEnabled(true)
end

function State.StopNoclip()
	return State.SetNoclipEnabled(false)
end

function State.SetFloat(enabled)
	return State.SetFloatEnabled(enabled)
end

function State.StartFloat()
	return State.SetFloatEnabled(true)
end

function State.StopFloat()
	return State.SetFloatEnabled(false)
end

function State.SetSpeedHack(enabled)
	return State.SetSpeedHackEnabled(enabled)
end

function State.StartSpeedHack()
	return State.SetSpeedHackEnabled(true)
end

function State.StopSpeedHack()
	return State.SetSpeedHackEnabled(false)
end

function State.SetInfiniteJump(enabled)
	return State.SetInfiniteJumpEnabled(enabled)
end

function State.StartInfiniteJump()
	return State.SetInfiniteJumpEnabled(true)
end

function State.StopInfiniteJump()
	return State.SetInfiniteJumpEnabled(false)
end

function State.ToggleFloatGlobal(state)
	return State.ToggleFloat(state)
end

ToggleFloat = State.ToggleFloatGlobal
_G.ToggleFloat = State.ToggleFloatGlobal

function State.SetBombSelection(itemNames)
	State.SelectedBombItems = {}

	if type(itemNames) == "table" then
		for _, itemName in ipairs(itemNames) do
			if itemName then
				State.SelectedBombItems[tostring(itemName)] = true
			end
		end
	else
		if itemNames then
			State.SelectedBombItems[tostring(itemNames)] = true
		end
	end

	syncBombSelectionConfig()
	State.SaveGearShopConfig()
	updateBombDropdownText()
	if BombDropdownList.Visible then
		refreshBombDropdownOptions()
	end
end

function State.StartBuyBomb(itemNames)
	if itemNames ~= nil then
		State.SetGearShopBuyAll(false)
		State.SetBombSelection(itemNames)
	end
	setBuyingBomb(true)
end

function State.StopBuyBomb()
	setBuyingBomb(false)
end

function State.StartBuyAllGearShop()
	State.SetGearShopBuyAll(true, false)
	setBuyingBomb(true)
	return State.BuyingBomb
end

function State.StartBuyAllBomb()
	return State.StartBuyAllGearShop()
end

function State.StopGearShop()
	setBuyingBomb(false)
end

function State.SetRadarSelection(itemNames)
	State.SelectedRadarItems = {}

	if type(itemNames) == "table" then
		for _, itemName in ipairs(itemNames) do
			if itemName then
				State.SelectedRadarItems[tostring(itemName)] = true
			end
		end
	else
		if itemNames then
			State.SelectedRadarItems[tostring(itemNames)] = true
		end
	end

	State.SyncRadarSelectionConfig()
	State.SaveGearShopConfig()
	State.UpdateRadarDropdownText()
	if UI.RadarDropdownList.Visible then
		State.RefreshRadarDropdownOptions()
	end
end

function State.StartBuyRadar(itemNames)
	if itemNames ~= nil then
		State.SetRadarShopBuyAll(false)
		State.SetRadarSelection(itemNames)
	end
	State.SetBuyingRadar(true)
end

function State.StopBuyRadar()
	State.SetBuyingRadar(false)
end

function State.StartBuyAllRadarShop()
	State.SetRadarShopBuyAll(true, false)
	State.SetBuyingRadar(true)
	return State.BuyingRadar
end

function State.StartBuyAllRadar()
	return State.StartBuyAllRadarShop()
end

function State.StartRadarShop(itemNames)
	return State.StartBuyRadar(itemNames)
end

function State.StopRadarShop()
	State.SetBuyingRadar(false)
end

function State.ApplySavedConfigStarts()
	if tostring(Config.SelectedBoulderName or "") ~= "" then
		State.SetBoulderTarget(Config.SelectedBoulderName, false)
	end
	if tostring(Config.SelectedDigBoulderName or "") ~= "" then
		State.SetDigBoulder(Config.SelectedDigBoulderName, false)
	end

	updatePlayerDropdownText()
	updateBoulderDropdownText()
	State.UpdateDigBoulderDropdownText()

	if Config.Collapsed then
		setCollapsed(true, false)
	end
	if Config.NoclipStart then
		State.SetNoclipEnabled(true, false)
	end
	if Config.FloatStart then
		State.SetFloatEnabled(true, false)
	end
	if Config.SpeedHackStart then
		State.SetSpeedHackEnabled(true, false)
	end
	if Config.InfiniteJumpStart then
		State.SetInfiniteJumpEnabled(true, false)
	end
	if Config.BoulderEspStart then
		setBoulderEspEnabled(true, false)
	end
	if Config.BoulderPromptStart then
		setBoulderPromptEnabled(true, false)
	end
	if Config.BoulderLevelFarmStart then
		State.SetBoulderLevelFarmEnabled(true, false)
	end
	if Config.BoulderHopStart then
		State.SetBoulderHopEnabled(true, false)
	end
	if Config.BoulderRejoinStart then
		State.SetBoulderRejoinEnabled(true, false)
	end
	if Config.FarmStart then
		setFarming(true, false)
	end
	if Config.PlayerTeleportStart then
		setPlayerTeleporting(true, false)
	end
	if Config.BoulderTeleportStart then
		setBoulderTeleporting(true, false)
	end
	if Config.DigReplayStart then
		State.SetDigReplayEnabled(true, false)
	end
	if Config.GearShopStartBuy or Config.GearShopAutoBuyEnabled then
		setBuyingBomb(true, false)
	end
	if Config.RadarShopStartBuy or Config.RadarShopAutoBuyEnabled then
		State.SetBuyingRadar(true, false)
	end
end

function State.Destroy()
	setFarming(false, false)
	setBuyingBomb(false, false)
	State.SetBuyingRadar(false, false)
	State.SetDigReplayEnabled(false, false)
	setPlayerTeleporting(false, false)
	setBoulderTeleporting(false, false)
	State.SetNoclipEnabled(false, false)
	State.SetFloatEnabled(false, false)
	State.SetSpeedHackEnabled(false, false)
	State.SetInfiniteJumpEnabled(false, false)
	setBoulderEspEnabled(false, false)
	setBoulderPromptEnabled(false, false)
	State.SetBoulderLevelFarmEnabled(false, false)
	State.SetBoulderHopEnabled(false, false)
	State.SetBoulderRejoinEnabled(false, false)
	for _, connection in ipairs(State.Connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	if State.Gui then
		State.Gui:Destroy()
	end
	_G.CrystalToolsUI = nil
	_G.PlayerBackTPUI = nil
	if _G.CrystalToolsDigHookState == State then
		_G.CrystalToolsDigHookState = nil
	end
	if ToggleFloat == State.ToggleFloatGlobal then
		ToggleFloat = nil
	end
	if _G.ToggleFloat == State.ToggleFloatGlobal then
		_G.ToggleFloat = nil
	end
end

updatePlayerDropdownText()
updateBoulderDropdownText()
State.UpdateDigBoulderDropdownText()
updateBoulderTeleportButton()
State.UpdateNoclipButton()
State.UpdateFloatButton()
State.UpdateSpeedButton()
State.UpdateInfiniteJumpButton()
State.UpdateDigReplayButton()
updateBoulderEspButton()
updateBoulderPromptButton()
State.UpdateBoulderLevelDropdownText()
State.UpdateBoulderLevelFarmButton()
State.UpdateBoulderHopButton()
State.UpdateBoulderRejoinButton()
RuneDrop.UpdateDropdownText()
State.UpdateGearShopBuyAllButton()
State.UpdateBuyBombButtonText()
updateBombDropdownText()
State.UpdateRadarShopBuyAllButton()
State.UpdateBuyRadarButtonText()
State.UpdateRadarDropdownText()
setStatus("Ready", Theme.Muted)

if Config.FarmStart
	or Config.PlayerTeleportStart
	or Config.BoulderTeleportStart
	or Config.BoulderEspStart
	or Config.BoulderPromptStart
	or Config.BoulderLevelFarmStart
	or Config.BoulderHopStart
	or Config.BoulderRejoinStart
	or Config.DigReplayStart
	or Config.NoclipStart
	or Config.FloatStart
	or Config.SpeedHackStart
	or Config.InfiniteJumpStart
	or Config.GearShopStartBuy
	or Config.GearShopAutoBuyEnabled
	or Config.RadarShopStartBuy
	or Config.RadarShopAutoBuyEnabled
	or Config.Collapsed
	or tostring(Config.SelectedBoulderName or "") ~= ""
	or tostring(Config.SelectedDigBoulderName or "") ~= "" then
	task.defer(function()
		if State.Gui and State.Gui.Parent then
			State.ApplySavedConfigStarts()
		end
	end)
end
