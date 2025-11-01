{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  home.file.".ideavimrc".text = ''
    let mapleader=" "
    let maplocalleader="\\"

    set clipboard=unnamedplus
    set clipboard+=unnamed
    set clipboard+=ideaput
    set showmode
    set visualbell
    set ignorecase
    set smartcase
    set incsearch
    set hlsearch
    set ideajoin
    set easymotion
    set which-key

    Plug 'machakann/vim-highlightedyank'
    Plug 'preservim/nerdtree'

    " LazyVim-inspired keymaps for IntelliJ IDEA

    " Terminal (LazyVim: <c-/> for terminal)
    nnoremap <D-i> :action ActivateTerminalToolWindow<CR>
    nnoremap <c-/> :action ActivateTerminalToolWindow<CR>
    inoremap <c-/> <Esc>:action ActivateTerminalToolWindow<CR>

    " Buffer navigation (LazyVim: <S-h>/<S-l> for prev/next buffer)
    nnoremap <S-h> :action PreviousTab<CR>
    nnoremap <S-l> :action NextTab<CR>
    nnoremap [b :action PreviousTab<CR>
    nnoremap ]b :action NextTab<CR>

    " Buffer management
    nnoremap <leader>bb :action Switcher<CR>
    nnoremap <leader>` :action Switcher<CR>
    nnoremap <leader>bd :action CloseContent<CR>
    nnoremap <leader>bo :action CloseAllEditorsButActive<CR>

    " File explorer (LazyVim: <leader>e for file explorer)
    nnoremap <leader>e :action SelectInProjectView<CR>
    nnoremap <leader>E :action SelectInProjectView<CR>
    nnoremap <leader>fe :action SelectInProjectView<CR>
    nnoremap <leader>fE :action SelectInProjectView<CR>

    " File navigation (LazyVim patterns)
    nnoremap <leader><space> :action GotoFile<CR>
    nnoremap <leader>ff :action GotoFile<CR>
    nnoremap <leader>fr :action RecentFiles<CR>
    nnoremap <leader>fg :action GotoFile<CR>
    nnoremap <leader>fb :action RecentFiles<CR>
    nnoremap <leader>fn :action NewFile<CR>

    " Search (LazyVim: <leader>/ for grep)
    nnoremap <leader>/ :action FindInPath<CR>
    nnoremap <leader>sg :action FindInPath<CR>
    nnoremap <leader>sw :action FindInPath<CR>
    vnoremap <leader>sw :action FindInPath<CR>

    " LSP actions (LazyVim patterns)
    nnoremap gd :action GotoDeclaration<CR>
    nnoremap gr :action FindUsages<CR>
    nnoremap gI :action GotoImplementation<CR>
    nnoremap gy :action GotoTypeDeclaration<CR>
    nnoremap K :action QuickJavaDoc<CR>
    nnoremap <leader>ca :action ShowIntentionActions<CR>
    vnoremap <leader>ca :action ShowIntentionActions<CR>
    nnoremap <leader>cr :action RenameElement<CR>
    nnoremap <leader>cf :action ReformatCode<CR>
    vnoremap <leader>cf :action ReformatCode<CR>
    nnoremap <leader>cd :action ShowErrorDescription<CR>
    nnoremap [d :action GotoPreviousError<CR>
    nnoremap ]d :action GotoNextError<CR>

    " Code structure (LazyVim: <leader>cs for symbols)
    nnoremap <leader>cs :action FileStructurePopup<CR>
    nnoremap <leader>ss :action FileStructurePopup<CR>

    " Git (LazyVim patterns)
    nnoremap <leader>gg :action TUILauncher.LazyGit<CR>
    nnoremap <leader>gb :action Annotate<CR>
    nnoremap <leader>gl :action Vcs.Show.Log<CR>
    nnoremap <leader>gf :action Vcs.ShowTabbedFileHistory<CR>

    " Zen/Focus mode (LazyVim: <leader>uz for zen mode)
    nnoremap <leader>uz :action ToggleZenMode<CR>
    nnoremap <leader>z :action ToggleZenMode<CR>

    " LazyGit integration
    nnoremap <leader>lg :action TUILauncher.LazyGit<CR>

    " Window management (LazyVim patterns)
    nnoremap <leader>- :action SplitHorizontally<CR>
    nnoremap <leader>| :action SplitVertically<CR>
    nnoremap <leader>wd :action CloseContent<CR>
    nnoremap <c-h> :action PrevSplitter<CR>
    nnoremap <c-j> :action PrevSplitter<CR>
    nnoremap <c-k> :action NextSplitter<CR>
    nnoremap <c-l> :action NextSplitter<CR>

    " Diagnostics/Quickfix (LazyVim patterns)
    nnoremap <leader>xl :action ActivateProblemsViewToolWindow<CR>
    nnoremap <leader>xx :action ActivateProblemsViewToolWindow<CR>
    nnoremap ]q :action GotoNextError<CR>
    nnoremap [q :action GotoPreviousError<CR>

    " AI/Copilot (matching your existing setup)
    nnoremap <leader>aa :action copilot.chat.show<CR>
    nnoremap <leader>ac :action copilot.chat.show<CR>

    " Utilities
    nnoremap <leader>l :action ShowSettings<CR>
    nnoremap <leader>vr :action IdeaVim.ReloadVimRc.reload<CR>
    nnoremap <c-s> :action SaveAll<CR>
    inoremap <c-s> <Esc>:action SaveAll<CR>

    " Clear search highlight (LazyVim: <esc> clears hlsearch)
    nnoremap <esc> :nohlsearch<CR>
  '';

}
