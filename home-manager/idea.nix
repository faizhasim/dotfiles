{ config, pkgs, lib, inputs, ... }: {
  home.file.".ideavimrc".text = ''
    let mapleader=" "

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

    Plug 'machakann/vim-highlightedyank'
    Plug 'preservim/nerdtree'

    " weird meta mapping in macOS and sometimes will put caret character
    nnoremap <D-i> :action ActivateTerminalToolWindow<CR>

    nnoremap <s-TAB> :action PreviousTab<CR>
    nnoremap <TAB> :action NextTab<CR>

    nnoremap <leader>e :NERDTree<CR>
    nnoremap <leader>z :action ToggleZenMode<CR>
    nnoremap <leader>lg :action TUILauncher.LazyGit<CR>
    nnoremap <leader>vr :action IdeaVim.ReloadVimRc.reload<CR>

    nnoremap <leader>c :action copilot.chat.show<CR>
    nnoremap <leader>i :action copilot.chat.inline<CR>
  '';

}
