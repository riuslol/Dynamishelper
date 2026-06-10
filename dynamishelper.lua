--[[
    DynamisHelper - Ashita v4 Port
    Original Author: Krizz, maintainer: Skyrant
    Ported to Ashita v4 with ImGui Settings Menu.
    Optimized for CatsEyeXI: Separated Normal vs Dreamlands logic & NM safe.
]]--

addon.name      = 'DynamisHelper'
addon.author    = 'Krizz / Skyrant'
addon.version   = '1.1.1'
addon.desc      = 'Tracks Dynamis currency, procs, and staggers.'
addon.link      = 'N/A'

local imgui = require('imgui')
local settings = require('settings')

---------------------------------------------------------------------------------------------------
-- Stagger Data Tables
---------------------------------------------------------------------------------------------------
local staggers = {
    normal = {},
    dreamlands = {
        morning = {},
        day = {},
        night = {}
    }
}

-- [STATIC PROCS - ALL ZONES, BEASTMEN, AND NMs]
staggers.normal.ja = { "Kindred Thief", "Kindred Beastmaster", "Kindred Monk", "Kindred Ninja", "Kindred Ranger", "Duke Gomory", "Marquis Andras", "Marquis Gamygyn", "Count Raum", "Marquis Cimeries", "Marquis Caim", "Baron Avnas", "Hydra Thief", "Hydra Beastmaster", "Hydra Monk", "Hydra Ninja", "Hydra Ranger", "Vanguard Backstabber", "Vanguard Grappler", "Vanguard Hawker", "Vanguard Pillager", "Vanguard Predator", "Voidstreaker Butchnotch", "Steelshank Kratzvatz", "Vanguard Beasttender", "Vanguard Kusa", "Vanguard Mason", "Vanguard Militant", "Vanguard Purloiner", "Ko'Dho Cannonball", "Vanguard Assassin", "Vanguard Liberator", "Vanguard Ogresoother", "Vanguard Salvager", "Vanguard Sentinel", "Wuu Qoho the Razorclaw", "Tee Zaksa the Ceaseless", "Vanguard Ambusher", "Vanguard Hitman", "Vanguard Pathfinder", "Vanguard Pit", "Vanguard Welldigger", "Bandrix Rockjaw", "Lurklox Dhalmelneck", "Trailblix Goatmug", "Kikklix Longlegs", "Snypestix Eaglebeak", "Jabkix Pigeonpecs", "Blazox Boneybod", "Bootrix Jaggedelbow", "Mobpix Mucousmouth", "Prowlox Barrelbelly", "Slystix Megapeepers", "Feralox Honeylips", "Bordox Kittyback", "Droprix Granitepalms", "Routsix Rubbertendon", "Slinkix Trufflesniff", "Swypestix Tigershins", "Woodnix Shrillwhistle", "Hamfist Gukhbuk", "Lyncean Juwgneg", "Va'Rhu Bodysnatcher", "Doo Peku the Fleetfoot", "Nant'ina", "Antaeus" }
staggers.normal.magic = { "Kindred White Mage", "Kindred Bard", "Kindred Summoner", "Kindred Black Mage", "Kindred Red Mage", "Duke Berith", "Marquis Decarabia", "Prince Seere", "Marquis Orias", "Marquis Nebiros", "Duke Haures", "Hydra White Mage", "Hydra Bard", "Hydra Summoner", "Hydra Black Mage", "Hydra Red Mage", "Vanguard Amputator", "Vanguard Bugler", "Vanguard Dollmaster", "Vanguard Mesmerizer", "Vanguard Vexer", "Soulsender Fugbrag", "Reapertongue Gadgquok", "Battlechoir Gitchfotch", "Vanguard Constable", "Vanguard Minstrel", "Vanguard Protector", "Vanguard Thaumaturge", "Vanguard Undertaker", "Gi'Pha Manameister", "Gu'Nhi Noondozer", "Ra'Gho Darkfount", "Va'Zhe Pummelsong", "Vanguard Chanter", "Vanguard Oracle", "Vanguard Prelate", "Vanguard Priest", "Vanguard Visionary", "Loo Hepe the Eyepiercer", "Xoo Kaza the Solemn", "Haa Pevi the Stentorian", "Xuu Bhoqa the Enigma", "Fuu Tzapo the Blessed", "Naa Yixo the Stillrage", "Vanguard Alchemist", "Vanguard Enchanter", "Vanguard Maestro", "Vanguard Necromancer", "Vanguard Shaman", "Elixmix Hooknose", "Gabblox Magpietongue", "Hermitrix Toothrot", "Humnox Drumbelly", "Morgmox Moldnoggin", "Mortilox Wartpaws", "Distilix Stickytoes", "Jabbrox Grannyguise", "Quicktrix Hexhands", "Wilywox Tenderpalm", "Ascetox Ratgums", "Brewnix Bittypupils", "Gibberox Pimplebeak", "Morblox Stubthumbs", "Whistrix Toadthroat", "Gosspix Blabblerlips", "Flamecaller Zoeqdoq", "Gi'Bhe Fleshfeaster", "Ree Nata the Melomanic", "Baa Dava the Bibliophage", "Aitvaras" }
staggers.normal.ws = { "Kindred Paladin", "Kindred Warrior", "Kindred Samurai", "Kindred Dragoon", "Kindred Dark Knight", "Count Zaebos", "Duke Scox", "Marquis Sabnak", "King Zagan", "Count Haagenti", "Hydra Paladin", "Hydra Warrior", "Hydra Samurai", "Hydra Dragoon", "Hydra Dark Knight", "Vanguard Footsoldier", "Vanguard Gutslasher", "Vanguard Impaler", "Vanguard Neckchopper", "Vanguard Trooper", "Wyrmgnasher Bjakdek", "Bladerunner Rokgevok", "Bloodfist Voshgrosh", "Spellspear Djokvukk", "Vanguard Defender", "Vanguard Drakekeeper", "Vanguard Hatamoto", "Vanguard Vigilante", "Vanguard Vindicator", "Ze'Vho Fallsplitter", "Zo'Pha Forgesoul", "Bu'Bho Truesteel", "Vanguard Exemplar", "Vanguard Inciter", "Vanguard Partisan", "Vanguard Persecutor", "Vanguard Skirmisher", "Maa Febi the Steadfast", "Muu Febi the Steadfast", "Vanguard Armorer", "Vanguard Dragontamer", "Vanguard Ronin", "Vanguard Smithy", "Buffrix Eargone", "Cloktix Longnail", "Sparkspox Sweatbrow", "Ticktox Beadyeyes", "Tufflix Loglimbs", "Wyrmwix Snakespecs", "Karashix Swollenskull", "Smeltix Thickhide", "Wasabix Callusdigit", "Anvilix Sootwrists", "Scruffix Shaggychest", "Tymexox Ninefingers", "Scourquix Scaleskin", "Draklix Scalecrust", "Moltenox Stubthumbs", "Ruffbix Jumbolobes", "Shisox Widebrow", "Tocktix Thinlids", "Shamblix Rottenheart", "Elvaansticker Bxafraff", "Qu'Pho Bloodspiller", "Te'Zha Ironclad", "Koo Rahi the Levinblade", "Barong", "Alklha", "Stihi", "Fairy Ring", "Stcemqestcint", "Stringes", "Suttung" }

