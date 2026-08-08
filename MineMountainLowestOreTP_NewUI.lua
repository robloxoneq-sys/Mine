local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer

local TechBlue = Color3.fromRGB(70, 205, 255)
local TechBlueBright = Color3.fromRGB(148, 235, 255)
local TechBlueDeep = Color3.fromRGB(10, 75, 185)
local TechBackground = Color3.fromRGB(3, 10, 25)

local blur = Instance.new("BlurEffect")
blur.Name = "IntroBlur"
blur.Size = 0
blur.Parent = Lighting

local gui = Instance.new("ScreenGui")
gui.Name = "IntroGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local backdrop = Instance.new("Frame")
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundColor3 = TechBackground
backdrop.BackgroundTransparency = 0.3
backdrop.BorderSizePixel = 0
backdrop.Parent = gui

local backdropGradient = Instance.new("UIGradient")
backdropGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(2, 8, 20)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(5, 24, 58)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(2, 8, 20))
})
backdropGradient.Rotation = 0
backdropGradient.Parent = backdrop

local techPanel = Instance.new("Frame")
techPanel.AnchorPoint = Vector2.new(0.5, 0.5)
techPanel.Size = UDim2.new(0, 760, 0, 210)
techPanel.Position = UDim2.new(0.5, 0, 0.46, 0)
techPanel.BackgroundColor3 = Color3.fromRGB(5, 16, 38)
techPanel.BackgroundTransparency = 0.1
techPanel.BorderSizePixel = 0
techPanel.ClipsDescendants = true
techPanel.Parent = gui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 8)
panelCorner.Parent = techPanel

local panelStroke = Instance.new("UIStroke")
panelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
panelStroke.Color = TechBlue
panelStroke.Transparency = 0.12
panelStroke.Thickness = 1.5
panelStroke.Parent = techPanel

local panelGlowNear = Instance.new("UIStroke")
panelGlowNear.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
panelGlowNear.Color = TechBlue
panelGlowNear.Transparency = 0.62
panelGlowNear.Thickness = 3
panelGlowNear.Parent = techPanel

local panelGlowFar = Instance.new("UIStroke")
panelGlowFar.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
panelGlowFar.Color = TechBlueBright
panelGlowFar.Transparency = 0.88
panelGlowFar.Thickness = 7
panelGlowFar.Parent = techPanel

local panelGradient = Instance.new("UIGradient")
panelGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 15, 34)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(7, 32, 72)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 15, 34))
})
panelGradient.Rotation = 0
panelGradient.Parent = techPanel

local topRail = Instance.new("Frame")
topRail.Size = UDim2.new(1, -54, 0, 3)
topRail.Position = UDim2.new(0, 27, 0, 17)
topRail.BackgroundColor3 = TechBlueDeep
topRail.BackgroundTransparency = 0.15
topRail.BorderSizePixel = 0
topRail.ClipsDescendants = true
topRail.Parent = techPanel

local railGradient = Instance.new("UIGradient")
railGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(6, 50, 125)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(12, 100, 215)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(6, 50, 125))
})
railGradient.Parent = topRail

local bottomRail = Instance.new("Frame")
bottomRail.Size = UDim2.new(1, -54, 0, 3)
bottomRail.Position = UDim2.new(0, 27, 1, -18)
bottomRail.BackgroundColor3 = TechBlueDeep
bottomRail.BackgroundTransparency = 0.15
bottomRail.BorderSizePixel = 0
bottomRail.ClipsDescendants = true
bottomRail.Parent = techPanel

local bottomRailGradient = Instance.new("UIGradient")
bottomRailGradient.Color = railGradient.Color
bottomRailGradient.Parent = bottomRail

local sideMarker = Instance.new("Frame")
sideMarker.Size = UDim2.new(0, 4, 0, 48)
sideMarker.Position = UDim2.new(0, 27, 0.5, -24)
sideMarker.BackgroundColor3 = TechBlueBright
sideMarker.BorderSizePixel = 0
sideMarker.Parent = techPanel

