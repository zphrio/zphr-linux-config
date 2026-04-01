return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "weilbith/neotest-gradle",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = function(_, opts)
      local adapter = require("neotest-gradle")
      -- Extend test file detection to include *IT.java (integration tests)
      local original_is_test_file = adapter.is_test_file
      adapter.is_test_file = function(file_path)
        return original_is_test_file(file_path) or file_path:match("IT%.java$") ~= nil
      end
      opts.adapters = opts.adapters or {}
      table.insert(opts.adapters, adapter)
    end,
  },
}
