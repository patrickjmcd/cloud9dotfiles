
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

APT := /usr/bin/apt
YUM := /usr/bin/yum

apt-exists: ; @which apt > /dev/null
check-apt: apt-exists

yum-exists: ; @which yum > /dev/null
check-yum: yum-exists

dev-apt: check-apt 
	@echo "Installing development tools"
	sudo apt-get update
	sudo apt-get -y upgrade
	sudo apt-get install -y build-essential tmux tree
	$(MAKE) apt-postgres-client
	$(MAKE) linux

dev-yum: check-yum 
	@echo "Installing development tools"
	sudo yum update
	sudo yum -y upgrade
	sudo yum install -y tmux tree
	$(MAKE) linux

linux: $(DOTFILE_FOLDER) bashprofile_additions git-ssh $(STARSHIP) $(GO) $(CLOUD9_KEEPALIVE) $(DOCKER_COMPOSE)
	pip3 install thefuck --user

# install go
GO := /usr/local/go/bin/go
$(GO):
	wget https://go.dev/dl/go$(GO_VERSION).linux-amd64.tar.gz -P /tmp
	sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf /tmp/go$(GO_VERSION).linux-amd64.tar.gz
	/usr/local/go/bin/go version > /dev/null

go: $(GO);

# install script to keep cloud9 alive
CLOUD9_KEEPALIVE := ~/.c9/stop-if-inactive.sh
$(CLOUD9_KEEPALIVE):
	sudo mv ~/.c9/stop-if-inactive.sh ~/.c9/stop-if-inactive.sh-SAVE
	curl https://raw.githubusercontent.com/aws-samples/cloud9-to-power-vscode-blog/main/scripts/stop-if-inactive.sh -o ~/.c9/stop-if-inactive.sh
	sudo chown root:root ~/.c9/stop-if-inactive.sh
	sudo chmod 755 ~/.c9/stop-if-inactive.sh

cloud9-keepalive: $(CLOUD9_KEEPALIVE);

# link up dotfiles
DOTFILE_FOLDER := $(HOME)/.dotfiles
$(DOTFILE_FOLDER):
	@echo 'symlinking $(DOTFILE_FOLDER)'
	ln -s $(HOME)/github/patrickjmcd/cloud9dotfiles $(DOTFILE_FOLDER)

dotfile-folder: $(DOTFILE_FOLDER);

# install starship prompt (it's pretty great)
STARSHIP := $(shell which starship > /dev/null)
$(STARSHIP):
	@echo 'Installing starship prompt'
	./starship.sh

starship: $(STARSHIP);

# set up git globabls
git-ssh:
	@echo 'Setting up github ssh'
	git config --global --add url."git@github.com:".insteadOf "https://github.com/"
	@printf "`tput setaf 2`Afterwards, set up your global username and email with:`tput sgr0`\n"
	@printf "`tput setaf 2`\tgit config --global user.name \"YOUR NAME\"`tput sgr0`\n"
	@printf "`tput setaf 2`\tgit config --global user.email me@meshify.com`tput sgr0`\n"
	@echo 'git config --global user.name "YOUR NAME"'
	@echo 'git config --global user.email me@meshify.com'
	./setup_git_ssh.sh

# add necessary lines to .bashprofile
bashprofile-additions:
	@echo 'Adding .bash_profile additions'
	./bashprofile_additions.sh

# install psql client
PSQL := $(shell which psql > /dev/null)
$(PSQL): check-apt
	@echo "Installing postgres client"
	sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(shell lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
	wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
	sudo apt-get update
	sudo apt-get install postgresql-client-common postgresql-client-12

apt-postgres-client: $(PSQL);

# install docker
DOCKER := $(shell which docker > /dev/null)
$(DOCKER): check-apt
	@echo "Installing docker"
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	echo \
  "deb [arch=$(shell dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(shell lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update
	sudo apt-get install docker-ce docker-ce-cli containerd.io

docker: $(DOCKER);

# install docker compose (not docker-compose, because that's GONE)
DOCKER_COMPOSE := $(shell docker compose version > /dev/null)
$(DOCKER_COMPOSE): $(DOCKER)
	@echo "Installing docker compose"
	mkdir -p ~/.docker/cli-plugins/
	curl -SL https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
	chmod +x ~/.docker/cli-plugins/docker-compose
	@echo `docker compose version`

docker-compose: $(DOCKER_COMPOSE);