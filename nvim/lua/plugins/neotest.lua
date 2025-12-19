-- Neotest configuration with language-specific adapters
-- LazyVim already provides test.core extra with base neotest setup
-- This file extends it with additional adapters and customizations

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-go",
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
      "rouge8/neotest-rust",
      "nvim-neotest/neotest-plenary",
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}

      -- Cache project detection to avoid redundant filesystem calls
      local project_cache = {}
      local function get_project_info(cwd)
        cwd = cwd or vim.uv.cwd()
        if project_cache[cwd] then
          return project_cache[cwd]
        end

        local uv = vim.uv
        local info = {
          package_manager = uv.fs_stat(cwd .. "/pnpm-lock.yaml") and "pnpm"
            or uv.fs_stat(cwd .. "/yarn.lock") and "yarn"
            or "npm",
          has_sku = false,
          has_skuba = false,
          jest_config = nil,
        }

        -- Hybrid detection for sku/skuba:
        -- 1. Primary: Check binaries (accurate, works with npm/yarn/pnpm/bun)
        -- 2. Fallback: Check package.json deps only (for Yarn Berry PnP)
        info.has_sku = uv.fs_stat(cwd .. "/node_modules/.bin/sku") ~= nil
        info.has_skuba = uv.fs_stat(cwd .. "/node_modules/.bin/skuba") ~= nil

        -- Fallback to package.json if no binaries found (Yarn Berry PnP mode)
        if not (info.has_sku or info.has_skuba) then
          local pkg_file = cwd .. "/package.json"
          local f = io.open(pkg_file, "r")
          if f then
            local ok, content = pcall(f.read, f, "*all")
            f:close()

            if ok and content then
              -- Check dependencies ONLY (not scripts) to avoid false positives
              -- Pattern: "sku": matches dependency name with colon
              info.has_sku = content:match('"sku"%s*:') ~= nil
              info.has_skuba = content:match('"skuba"%s*:') ~= nil
            end
          end
        end

        -- Detect jest config file
        for _, file in ipairs({ "jest.config.js", "jest.config.ts", "jest.config.mjs" }) do
          if uv.fs_stat(cwd .. "/" .. file) then
            info.jest_config = file
            break
          end
        end

        project_cache[cwd] = info
        return info
      end

      -- Go adapter
      opts.adapters["neotest-go"] = {
        recursive_run = true,
        args = { "-v", "-race", "-count=1", "-timeout=60s" },
        experimental = { test_table = true },
      }

      -- Python adapter
      opts.adapters["neotest-python"] = {
        dap = { justMyCode = false },
        args = { "--log-level", "DEBUG", "-vv" },
        runner = "pytest",
      }

      -- Jest adapter (TypeScript/JavaScript) with custom wrapper support
      opts.adapters["neotest-jest"] = {
        jestCommand = function()
          local info = get_project_info()
          -- Support for custom Jest wrappers (sku for frontend, skuba for backend)
          if info.has_sku then
            return info.package_manager == "pnpm" and "pnpm exec sku test"
              or info.package_manager == "yarn" and "yarn sku test"
              or "npx sku test"
          elseif info.has_skuba then
            return info.package_manager == "pnpm" and "pnpm exec skuba test"
              or info.package_manager == "yarn" and "yarn skuba test"
              or "npx skuba test"
          else
            return info.package_manager == "pnpm" and "pnpm exec jest"
              or info.package_manager == "yarn" and "yarn jest"
              or "npx jest"
          end
        end,
        jestConfigFile = function()
          local info = get_project_info()
          -- Some wrappers use their own config systems, skip --config arg
          if info.has_sku or info.has_skuba then
            return ".no-config"
          end
          return info.jest_config or "jest.config.js"
        end,
        env = {
          CI = true,
          -- Some registries require auth token in env vars
          -- Set dummy value to prevent config validation warnings
          CLOUDSMITH_AUTH_TOKEN = "local-test-run",
        },
        cwd = function()
          return vim.uv.cwd()
        end,
        -- Custom isTestFile to support custom wrappers and monorepos
        -- Uses io.open (safe for fast event contexts, unlike vim.fn.*)
        isTestFile = function(file_path)
          if not file_path then
            return false
          end

          -- Check test file patterns
          local is_test_file = file_path:match("%.test%.[jt]sx?$") or file_path:match("%.spec%.[jt]sx?$")
          if not is_test_file then
            return false
          end

          -- Manually walk up directory tree to find package.json with test framework
          -- (monorepo support: vim.fs.find upward=true stops at first match)
          local current_dir = file_path:match("(.+)/[^/]+$") or "/"

          while current_dir and current_dir ~= "/" and current_dir ~= "" do
            local pkg_file = current_dir .. "/package.json"
            local f = io.open(pkg_file, "r")

            if f then
              local ok, content = pcall(f.read, f, "*all")
              f:close()

              if ok and content then
                -- Check for jest/sku/skuba in package name OR scripts
                local has_jest = content:match('"jest"%s*:') ~= nil or content:match('"scripts".-jest') ~= nil
                local has_sku = content:match('"sku"%s*:') ~= nil or content:match('"scripts".-sku') ~= nil
                local has_skuba = content:match('"skuba"%s*:') ~= nil or content:match('"scripts".-skuba') ~= nil

                if has_jest or has_sku or has_skuba then
                  return true
                end
              end
            end

            -- Move up one directory
            current_dir = current_dir:match("(.+)/[^/]+$")
          end

          return false
        end,
      }

      -- Vitest adapter
      opts.adapters["neotest-vitest"] = {
        vitestCommand = function()
          local info = get_project_info()
          return info.package_manager == "pnpm" and "pnpm exec vitest"
            or info.package_manager == "yarn" and "yarn vitest"
            or "npm exec vitest"
        end,
        filter_dir = function(name)
          return name ~= "node_modules"
        end,
      }

      -- Rust adapter
      opts.adapters["neotest-rust"] = {
        args = { "--no-capture" },
        dap_adapter = "lldb",
      }

      -- Plenary adapter (Neovim plugin development)
      opts.adapters["neotest-plenary"] = {}

      -- UI configuration
      opts.output = vim.tbl_deep_extend("force", opts.output or {}, {
        open_on_run = "short",
      })

      opts.quickfix = vim.tbl_deep_extend("force", opts.quickfix or {}, {
        enabled = true,
        open = false,
      })

      opts.status = vim.tbl_deep_extend("force", opts.status or {}, {
        enabled = true,
        virtual_text = true,
        signs = true,
      })

      opts.discovery = vim.tbl_deep_extend("force", opts.discovery or {}, {
        enabled = true,
        concurrent = 1,
      })

      return opts
    end,
  },

  -- DAP support for Go
  {
    "leoluz/nvim-dap-go",
    optional = true,
    opts = {},
  },
}
