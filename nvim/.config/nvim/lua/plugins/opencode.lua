local function terminal(cmd, action, cwd)
  if vim.fn.executable("opencode") ~= 1 then
    vim.notify("Install OpenCode V2 to use the AI shortcuts", vim.log.levels.ERROR)
    return
  end
  return Snacks.terminal[action](cmd, {
    cwd = cwd or LazyVim.root.get(),
    win = { position = "right", width = 0.4 },
  })
end

return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>a", nil, desc = "AI/OpenCode" },
      {
        "<leader>ac",
        function()
          terminal({ "opencode" }, "toggle")
        end,
        desc = "Toggle OpenCode",
      },
      {
        "<leader>af",
        function()
          terminal({ "opencode" }, "focus")
        end,
        desc = "Focus OpenCode",
      },
      {
        "<leader>ar",
        function()
          terminal({ "opencode", "--continue" }, "toggle")
        end,
        desc = "Resume OpenCode",
      },
      {
        "<leader>as",
        function()
          local cwd = LazyVim.root.get()
          local start = vim.fn.getpos("v")
          local finish = vim.fn.getpos(".")
          local lines = vim.fn.getregion(start, finish, {
            type = vim.fn.mode(),
            exclusive = vim.o.selection == "exclusive",
          })
          local path = vim.api.nvim_buf_get_name(0)
          local context = ("%s:%d-%d\n%s"):format(
            path ~= "" and path or "[unnamed buffer]",
            math.min(start[2], finish[2]),
            math.max(start[2], finish[2]),
            table.concat(lines, "\n")
          )
          vim.ui.input({ prompt = "Ask OpenCode about selection: " }, function(prompt)
            if prompt and vim.trim(prompt) ~= "" then
              terminal({ "opencode", "--prompt", prompt .. "\n\n" .. context }, "open", cwd)
            end
          end)
        end,
        mode = "x",
        desc = "Ask OpenCode about selection (new session)",
      },
    },
  },
}