local markerCorner = Instance.new("UICorner")
markerCorner.CornerRadius = UDim.new(1, 0)
markerCorner.Parent = sideMarker

local function createRailRunner(parent, startPosition)
    local runner = Instance.new("Frame")
    runner.Size = UDim2.new(0, 150, 1, 0)
    runner.Position = startPosition
    runner.BackgroundColor3 = TechBlueBright
    runner.BorderSizePixel = 0
    runner.Parent = parent

    local runnerGradient = Instance.new("UIGradient")
    runnerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, TechBlue),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, TechBlue)
    })
    runnerGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    runnerGradient.Parent = runner

    return runner
end

local topRunner = createRailRunner(topRail, UDim2.new(0, -150, 0, 0))
local bottomRunner = createRailRunner(bottomRail, UDim2.new(1, 0, 0, 0))

local leftText = Instance.new("TextLabel")
leftText.Parent = techPanel
leftText.BackgroundTransparency = 1
leftText.Size = UDim2.new(1, -76, 0, 68)
leftText.Position = UDim2.new(-1, 0, 0, 28)
leftText.Font = Enum.Font.GothamBlack
leftText.Text = "UPDATE BYPASS ANTICHEAT"
leftText.TextSize = 42
leftText.TextColor3 = Color3.fromRGB(255, 255, 255)
leftText.TextStrokeColor3 = TechBlue
leftText.TextStrokeTransparency = 0.45
leftText.TextXAlignment = Enum.TextXAlignment.Left

local rightText = Instance.new("TextLabel")
rightText.Parent = techPanel
rightText.BackgroundTransparency = 1
rightText.Size = UDim2.new(1, -76, 0, 30)
rightText.Position = UDim2.new(1.25, 0, 0, 85)
rightText.Font = Enum.Font.GothamBold
rightText.Text = "SCRIPT BROKEN DO NOT EXECUTE THE SCRIPT."
rightText.TextSize = 20
rightText.TextColor3 = TechBlueBright
rightText.TextStrokeColor3 = TechBlueDeep
rightText.TextStrokeTransparency = 0.35
rightText.TextXAlignment = Enum.TextXAlignment.Left

-- ย้ายตำแหน่ง Loading ลงมาอยู่ด้านล่างข้อความเตือน
local loadingLabel = Instance.new("TextLabel")
loadingLabel.Size = UDim2.new(0, 650, 0, 20)
loadingLabel.Position = UDim2.new(0, 52, 0, 130)
loadingLabel.BackgroundTransparency = 1
loadingLabel.Font = Enum.Font.GothamBold
loadingLabel.Text = "Loading... 1%"
loadingLabel.TextSize = 13
loadingLabel.TextColor3 = TechBlueBright
loadingLabel.TextStrokeColor3 = TechBlueDeep
loadingLabel.TextStrokeTransparency = 0.6
loadingLabel.TextXAlignment = Enum.TextXAlignment.Left
loadingLabel.Parent = techPanel

local loadingTrack = Instance.new("Frame")
loadingTrack.Size = UDim2.new(1, -104, 0, 8)
loadingTrack.Position = UDim2.new(0, 52, 0, 155)
loadingTrack.BackgroundColor3 = Color3.fromRGB(5, 28, 67)
loadingTrack.BorderSizePixel = 0
loadingTrack.ClipsDescendants = true
loadingTrack.Parent = techPanel

local loadingTrackCorner = Instance.new("UICorner")
loadingTrackCorner.CornerRadius = UDim.new(1, 0)
loadingTrackCorner.Parent = loadingTrack

local loadingStroke = Instance.new("UIStroke")
loadingStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
loadingStroke.Color = TechBlue
loadingStroke.Transparency = 0.2
loadingStroke.Thickness = 1
loadingStroke.Parent = loadingTrack

local loadingFill = Instance.new("Frame")
loadingFill.Size = UDim2.new(0.01, 0, 1, 0)
loadingFill.BackgroundColor3 = TechBlueBright
loadingFill.BorderSizePixel = 0
loadingFill.Parent = loadingTrack

