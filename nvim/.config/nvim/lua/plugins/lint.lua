return {
  -- Disable markdownlint-cli2 diagnostics (MD013 line-length, MD060, etc.)
  -- pulled in by the LazyVim markdown extra. Too noisy for prose.
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.markdown = {}
      opts.linters_by_ft["markdown.mdx"] = {}
    end,
  },
}
