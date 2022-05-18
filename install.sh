#!/bin/bash

function install_ripgrep {
  if [[ $OSTYPE == "linux-gnu"* ]]; then
    apt-get -y install ripgrep
  elif [[ "$(uname)" == "Darwin" ]]; then
    brew install ripgrep
  fi
}

function install_nvim {
  if [[ $OSTYPE == "linux-gnu"* ]]; then
    DEBIAN_FRONTEND=noninteractive apt-get -y install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip
    (
      cd "$HOME"
      rm -rf neovim
      git clone https://github.com/neovim/neovim
      cd neovim
      make CMAKE_BUILD_TYPE=Release install
      cd "$HOME"
      rm -rf neovim
    )
  elif [[ "$(uname)" == "Darwin" ]]; then
    brew install neovim
  fi
}

function install_starship {
  if [[ $OSTYPE == "linux-gnu"* ]]; then
    sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes
  elif [[ "$(uname)" == "Darwin" ]]; then
    brew install starship
  fi
}

function install_zsh {
  if [[ "$(uname)" == "Darwin" ]]; then
    if [[ "$SHELL" != "/bin/zsh" ]]; then
      brew install zsh
    fi

    if [[ "$SHELL" != "/bin/zsh" ]]; then
      chsh -s "$(which zsh)"
    fi
  elif [[ $OSTYPE == "linux-gnu"* ]]; then
    if [[ "$SHELL" != "/bin/zsh" ]]; then
      apt-get -y install zsh
    fi

    sed -i "s|/bin/bash|$(which zsh)|g" /etc/passwd
  fi
}

function drop_dotfiles {
  if [ ! -d "$HOME/.tin" ]; then
    git clone https://github.com/tanvirtin/.tin "$HOME/.tin"
  else
    (
      cd "$HOME/.tin"
      git pull origin HEAD
    )
  fi

  mkdir -p "$HOME/.config"

  if [[ ! -e "$HOME/.config/nvim" && ! -L "$HOME/.config/nvim" ]]; then
    ln -s "$HOME/.tin/nvim" "$HOME/.config/nvim" 
  fi
}

function configure_zsh {
  if [[ ! -e "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
    ln -s "$HOME/.tin/assets/.zshrc" "$HOME/.zshrc"
  fi

  if [[ ! -d "$HOME/.zsh/zsh-autosuggestions" ]]; then
    git clone "https://github.com/zsh-users/zsh-autosuggestions" "$HOME/.zsh/zsh-autosuggestions"
  fi
}

function start_zsh {
  exec "$(which zsh)" -l
}

function cleanup {
  # NOTE (future devs): `pwd` is present working directory meaning,
  # if you execute this script from an arbitary path the pwd will 
  # change `dirname "$0"` will remain constant.
  rm -rf "dirname "$0""
}

function main {
  install_starship
  install_ripgrep
  install_nvim
  install_zsh

  drop_dotfiles

  configure_zsh

  start_zsh
  cleanup

  echo "DONE"
}

main
