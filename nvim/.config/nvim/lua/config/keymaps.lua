-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>cf", function()
  local root = LazyVim.root.get()
  vim.notify("Running spotlessApply...", vim.log.levels.INFO)
  vim.fn.jobstart({ "./gradlew", "spotlessApply" }, {
    cwd = root,
    on_exit = function(_, code)
      if code == 0 then
        vim.schedule(function()
          vim.notify("spotlessApply completed", vim.log.levels.INFO)
          vim.cmd("checktime")
        end)
      else
        vim.schedule(function()
          vim.notify("spotlessApply failed (exit " .. code .. ")", vim.log.levels.ERROR)
        end)
      end
    end,
  })
end, { desc = "Format (spotlessApply)" })
