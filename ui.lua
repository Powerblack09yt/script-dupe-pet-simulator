local _wait = task.wait
repeat _wait() until game:IsLoaded()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local rs_Monsters = ReplicatedStorage:WaitForChild("MonsterSpawn")
local Modules = ReplicatedStorage:WaitForChild("ModuleScript")
local Monsters = workspace:WaitForChild("Monster")

local QuestSettings = Modules:WaitForChild("Quest_Settings")

local NPCs = workspace:WaitForChild("NPCs")
local Raids = workspace:WaitForChild("Raids")
local Location = workspace:WaitForChild("Location")
local Region = workspace:WaitForChild("Region")
local Island = workspace:WaitForChild("Island")

local Quests_Npc = NPCs:WaitForChild("Quests_Npc")
local EnemyLocation = Location:WaitForChild("Enemy_Location")
local QuestLocation = Location:WaitForChild("QuestLocaion")

local Items = Player:WaitForChild("Items")
local QuestFolder = Player:WaitForChild("QuestFolder")
local Ability = Player:WaitForChild("Ability")
local PlayerData = Player:WaitForChild("PlayerData")
local PlayerLevel = PlayerData:WaitForChild("Level")

local sethiddenproperty = sethiddenproperty or (function()end)

local CFrame_Angles = CFrame.Angles
local CFrame_new = CFrame.new
local Vector3_new = Vector3.new

local _huge = math.huge

local Loaded, Funcs, Folders = {}, {}, {} do
  Loaded.WeaponsList = { "Fight", "Power", "Weapon" }
  Loaded.EnemeiesList = {}
  Loaded.EnemiesSpawns = {}
  Loaded.EnemiesQuests = {}
  Loaded.Islands = {}
  Loaded.Quests = {}
  
  local function RedeemCode(Code)
    return ReplicatedStorage.OtherEvent.MainEvents.Code:InvokeServer(Code)
  end
  
  Funcs.RAllCodes = function(self)
    if Modules:FindFirstChild("CodeList") then
      local List = require(Modules.CodeList)
      for Code, Info in pairs(type(List) == "table" and List or {}) do
        if type(Code) == "string" and type(Info) == "table" and Info.Status then RedeemCode(Code) end
      end
    end
  end
  
  Funcs.GetPlayerLevel = function(self)
    return PlayerLevel.Value
  end
  
  Funcs.GetCurrentQuest = function(self)
    for _,Quest in pairs(Loaded.Quests) do
      if Quest.Level <= self:GetPlayerLevel() and not Quest.RaidBoss then
        return Quest
      end
    end
  end
  
  Funcs.CheckQuest = function(self)
    for _,v in ipairs(QuestFolder:GetChildren()) do
      if v.Target.Value ~= "None" then
        return v
      end
    end
  end
  
  Funcs.VerifySword = function(self, SName)
    local Swords = Items.Weapon
    return Swords:FindFirstChild(SName) and Swords[SName].Value > 0
  end
  
  Funcs.VerifyAccessory = function(self, AName)
    local Accessories = Items.Accessory
    return Accessories:FindFirstChild(AName) and Accessories[AName].Value > 0
  end
  
  Funcs.GetMaterial = function(self, MName)
    local ItemStorage = Items.ItemStorage
    return ItemStorage:FindFirstChild(MName) and ItemStorage[MName].Value or 0
  end
  
  Funcs.AbilityUnlocked = function(self, Ablt)
    return Ability:FindFirstChild(Ablt) and Ability[Ablt].Value
  end
  
  local _Quests = require(QuestSettings)
  for Npc,Quest in pairs(_Quests) do
    if not Quest.Special_Quest and QuestLocation:FindFirstChild(Npc) then
      table.insert(Loaded.Quests, {
        RaidBoss = Quest.Raid_Boss,
        NpcName = Npc,
        QuestPos = QuestLocation[Npc].CFrame,
        EnemyPos = EnemyLocation[Quest.Target].CFrame,
        Level = Quest.LevelNeed,
        Enemy = Quest.Target
      })
    end
  end
  
  table.sort(Loaded.Quests, function(a, b) return a.Level > b.Level end)
  for _,v in ipairs(Loaded.Quests) do
    table.insert(Loaded.EnemeiesList, v.Enemy)Loaded.EnemiesQuests[v.Enemy] = v.NpcName
  end
