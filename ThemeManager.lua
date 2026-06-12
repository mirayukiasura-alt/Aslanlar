local cloneref = (cloneref or clonereference or function(instance: any) return instance end)
local httpService = cloneref(game:GetService("HttpService"))
local httprequest = (syn and syn.request) or request or http_request or (http and http.request)
local getassetfunc = getcustomasset or getsynasset
local isfolder, isfile, listfiles = isfolder, isfile, listfiles

if typeof(copyfunction) == "function" then
    local isfolder_copy, isfile_copy, listfiles_copy = copyfunction(isfolder), copyfunction(isfile), copyfunction(listfiles)
    local isfolder_success, isfolder_error = pcall(function()
        return isfolder_copy("test" .. tostring(math.random(1000000, 9999999)))
    end)
    if isfolder_success == false or typeof(isfolder_error) ~= "boolean" then
        isfolder = function(folder) local success, data = pcall(isfolder_copy, folder) return (if success then data else false) end
        isfile = function(file) local success, data = pcall(isfile_copy, file) return (if success then data else false) end
        listfiles = function(folder) local success, data = pcall(listfiles_copy, folder) return (if success then data else {}) end
    end
end

local ThemeManager = {} do
    ThemeManager.Folder = "AslanlarHubThemes"
    ThemeManager.Library = nil

    ThemeManager.BuiltInThemes = {
        ["Aslanlar Custom"] = {
            FontColor = Color3.fromRGB(255, 255, 255),
            MainColor = Color3.fromRGB(18, 18, 18),
            BackgroundColor = Color3.fromRGB(14, 14, 14),
            AccentColor = Color3.fromRGB(255, 50, 160), -- Modern Neon Pembe
            OutlineColor = Color3.fromRGB(32, 32, 32),
            InvertedFontColor = Color3.fromRGB(0, 0, 0)
        }
    }

    function ThemeManager:ApplyTheme(themeName)
        local theme = self.BuiltInThemes[themeName]
        if not theme then return end

        for option, color in pairs(theme) do
            self.Library[option] = color
        end
        self.Library:UpdateColors()
        self.Library:UpdateToggleColors()
    end

    function ThemeManager:SetLibrary(lib)
        self.Library = lib
    end

    function ThemeManager:ApplyToTab(tab)
        -- Temayı ilk açılışta zorunlu olarak yükle
        self:ApplyTheme("Aslanlar Custom")
        
        local groupbox = tab:AddLeftGroupbox("Theme Configuration")
        groupbox:AddLabel("Theme Status: Active", false)
        groupbox:AddButton("Force Reset Theme", function()
            self:ApplyTheme("Aslanlar Custom")
            self.Library:Notify("System", "Theme refitted successfully!")
        end)
    end
end

getgenv().ObsidianThemeManager = ThemeManager
return ThemeManager
