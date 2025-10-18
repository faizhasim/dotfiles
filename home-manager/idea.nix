{ config, pkgs, lib, inputs, ... }: {
  home.file.".ideavimrc".text = ''
    let mapleader = " "

    set clipboard=unnamedplus
    set showmode
    set visualbell
    set ignorecase
    set smartcase
    set incsearch
    set hlsearch
    set ideajoin

    nnoremap <A-i> :action ActivateTerminalToolWindow<CR>
  '';

}
