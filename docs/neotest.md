# Neotest Configuration

## Overview

Neotest is configured to work with multiple test frameworks, including
custom Jest wrappers and standard test runners.

## Supported Test Frameworks

- ✅ **Jest** (standard JavaScript/TypeScript)
- ✅ **Custom Jest wrappers** (sku, skuba, or similar)
- ✅ **Vitest** (alternative to Jest)
- ✅ **Go** (via neotest-go)
- ✅ **Python** (via neotest-python with pytest)
- ✅ **Rust** (via neotest-rust)

## Custom Jest Wrappers

Some projects use custom Jest wrappers instead of calling Jest directly.
This configuration supports:

### sku

- **Typical use**: Frontend/React applications
- **Command**: `yarn sku test` (not `yarn jest`)
- **Config**: Custom config file (e.g., `sku.config.ts`)
- **Detection**: Checks for `node_modules/.bin/sku` binary or `"sku"` in package.json

### skuba

- **Typical use**: Backend/Node.js APIs
- **Command**: `yarn skuba test` (not `yarn jest`)
- **Config**: Jest config with custom presets
- **Detection**: Checks for `node_modules/.bin/skuba` binary or `"skuba"` in package.json

## Key Features

### 1. Monorepo Support

- Walks up directory tree to find test framework in any parent package.json
- Works with Yarn/pnpm workspaces where dependencies are in root

### 2. Performance Optimization

- Caches project detection results to avoid redundant filesystem calls
- Reduces overhead from ~10 calls to 1-4 per test run

### 3. Package Manager Detection

- Auto-detects pnpm, yarn, or npm based on lock files
- Uses appropriate command prefix (e.g., `yarn` vs `pnpm exec`)

### 4. Custom Registry Support

- Handles auth tokens required by private registries
- Sets dummy values to prevent config validation errors during test runs

## Known Limitation

**"Force exiting Jest" false failures:**

- **Symptom**: Tests pass but neotest shows them as FAILED
- **Cause**: Jest exits before JSON output file is fully written
- **Impact**: Visual status is incorrect, but test output is still visible
- **Workaround**: Check terminal output, not just the status icons

Despite this limitation, neotest is still valuable for:

- Running tests from Neovim
- Viewing test output inline
- Debugging with DAP
- Quick navigation to test failures

## Keybindings

LazyVim provides these keybindings (under `<leader>t`):

| Key          | Action              | Description                            |
| ------------ | ------------------- | -------------------------------------- |
| `<leader>tt` | Run File            | Run all tests in current file          |
| `<leader>tT` | Run All Tests       | Run all tests in project               |
| `<leader>tr` | Run Nearest         | Run test under cursor                  |
| `<leader>tl` | Run Last            | Re-run last test                       |
| `<leader>ts` | Toggle Summary      | Show/hide test summary window          |
| `<leader>to` | Show Output         | Show test output                       |
| `<leader>tO` | Toggle Output Panel | Toggle output panel                    |
| `<leader>td` | Debug Nearest       | Debug test under cursor (requires DAP) |

## Debugging

### Check if tests are detected

```vim
:lua print(vim.inspect(require('neotest').state.adapter_ids()))
```

### View neotest log

```bash
tail -100 ~/.local/state/nvim/neotest.log
```

### Run test manually

```bash
cd your-project
yarn skuba test path/to/test.ts
# or
yarn sku test path/to/test.tsx
# or
yarn jest path/to/test.ts
```

### Check project detection

```vim
:lua vim.print(require('neotest.adapters.jest').get_project_info())
```

## File Structure

```
nvim/lua/plugins/neotest.lua       # Main configuration
scripts/test-neotest-detection.sh  # Detection validation script
docs/neotest.md                    # This file
```

## Configuration Details

The configuration:

1. **Caches project info** (package manager, framework detection)
2. **Binary detection first** (accurate, works with most package managers)
3. **Package.json fallback** (for Yarn Berry PnP mode)
4. **Custom isTestFile** for monorepo support
5. **Skips --config arg** for custom wrappers (they use their own config systems)
6. **Uses vim.uv._ and io._** (safe in fast event contexts, not vim.fn.\*)

## Troubleshooting

### Tests not detected

1. Check if test file matches pattern: `*.test.[jt]sx?` or `*.spec.[jt]sx?`
2. Verify framework is in package.json (jest/sku/skuba/etc.)
3. Run detection test: `./scripts/test-neotest-detection.sh`
4. Check for errors: `:messages`

### Config validation errors

- Already handled via environment variables
- No action needed

### False FAILED status

- Known limitation, check terminal output instead
- Tests are still running correctly despite status

## Adding New Custom Wrappers

To add support for another Jest wrapper (e.g., `my-jest-wrapper`):

1. Add detection in `get_project_info()`:

   ```lua
   info.has_my_wrapper =
    uv.fs_stat(cwd .. "/node_modules/.bin/my-jest-wrapper") ~= nil
   ```

2. Add command in `jestCommand()`:

   ```lua
   elseif info.has_my_wrapper then
     return "yarn my-jest-wrapper test"
   ```

3. Add config handling in `jestConfigFile()`:

   ```lua
   if info.has_sku or info.has_skuba or info.has_my_wrapper then
     return ".no-config"
   end
   ```

4. Add detection in `isTestFile()`:

   ```lua
   local has_my_wrapper = content:match('"my-jest-wrapper"%s*:') ~= nil
   ```

## References

- [neotest documentation](https://github.com/nvim-neotest/neotest)
- [neotest-jest](https://github.com/nvim-neotest/neotest-jest)
- [LazyVim test.core extra](https://www.lazyvim.org/extras/test/core)