end

local Settings = Settings or {} do
  Settings.BringMobs = true
  Settings.FarmDistance = 9
  Settings.ViewHitbox = false
  Settings.AntiAFK = true
  Settings.AutoHaki = true
  Settings.AutoClick = true
  Settings.ToolFarm = "Fight" -- [[ "Fight", "Power", "Weapon" ]]
  Settings.FarmCFrame = CFrame_new(0, Settings.FarmDistance, 0) * CFrame_Angles(math.rad(-90), 0, 0)
end

local function PlayerClick()
  local Char = Player.Character
  if Char then
    if Settings.AutoClick then
      VirtualUser:CaptureController()
      VirtualUser:Button1Down(Vector2.new(1e4, 1e4))
    end
    if Settings.AutoHaki and Char:FindFirstChild("AuraColor_Folder") and Funcs:AbilityUnlocked("Aura") then
      if #Char.AuraColor_Folder:GetChildren() < 1 then
        ReplicatedStorage.OtherEvent.MainEvents.Ability:InvokeServer("Aura")
      end
    end
  end
end

local function IsAlive(Char)
  local Hum = Char and Char:FindFirstChild("Humanoid")
  return Hum and Hum.Health > 0
end

local function GetNextEnemie(EnemieName)
  for _,v in ipairs(Monsters:GetChildren()) do
    if (not EnemieName or v.Name == EnemieName) and IsAlive(v) then
      return v
    end
  end
  return false
end

local function GoTo(CFrame, Move)
  local Char = Player.Character
  if IsAlive(Char) then
    return Move and ( Char:MoveTo(CFrame.p) or true ) or Char:SetPrimaryPartCFrame(CFrame)
  end
end

local function EquipWeapon()
  local Backpack, Char = Player:FindFirstChild("Backpack"), Player.Character
  if IsAlive(Char) and Backpack then
    for _,v in ipairs(Backpack:GetChildren()) do
      if v:IsA("Tool") and v.ToolTip:find(Settings.ToolFarm) then
        Char.Humanoid:EquipTool(v)
      end
    end
  end
end

local function BringMobsTo(_Enemie, CFrame, SBring)
  for _,v in ipairs(Monsters:GetChildren()) do
    if (SBring or v.Name == _Enemie) and IsAlive(v) and v.PrimaryPart then
      v.PrimaryPart.CFrame = CFrame
      if v:FindFirstChild("Humanoid") then
        local Hum = v.Humanoid
        Hum.WalkSpeed = 0
        Hum:ChangeState(14)
      end
      local PP = v.PrimaryPart
      PP.CanCollide = false
      PP.Transparency = Settings.ViewHitbox and 0.8 or 1
      PP.Size = Vector3.new(50, 50, 50)
    end
  end
  return pcall(sethiddenproperty, Player, "SimulationRadius", _huge)
end

local function KillMonster(_Enemie, SBring)
  local Enemie = typeof(_Enemie) == "Instance" and _Enemie or GetNextEnemie(_Enemie)
  if IsAlive(Enemie) and Enemie.PrimaryPart then
    GoTo(Enemie.PrimaryPart.CFrame * Settings.FarmCFrame)EquipWeapon()PlayerClick()
    if Settings.BringMobs then BringMobsTo(_Enemie, Enemie.PrimaryPart.CFrame, SBring) end
    return true
  end
end

local function TakeQuest(QuestName, CFrame, Wait)
  local QuestGiver = Quests_Npc:FindFirstChild(QuestName)
  if QuestGiver and Player:DistanceFromCharacter(QuestGiver.WorldPivot.p) < 5 then
    return fireproximityprompt(QuestGiver.Block.QuestPrompt), _wait(Wait or 0.1)
  end
  GoTo(CFrame or QuestLocation[QuestName].CFrame)
end

local function ClearQuests(Ignore)
  for _,v in ipairs(QuestFolder:GetChildren()) do
    if v.QuestGiver.Value ~= Ignore and v.Target.Value ~= "None" then
      ReplicatedStorage.OtherEvent.QuestEvents.Quest:FireServer("Abandon_Quest", { QuestSlot = v.Name })
    end
  end
end

