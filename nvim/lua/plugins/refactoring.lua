-- refactoring.nvim added lewis6991/async.nvim as a hard dependency but
-- LazyVim's bundled spec doesn't declare it yet.
return {
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "lewis6991/async.nvim",
    },
  },
}
