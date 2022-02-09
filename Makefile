
#
# Makefile for dotfiles
#
# This file can be used to install individual dotfiles or 
# all of them at once. Each Makefile rule will clean the
# existing dotfile and creating a new symlink.
#
GO_VERSION = 1.17.6

help:
	@echo 'Makefile for dotfiles'
	@echo ''
	@echo 'Usage:'
	@echo '     make all					install everything'
	@echo '     make dev					install tools for a development environment'




APT := /usr/bin/apt
YUM := /usr/bin/yum

apt-exists: ; @which apt > /dev/null
check-apt: apt-exists

yum-exists: ; @which yum > /dev/null
check-yum: yum-exists

GO := /usr/local/go/bin/go
$(GO):
	wget https://go.dev/dl/go$(GO_VERSION).linux-amd64.tar.gz -P /tmp
	sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf /tmp/go$(GO_VERSION).linux-amd64.tar.gz
	/usr/local/go/bin/go version > /dev/null


CLOUD9_KEEPALIVE := ~/.c9/stop-if-inactive.sh
$(CLOUD9_KEEPALIVE):
	sudo mv ~/.c9/stop-if-inactive.sh ~/.c9/stop-if-inactive.sh-SAVE
	curl https://raw.githubusercontent.com/aws-samples/cloud9-to-power-vscode-blog/main/scripts/stop-if-inactive.sh -o ~/.c9/stop-if-inactive.sh
	sudo chown root:root ~/.c9/stop-if-inactive.sh
	sudo chmod 755 ~/.c9/stop-if-inactive.sh

DOTFILE_FOLDER := $(HOME)/.dotfiles
$(DOTFILE_FOLDER):
	@echo 'symlinking $(DOTFILE_FOLDER)'
	ln -s $(HOME)/github/patrickjmcd/cloud9dotfiles $(DOTFILE_FOLDER)

STARSHIP := $(shell which starship)
$(STARSHIP):
	@echo 'Installing starship prompt'
	./starship.sh

git-ssh:
	@echo 'Setting up github ssh'
	git config --global --add url."git@github.com:".insteadOf "https://github.com/"
	git config --global user.name "Patrick McDonagh"
  git config --global user.email patrick@meshify.com
	./setup_git_ssh.sh

bash-profile-additions:
	@echo 'Adding .bash_profile additions'
	./bash_profile_additions.sh

dev-apt: check-apt 
	@echo "Installing development tools"
	sudo apt-get update
	sudo apt-get -y upgrade
	sudo apt-get install -y build-essential tmux tree
	
	$(MAKE) linux

linux: $(DOTFILE_FOLDER) bash_profile_additions git-ssh $(STARSHIP) $(GO) $(CLOUD9_KEEPALIVE)