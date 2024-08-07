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



local Dropdown = Tabs.MainFarm:AddDropdown("Dropdown", {
    Title = "farm tool",
    Values = ,
    Multi = false,
    Default = ,
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
    Values = ,
    Multi = false,
    Default = ,
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