-- [DREAMLANDS - NIGHTMARE MOBS ONLY]
local nm_group_A = { "Nightmare Crawler", "Nightmare Raven", "Nightmare Uragnite", "Nightmare Fly", "Nightmare Flytrap", "Nightmare Funguar", "Nightmare Gaylas", "Nightmare Kraken", "Nightmare Roc", "Nightmare Hornet", "Nightmare Bugard" }
local nm_group_B = { "Nightmare Bunny", "Nightmare Eft", "Nightmare Mandragora", "Nightmare Hippogryph", "Nightmare Sabotender", "Nightmare Sheep", "Nightmare Snoll", "Nightmare Stirge", "Nightmare Weapon", "Nightmare Makara", "Nightmare Cluster" }
local nm_group_C = { "Nightmare Crab", "Nightmare Dhalmel", "Nightmare Scorpion", "Nightmare Goobbue", "Nightmare Manticore", "Nightmare Treant", "Nightmare Diremite", "Nightmare Tiger", "Nightmare Raptor", "Nightmare Leech", "Nightmare Worm" }

staggers.dreamlands.morning.ja    = nm_group_A
staggers.dreamlands.morning.magic = nm_group_B
staggers.dreamlands.morning.ws    = nm_group_C
staggers.dreamlands.morning.random = { "Nightmare Taurus" }

staggers.dreamlands.day.ja    = nm_group_B
staggers.dreamlands.day.magic = nm_group_C
staggers.dreamlands.day.ws    = nm_group_A
staggers.dreamlands.day.random = { "Nightmare Taurus" }

staggers.dreamlands.night.ja    = nm_group_C
staggers.dreamlands.night.magic = nm_group_A
staggers.dreamlands.night.ws    = nm_group_B
staggers.dreamlands.night.random = { "Nightmare Taurus" }


-- Currency Tracking Array
local Currency = {
    ["Ordelle Bronzepiece"] = 0, ["Montiont Silverpiece"] = 0, ["One Byne Bill"] = 0,
    ["One Hundred Byne Bill"] = 0, ["Tukuku Whiteshell"] = 0, ["Lungo-Nango Jadeshell"] = 0,
    ["Forgotten Thought"] = 0, ["Forgotten Hope"] = 0, ["Forgotten Touch"] = 0,
    ["Forgotten Journey"] = 0, ["Forgotten Step"] = 0
}

