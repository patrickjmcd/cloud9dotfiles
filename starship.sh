#! /bin/bash

echo "Setting up Starship Prompt"
sudo sh -c "$(curl -fsSL https://starship.rs/install.sh)"
grep -qxF 'eval "$(starship init bash)"' $HOME/.bashrc || echo 'eval "$(starship init bash)"' >> $HOME/.bashrc

echo "Setting up BLE for autocompletion"
make -C ble.sh install PREFIX=~/.local
grep -qxF 'source ~/.local/share/blesh/ble.sh' $HOME/.bashrc || echo 'source ~/.local/share/blesh/ble.sh' >> $HOME/.bashrc