local function GetRaidEnemies()
  for _,v in ipairs(Monsters:GetChildren()) do
    if v:GetAttribute("Raid_Enemy") and IsAlive(v) then
      return v
    end
  end
end

local function GetRaidMap()
  for _,v in ipairs(Raids:GetChildren()) do
    if v.Joiners:FindFirstChild(Player.Name) then
      return v
    end
  end
end

local function VerifyQuest(QName)
  local Quest = Funcs:CheckQuest()
  return Quest and Quest.QuestGiver.Value == QName
end

getgenv.FarmFuncs = {
  {"_FloppaSword", (function()
    if not Funcs:VerifySword("Floppa") then
      if VerifyQuest("Cool Floppa Quest") then
        GoTo(CFrame_new(794, -31, -440))
        fireproximityprompt(Island.FloppaIsland["Lava Floppa"].ClickPart.ProximityPrompt)
      else
        ClearQuests("Cool Floppa Quest")
        TakeQuest("Cool Floppa Quest", CFrame_new(758, -31, -424))
      end
      return true
    end
  end)},
  {"MemeBeast1", (function()
    local MemeBeast = Monsters:FindFirstChild("Meme Beast") or rs_Monsters:FindFirstChild("Meme Beast")
    if MemeBeast then
      GoTo(MemeBeast.WorldPivot)EquipWeapon()PlayerClick()
      return true
    end
  end)},
  {"LordSus1", (function()
    local LordSus = Monsters:FindFirstChild("Lord Sus") or rs_Monsters:FindFirstChild("Lord Sus")
    if LordSus then
      if not VerifyQuest("Floppa Quest 32") and Funcs:GetPlayerLevel() >= 1550 then
        ClearQuests("Floppa Quest 32")TakeQuest("Floppa Quest 32", nil, 1)
      else
        KillMonster(LordSus)
      end
      return true
    elseif Funcs:GetMaterial("Sussy Orb") > 0 then
      if Player:DistanceFromCharacter(Vector3_new(6644, -95, 4811)) < 5 then
        fireproximityprompt(Island.ForgottenIsland.Summon3.Summon.SummonPrompt)
      else GoTo(CFrame_new(6644, -95, 4811)) end
      return true
    end
  end)},
  {"EvilNoob1", (function()
    local EvilNoob = Monsters:FindFirstChild("Evil Noob") or rs_Monsters:FindFirstChild("Evil Noob")
    if EvilNoob then
      if not VerifyQuest("Floppa Quest 29") and Funcs:GetPlayerLevel() >= 1400 then
        ClearQuests("Floppa Quest 29")TakeQuest("Floppa Quest 29", nil, 1)
      else
        KillMonster(EvilNoob)
      end
      return true
    elseif Funcs:GetMaterial("Noob Head") > 0 then
      if Player:DistanceFromCharacter(Vector3_new(-2356, -81, 3180)) < 5 then
        fireproximityprompt(Island.MoaiIsland.Summon2.Summon.SummonPrompt)
      else GoTo(CFrame_new(-2356, -81, 3180)) end
      return true
    end
  end)},
  {"GiantPumpkin", (function()
    local Pumpkin = Monsters:FindFirstChild("Giant Pumpkin") or rs_Monsters:FindFirstChild("Giant Pumpkin")
    if Pumpkin then
      if not VerifyQuest("Floppa Quest 23") and Funcs:GetPlayerLevel() >= 1100 then
        ClearQuests("Floppa Quest 23")TakeQuest("Floppa Quest 23", nil, 1)
      else
        KillMonster(Pumpkin)
      end
      return true
    elseif Funcs:GetMaterial("Flame Orb") > 0 then
      if Player:DistanceFromCharacter(Vector3_new(-1180, -93, 1462)) < 5 then
        fireproximityprompt(Island.PumpkinIsland.Summon1.Summon.SummonPrompt)
      else GoTo(CFrame_new(-1180, -93, 1462)) end
      return true
    end
  end)},
  {"Bring Fruits", (function()
    
  end)},
  {"LevelFarm", (function()
    local Quest, QuestChecker = Funcs:GetCurrentQuest(), Funcs:CheckQuest()
    if Quest then
      if QuestChecker then
        local _QuestName = QuestChecker.QuestGiver.Value
        if _QuestName == Quest.NpcName then
          if KillMonster(Quest.Enemy) then else GoTo(Quest.EnemyPos) end
        else
          if KillMonster(QuestChecker.Target.Value) then else GoTo(QuestLocation[_QuestName].CFrame) end
        end
      else TakeQuest(Quest.NpcName) end
    end
    return true
  end)},
  {"RaidFarm", (function()
    if Funcs:GetPlayerLevel() >= 1000 then
      local RaidMap = GetRaidMap()
      if RaidMap then
        local Enemie = GetRaidEnemies()
        if Enemie then KillMonster(Enemie, true) else
          local Spawn = RaidMap:FindFirstChild("Spawn_Location")
          if Spawn then GoTo(Spawn.CFrame) end
        end
      else
        local Raid = Region:FindFirstChild("RaidArea")
        if Raid then GoTo(Raid.CFrame, true) end
      end
      return true
    end
  end)},
  {"FSEnemie", (function()
    local Enemy = getgenv.SelecetedEnemie
    local Quest = Loaded.EnemiesQuests[Enemy]
    if VerifyQuest(Quest) or not getgenv["FStakeQuest"] then
      if KillMonster(Enemy) then else GoTo(EnemyLocation[Enemy].CFrame) end
    else ClearQuests(Quest)TakeQuest(Quest) end
    return true
  end)},
  {"NearestFarm", (function() return KillMonster(GetNextEnemie()) end) }
}