local proctype = {"ja", "magic", "ws", "random"}

-- Dynamis Zone Definitions
local dynamis_zones = {
    [39] = true, [40] = true, [41] = true, [42] = true, -- Dreamlands
    [134] = true, [135] = true,                         -- North
    [185] = true, [186] = true, [187] = true, [188] = true -- Cities
}

-- State variables
local stagger_count = 0
local current_proc = "Unknown"
local current_mob = ""
local current_zone_type = "None"

-- ImGui UI Tracking Arrays
local ui = {
    config_open  = { false },
    tracker_open = { true },
    proc_open    = { true }
}

-- Configuration Setup & Registration (Hardened against nil values)
local default_settings = {
    timer = false,
    tracker = false,
    proc = false,
}

local config = default_settings

settings.register('settings', 'settings_update', function(s)
    if s ~= nil then
        config = s
    end
end)

-- Safe load: If the file is broken or empty, it forces default_settings
local loaded_settings = settings.load(default_settings)
if loaded_settings ~= nil then
    config = loaded_settings
end

---------------------------------------------------------------------------------------------------
-- Functions
---------------------------------------------------------------------------------------------------

-- Calculates exact Vana'diel Time mathematically using the Earth epoch, bypassing memory pointers
local function GetVanaTimeMinutes()
    local vana_epoch = 1009810800 -- Jan 1, 2002 00:00:00 JST in Unix Time
    local earth_seconds = os.time() - vana_epoch
    local vana_seconds = earth_seconds * 25
    local vana_minutes = math.floor(vana_seconds / 60)
    return vana_minutes % 1440 -- Returns the exact minute of the current Vana'diel day (0-1439)
end

local function check_zone()
    local party = AshitaCore:GetMemoryManager():GetParty()
    if party then
        local zone = party:GetMemberZone(0)
        if dynamis_zones[zone] then
            if zone >= 39 and zone <= 42 then
                current_zone_type = "Dreamlands"
            else
                current_zone_type = "Normal"
            end
        else
            current_zone_type = "None"
        end
    end
end

local function reset_currency()
    for k, _ in pairs(Currency) do
        Currency[k] = 0
    end
end

---------------------------------------------------------------------------------------------------
-- Commands Hook
---------------------------------------------------------------------------------------------------
ashita.events.register('command', 'command_cb', function(e)
    local args = e.command:args()
    -- Safely bypass if it's not our command
    if args[1] ~= '/dhelper' and args[1] ~= '/dynamishelper' then
        return
    end

    e.blocked = true

    if #args < 2 or args[2] == nil or string.lower(args[2]) == 'help' then
        print('\31\200[\31\05DynamisHelper\31\200]\30\01: Commands:')
        print(' /dhelper config           : Opens the Settings UI.')
        print(' /dhelper timer [on/off]   : Echoes when a stagger occurs.')
        print(' /dhelper tracker [on/off/reset] : Tracks obtained currency.')
        print(' /dhelper proc [on/off]    : Displays the current proc for the target.')
        return
    end

    local cmd = string.lower(args[2])
    
    if cmd == 'config' or cmd == 'menu' then
        ui.config_open[1] = not ui.config_open[1]
        
    elseif cmd == 'timer' and args[3] then
        if string.lower(args[3]) == 'on' then config.timer = true print('Timer enabled.')
        elseif string.lower(args[3]) == 'off' then config.timer = false print('Timer disabled.') end
        settings.save()
        
    elseif cmd == 'tracker' and args[3] then
        if string.lower(args[3]) == 'on' then config.tracker = true print('Tracker enabled.')
        elseif string.lower(args[3]) == 'off' then config.tracker = false print('Tracker disabled.')
        elseif string.lower(args[3]) == 'reset' then reset_currency() print('Tracker reset.') end
        settings.save()
        
    elseif cmd == 'proc' and args[3] then
        if string.lower(args[3]) == 'on' then config.proc = true print('Proc tracking enabled.')
        elseif string.lower(args[3]) == 'off' then config.proc = false print('Proc tracking disabled.') end
        settings.save()
    end
end)

