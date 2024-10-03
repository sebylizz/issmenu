# Menu of the day (ISS menu)

Using lazy:

```lua
return {
    "sebylizz/issmenu",
    event = "VimEnter",
    dependencies = {"rcarriga/nvim-notify", "nvim-lua/plenary.nvim"},
    config = function()
        local apiurl = "YOUR-ISS-MENU-URL"
        require("issmenu").setup(apiurl)
    end,
    keys = {
        vim.keymap.set("n", "<leader>md", "<cmd>ISSMenu<CR>", {noremap = true, silent = true})
    }
}
```