end




local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Caveira hub meme sea " .. Fluent.Version,
    SubTitle = "by Caveira",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    discord = Window:AddTab({ Title = "Discord", Icon = "" }),
    MainFarm = Window:AddTab({ Title = "Farm", Icon = "" }),
    Itens = Window:AddTab({ Title = "Itens", Icon = "" }),
    Stats= Window:AddTab({ Title = "Stats", Icon = "" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "" }),
    Settings = Window:AddTab({ Title = "Misc", Icon = "settings" })
}

local Options = Fluent.Options

do

Tabs.discord:AddButton({
    Title = "Discord invite",
    Description = "copy discord invite",
    Callback = function()
        setclipboard("https://discord.gg/wa4Z2XPVkq")
    end
})

local _MainFarm = Tabs.MainFarm do

local Dropdown = Tabs.MainFarm:AddDropdown("Dropdown", {
    Title = "farm tool",
    Values = Loaded.WeaponsList,
    Multi = false,
    Default = Fight,
})
Dropdown:SetValue("Fight")
Dropdown:OnChanged(function(Value)
end)

local Toggle = Tabs.MainFarm:AddToggle("MyToggle", {Title = "Auto Farm Level", Default = false })
Toggle:OnChanged(function(Value)
  
end)


local Toggle = Tabs.MainFarm:AddToggle("MyToggle", {Title = "Auto farm nearest", Default = false })
    Toggle:OnChanged(function(Value)
    
    end)


  Tabs.MainFarm:AddParagraph({
        Title = "enemies",
        Content = "select enemies"
    })
  
  local Dropdown = Tabs.MainFarm:AddDropdown("Dropdown", {
    Title = "Select Enemie",
    Values = Loaded.EnemeiesList,
    Multi = false,
    Default = Loaded.EnemeiesList[1],
})

Dropdown:SetValue("")

Dropdown:OnChanged(function(Value)
end)


local Toggle = Tabs.MainFarm:AddToggle("MyToggle", {Title = "Auto Farm Selected", Default = false })
Toggle:OnChanged(function()
end)




local Toggle = Tabs.MainFarm:AddToggle("MyToggle", {Title = "Take Quest [ Enemie Selected ]", Default = true })

Toggle:OnChanged(function()

end)

Tabs.MainFarm:AddParagraph({
  Title = "Boss Farm",
  Content = ""
})

local Toggle = Tabs.MainFarm:AddToggle("MyToggle", {Title = "Auto Meme Beast", Default = false })

Toggle:OnChanged(function()

end)


Tabs.MainFarm:AddParagraph({
  Title = "Raid",
  Content = ""
})

local Toggle = Tabs.MainFarm:AddToggle("MyToggle", {Title = "Auto Farm Raid", Default = false })

Toggle:OnChanged(function()
end)







end
end