---------------------------------------------------------------------------------------------------
-- Chat / Text parsing
---------------------------------------------------------------------------------------------------
ashita.events.register('text_in', 'text_in_cb', function(e)
    if e.injected then return end

    local msg = e.message:gsub("[\x01-\x1F\x7F]", "")

    if config.timer then
        if msg:match("%w+'s attack staggers the .*!") then
            stagger_count = stagger_count + 1
            AshitaCore:GetChatManager():QueueCommand(1, '/echo [DynamisHelper] Stagger ' .. stagger_count .. ' triggered!')
        end
    end

    if config.tracker then
        for currency_name, _ in pairs(Currency) do
            if msg:lower():match("obtains.*" .. currency_name:lower()) then
                Currency[currency_name] = Currency[currency_name] + 1
            end
        end
    end
end)

---------------------------------------------------------------------------------------------------
-- Rendering & Polling
---------------------------------------------------------------------------------------------------
ashita.events.register('d3d_present', 'd3d_present_cb', function()
    -- Render Configuration Menu (This can be opened anywhere)
    if ui.config_open[1] then
        imgui.SetNextWindowSize({ 270, 170 })
        if imgui.Begin('DynamisHelper Settings', ui.config_open) then
            
            local timer_state = { config.timer or false }
            if imgui.Checkbox('Enable Stagger Timer Echo', timer_state) then
                config.timer = timer_state[1]
                settings.save()
            end

            local tracker_state = { config.tracker or false }
            if imgui.Checkbox('Enable Currency Tracker Window', tracker_state) then
                config.tracker = tracker_state[1]
                settings.save()
            end

            local proc_state = { config.proc or false }
            if imgui.Checkbox('Enable Target Proc Window', proc_state) then
                config.proc = proc_state[1]
                settings.save()
            end

            imgui.Separator()

            if imgui.Button('Reset Currency Tracker', { 180, 25 }) then
                reset_currency()
                AshitaCore:GetChatManager():QueueCommand(1, '/echo [DynamisHelper] Currency tracker reset.')
            end
        end
        imgui.End()
    end

    -- Stop rendering the rest of the UI if we aren't in Dynamis
    check_zone()
    if current_zone_type == "None" then return end

    -- Poll Target & Calculate Proc Window
    if config.proc then
        local target = AshitaCore:GetMemoryManager():GetTarget()
        local t_index = target:GetTargetIndex(0)
        
        if t_index == 0 then
            current_mob = ""
            current_proc = "Unknown"
        else
            local name = AshitaCore:GetMemoryManager():GetEntity():GetName(t_index)
            if name and name ~= current_mob then
                current_mob = name
                current_proc = "Unknown"
                
                -- Step 1: Check the static table (Covers all NMs and Beastmen across all zones)
                for i = 1, #proctype do
                    if staggers.normal[proctype[i]] then
                        for j = 1, #staggers.normal[proctype[i]] do
                            if current_mob == staggers.normal[proctype[i]][j] then
                                if proctype[i] == 'ja' then current_proc = 'Job Ability'
                                elseif proctype[i] == 'magic' then current_proc = 'Magic'
                                elseif proctype[i] == 'ws' then current_proc = 'Weapon Skill'
                                else current_proc = proctype[i] end
                                break
                            end
                        end
                    end
                end

                -- Step 2: If not found, and it is a Nightmare family mob, calculate mathematically
                if current_proc == "Unknown" and current_mob:match("^Nightmare ") then
                    local vTime = GetVanaTimeMinutes()
                    local window = 'morning'
                    
                    if vTime >= 0 and vTime < 480 then window = 'morning'
                    elseif vTime >= 480 and vTime < 960 then window = 'day'
                    else window = 'night' end

                    local target_table = staggers.dreamlands[window]

                    for i = 1, #proctype do
                        if target_table[proctype[i]] then
                            for j = 1, #target_table[proctype[i]] do
                                if current_mob == target_table[proctype[i]][j] then
                                    if proctype[i] == 'ja' then current_proc = 'Job Ability'
                                    elseif proctype[i] == 'magic' then current_proc = 'Magic'
                                    elseif proctype[i] == 'ws' then current_proc = 'Weapon Skill'
                                    else current_proc = proctype[i] end
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Render Tracker Window
    if config.tracker and ui.tracker_open[1] then
        imgui.SetNextWindowSize({ 200, 150 })
        if imgui.Begin('Dynamis Currency', ui.tracker_open) then
            local total_drops = 0
            for k, v in pairs(Currency) do
                if v > 0 then
                    imgui.Text(string.format("%s: %d", k, v))
                    total_drops = total_drops + v
                end
            end
            if total_drops == 0 then
                imgui.Text("No currency obtained yet.")
            end
        end
        imgui.End()
    end

    -- Render Proc Window
    if config.proc and current_mob ~= "" and ui.proc_open[1] then
        imgui.SetNextWindowSize({ 220, 80 })
        if imgui.Begin('Dynamis Proc', ui.proc_open) then
            imgui.Text("Target: " .. current_mob)
            imgui.Text("Proc: " .. current_proc)
        end
        imgui.End()
    end
end)
