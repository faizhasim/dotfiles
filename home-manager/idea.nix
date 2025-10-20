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
    set NERDTree
    set easymotion

    Plug 'machakann/vim-highlightedyank'

    nnoremap <A-i> :action ActivateTerminalToolWindow<CR>

    nnoremap <TAB> :action PreviousTab<CR>
    nnoremap <s-TAB> :action NextTab<CR>

    nnoremap <leader>e :NERDTree<CR>
    nnoremap <leader>z :action ToggleZenMode<CR>
    nnoremap <leader>lg :action TUILauncher.LazyGit<CR>
    nnoremap <leader>vr :action IdeaVim.ReloadVimRc.reload<CR>

    nnoremap <leader>f <Plug>(easymotion-s)
    nnoremap <leader>e <Plug>(easymotion-f)

  '';

}