local loadingFillCorner = Instance.new("UICorner")
loadingFillCorner.CornerRadius = UDim.new(1, 0)
loadingFillCorner.Parent = loadingFill

local loadingFillGradient = Instance.new("UIGradient")
loadingFillGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, TechBlueDeep),
    ColorSequenceKeypoint.new(0.7, TechBlue),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
})
loadingFillGradient.Parent = loadingFill

local loadingProgress = Instance.new("NumberValue")
loadingProgress.Value = 1
loadingProgress.Parent = techPanel

local function updateLoadingProgress(value)
    local progress = math.clamp(math.floor(value + 0.5), 1, 100)
    loadingLabel.Text = string.format("Loading... %d%%", progress)
    loadingFill.Size = UDim2.new(progress / 100, 0, 1, 0)
end

loadingProgress.Changed:Connect(updateLoadingProgress)
updateLoadingProgress(loadingProgress.Value)

local tweenInfo = TweenInfo.new(
    1.8,
    Enum.EasingStyle.Quart,
    Enum.EasingDirection.Out
)

local tweenLeft = TweenService:Create(leftText, tweenInfo, {
    Position = UDim2.new(0, 52, 0, 28)
})

local tweenRight = TweenService:Create(rightText, tweenInfo, {
    Position = UDim2.new(0, 52, 0, 85)
})

local blurIn = TweenService:Create(blur, TweenInfo.new(0.8), { Size = 18 })
local blurOut = TweenService:Create(blur, TweenInfo.new(1.2), { Size = 0 })
local topRunnerTween = TweenService:Create(
    topRunner,
    TweenInfo.new(1.05, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
    { Position = UDim2.new(1, 0, 0, 0) }
)
local bottomRunnerTween = TweenService:Create(
    bottomRunner,
    TweenInfo.new(1.05, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
    { Position = UDim2.new(0, -150, 0, 0) }
)
local loadingTween = TweenService:Create(
    loadingProgress,
    TweenInfo.new(3.5, Enum.EasingStyle.Linear),
    { Value = 100 }
)
local nearGlowTween = TweenService:Create(
    panelGlowNear,
    TweenInfo.new(1.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
    { Transparency = 0.35 }
)
local farGlowTween = TweenService:Create(
    panelGlowFar,
    TweenInfo.new(1.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
    { Transparency = 0.72 }
)

blurIn:Play()
tweenLeft:Play()
tweenRight:Play()
topRunnerTween:Play()
bottomRunnerTween:Play()
loadingTween:Play()
nearGlowTween:Play()
farGlowTween:Play()

task.wait(3.5)
loadingProgress.Value = 100

local fadeInfo = TweenInfo.new(1.5)

TweenService:Create(leftText, fadeInfo, {
    TextTransparency = 1,
    TextStrokeTransparency = 1
}):Play()

TweenService:Create(rightText, fadeInfo, {
    TextTransparency = 1,
    TextStrokeTransparency = 1
}):Play()

TweenService:Create(loadingLabel, fadeInfo, {
    TextTransparency = 1,
    TextStrokeTransparency = 1
}):Play()

TweenService:Create(techPanel, fadeInfo, {
    BackgroundTransparency = 1
}):Play()

TweenService:Create(backdrop, fadeInfo, {
    BackgroundTransparency = 1
}):Play()

for _, stroke in ipairs({ panelStroke, panelGlowNear, panelGlowFar, loadingStroke }) do
    TweenService:Create(stroke, fadeInfo, {
        Transparency = 1
    }):Play()
end

for _, line in ipairs({ topRail, bottomRail, sideMarker, topRunner, bottomRunner, loadingTrack, loadingFill }) do
    TweenService:Create(line, fadeInfo, {
        BackgroundTransparency = 1
    }):Play()
end

blurOut:Play()

task.wait(1.5)

gui:Destroy()
blur:Destroy()
