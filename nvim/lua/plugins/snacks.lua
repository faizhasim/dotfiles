return {
  "snacks.nvim",
  opts = function(_, opts)
    local logo = {
      "░▀█▀░█░█░▀█▀░█▀▀░░░▀█▀░█▀▀░░░█▀▀░▀█▀░█▀█░█▀▀░░░░░░░░░",
      "░░█░░█▀█░░█░░▀▀█░░░░█░░▀▀█░░░█▀▀░░█░░█░█░█▀▀░░░░░░░░░",
      "░░▀░░▀░▀░▀▀▀░▀▀▀░░░▀▀▀░▀▀▀░░░▀░░░▀▀▀░▀░▀░▀▀▀░▀░░▀░░▀░",
      "",
      "  Kubernetes Cluster      :  🟢  healthy (pending reality check)      ",
      "  GitHub Merge Conflicts  :  🔴  42 files need divine intervention    ",
      "  ArgoCD Sync             :  🟠  out-of-sync (but spiritually aligned)",
      "  Buildkite Pipeline      :  🟡  still running since last Friday      ",
      "  Jira Ticket             :  🟣  moved to “Almost Done (™)”           ",
      "  Git Rebase              :  🟠  branch ‘fix/fix-fix’ collapsed again ",
      "  Observability           :  🟢  metrics unknown, but vibes are good  ",
    }

    opts.dashboard.preset.header = table.concat(logo, "\n")
    opts.terminal.win.position = "float"
  end,
}
