local menu = {}
local daily_menus
local Job = require('plenary.job')

local translation = {
    ["Monday"] = "Mandag",
    ["Tuesday"] = "Tirsdag",
    ["Wednesday"] = "Onsdag",
    ["Thursday"] = "Torsdag",
    ["Friday"] = "Fredag"
}

menu.setup = function(apiurl)
    if not apiurl then
        vim.schedule(function()
            require("notify")("API URL is not set. Please set it in your config.", "error", { title = "ISSMenu Error" })
        end)
        return
    end
    local weekOfYear = os.date("%V")
    local year = os.date("%Y")
    local url = apiurl .. weekOfYear .. "/" .. year .. "/lunch"

    Job:new({
        command = 'curl',
        args = { '-s', '-X', 'GET', url, '-H', 'accept: */*' },
        on_exit = function(j, return_val)
            vim.schedule(function()
                if return_val == 0 then
                    local result = table.concat(j:result(), "\n")
                    local decoded_data = vim.json.decode(result)
                    if decoded_data and decoded_data.data and decoded_data.data.attributes then
                        daily_menus = decoded_data.data.attributes.daily_menus
                    else
                        require("notify")("Invalid menu data format", "error", { title = "ISSMenu Error" })
                    end
                else
                    require("notify")("Failed to fetch menu data", "error", { title = "ISSMenu Error" })
                end
            end)
        end,
    }):start()
end

menu.call = function()
    local hour = tonumber(os.date("%H"))
    local day = os.date("%A")

    if hour > 16 then
        day = os.date("%A", os.time() + 86400)
    end

    local danish_day = translation[day]

    if not danish_day then
        vim.schedule(function()
            require("notify")("No menu for the weekend :-)", "info")
        end)
        return
    end

    if not daily_menus then
        vim.schedule(function()
            require("notify")("Menu data is not loaded yet.", "warning")
        end)
        return
    end

    local menu_for_today = nil
    for _, dmenu in ipairs(daily_menus) do
        if dmenu.weekday == danish_day then
            menu_for_today = dmenu.menu_items
            break
        end
    end

    vim.schedule(function()
        if menu_for_today then
            local output = table.concat(vim.tbl_map(function(item) return item.name end, menu_for_today), "\n")
            require("notify")(output, "info", { title = danish_day .. "ens menu" })
        else
            require("notify")("No menu found for today :-(", "error")
        end
    end)
end

vim.api.nvim_create_user_command("ISSMenu", menu.call, { nargs = 0 })

return menu
