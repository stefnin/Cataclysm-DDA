--Increasing stats by skill
local MOD = {}

local version = 1

mods["StatEvolution"] = MOD

local stats = { "str", "dex", "int", "per" }

local skills = {
    str = { "carpentry", "mechanics", "swimming", "bashing", "cutting", "melee", "throw" },
    dex = { "driving", "survival", "tailor", "traps", "dodge", "stabbing", "unarmed" },
    int = { "barter", "computer", "cooking", "electronics", "fabrication", "firstaid", "speech" },
    per = { "archery", "gun", "launcher", "pistol", "rifle", "shotgun", "smg" }
}

-- skill_to_stat gives the stat associated to the given key skill
-- it is initialized in skill_to_stat
local skill_to_stat = {}

-- skill_usage keeps track for each skill of:
--  - the amount of points learnt in that skill (without taking into account reading)
--  - the current level of that skill (without taking into account reading)
--
-- That "skill level" follows the same evolution formula as the one used in the cdda code,
-- but just counts skill usage - and not reading.

skill_usage = {}

-- Puts the bonus from this mod in a different table
SE_stat_bonus = {}

function SE_log(str)
    game.add_msg(str)
end

function MOD.on_new_player_created()
    -- SE_log("New player starting with StatEvolution")
    -- SE_log(player.name)
    for _, statName in pairs(stats) do
        SE_stat_bonus[statName] = 0
        for _, skill in pairs(skills[statName]) do
            skill_usage[skill] = {}
            skill_usage[skill].skill_amount = 0
            skill_usage[skill].skill_level = 0
        end
    end
end

function MOD.on_skill_used()
    --SE_log("Skill used: "..player.skill_used.." - increase amount: "..player.skill_increase_amount)
    local old_amount = skill_usage[player.skill_used].skill_amount

    -- Note: it is not really required to pass player.skill_used because it can be accessed in SE_functions.check_amount_increase
    -- TODO: compute a new amount based on the skill level

    if (SE_functions.check_amount_increase(player.skill_used)) then
        local new_amount = old_amount + player.skill_increase_amount
        --SE_log("New skill amount: "..new_amount)
        skill_usage[player.skill_used].skill_amount = new_amount
        local current_level = player:get_skill_level(skill_id(player.skill_used))
        if ( skill_usage[player.skill_used].skill_amount  > 100*(current_level+1)*(current_level+1) ) then
            skill_usage[player.skill_used].skill_level = skill_usage[player.skill_used].skill_level + 1
            skill_usage[player.skill_used].skill_amount = 0
        end
    end
end

-- function print_stat(statName)
--     local stat_max_string = statName.."_max"
--     SE_log("Stat max: "..statName.." "..player[stat_max_string])
-- end

function MOD.on_save_player_data()
    -- SE_log("MOD.on_save_player_data")
    local json = require ("data/mods/StatEvolution/dkjson")
    local str1 = json.encode(skill_usage, { indent = true })
    -- SE_log("str1 "..str1)
    player:set_value("skill_usage", str1)
    local str2 = json.encode(SE_stat_bonus, { indent = true })
    -- SE_log("str2 "..str2)
    player:set_value("SE_stat_bonus", str2)
    SE_functions.save()
end

function MOD.on_game_loaded()
    local json = require ("data/mods/StatEvolution/dkjson")
    local pos, err
    local str1 = player:get_value("skill_usage")
    skill_usage, pos, err = json.decode (str1, 1, nil)
    if err then
        -- What to do if there is an error?
    end
    local str2 = player:get_value("SE_stat_bonus")
    SE_stat_bonus, pos, err = json.decode (str2, 1, nil)
    if err then
        -- What to do if there is an error?
    end
    SE_functions.load()
end

function MOD.on_day_passed()
    -- SE_log("A day passed")
    for _, statName in pairs(stats) do
        if (SE_functions.check_stat_increase(statName)) then
            SE_stat_bonus[statName] = SE_stat_bonus[statName] + 1
            increase_stat(statName)
            local stat_max_string = statName.."_max"
            local stat_max = player[stat_max_string]
            print_results(stat_max,statName,stat_max-1)
        end
    end
    player:recalc_hp()
end

function increase_stat(statName)
    local stat_max_string = statName.."_max"
    local stat_max = player[stat_max_string]
    stat_max = stat_max + 1
    player[stat_max_string] = stat_max
end

function print_results(cur_stat,stat,prev_stat)
    if (prev_stat < cur_stat) then
        game.add_msg("Raising "..stat.." to "..tostring(cur_stat))
    elseif (prev_stat > cur_stat) then
        game.add_msg("Lowering "..stat.." to "..tostring(cur_stat))
    end
end

-- Customizable functions

function check_stat_increase_v1(statName)
    --SE_log("Checking stat "..statName)
    local sum = 0
    for _, skill in pairs(skills[statName]) do
        sum = sum + skill_usage[skill].skill_level
    end

    -- 1) get current stat values
    local stat_max_string = statName.."_max"
    local stat_max = player[stat_max_string] -- this is actually the current stat value - when not taking incto account "temporary" bonuses or maluses

    -- 2) compare to skill_points_needed
        local skill_points_needed_to_increase_stat = skill_points_needed(stat_max)
        if (sum >= (skill_points_used[statName] + skill_points_needed_to_increase_stat)) then
            skill_points_used[statName] = skill_points_used[statName] + skill_points_needed_to_increase_stat
            return true
        else
            return false
        end
end

function skill_points_needed(stat)
    return stat + 3
end

function check_amount_increase_v1(skillName)
    --SE_log("skillName : "..skillName)
    local statName = skill_to_stat[skillName]
    --SE_log("statName : "..statName)
    local stat_max_string = statName.."_max"
    local stat_max = player[stat_max_string]
    --SE_log("stat_max : "..stat_max)

    local skillMin = math.floor(stat_max/2) - 2
    --SE_log("skillMin : "..skillMin)
    local current_level = player:get_skill_level(skill_id(player.skill_used))
    --SE_log("current_level : "..current_level)

    if (current_level >= skillMin) then
        return true
    else
        return false
    end
end

function init_v1()
    skill_points_used = {
        str = 0,
        dex = 0,
        int = 0,
        per = 0
    }
end

function save_v1()
    -- SE_log("save_v1")
    local json = require ("data/mods/StatEvolution/dkjson")
    local str = json.encode(skill_points_used, { indent = true })
    player:set_value("SE_skill_points_used",str)
end

function load_v1()
    -- SE_log("load_v1")
    local json = require ("data/mods/StatEvolution/dkjson")
    local pos, err
    local str = player:get_value("SE_skill_points_used")
    skill_points_used, pos, err = json.decode (str, 1, nil)
    if err then
        -- What to do if there is an error?
    end
end

--

SE_functions = {
    check_stat_increase = check_stat_increase_v1,
    check_amount_increase = check_amount_increase_v1,
    init = init_v1,
    save = save_v1,
    load = load_v1
}

--Initialization code

function init_skill_to_stat()
    for _, statName in pairs(stats) do
        for _, skill in pairs(skills[statName]) do
            skill_to_stat[skill] = statName
        end
    end
end

--

init_skill_to_stat()

SE_functions.init()
