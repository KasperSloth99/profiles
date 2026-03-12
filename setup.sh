#!/bin/bash -e

SCRIPT_NAME="$0"

function usage() {
	echo "$SCRIPT_NAME [--email] [--name] [--branch]"
	echo "--help              display this message"
	echo "--email             Your email"
	echo "--name              You name"
	echo "--branch            Your main branch name"
}

EMAIL=""
NAME=""
BRANCH=""

function check_input() {
	if [ -z "$1" ]; then
		usage
		exit 1
	fi
}

while [ $# -gt 0 ]; do
	case $1 in
		--email)
			check_input "$2"
			EMAIL="$2"
			shift 2
			;;
		--name)
			check_input "$2"
			shift 1
			while [ $# -gt 0 ] && [[ ! $1 =~ ^-- ]]; do
				NAME+="$1 "
				shift 1
			done
			NAME="${NAME%% }" # Remove trailing space
			;;
		--branch)
			check_input $2
			BRANCH="$2"
			shift 2
			;;
		*)
			usage
			exit 1
			;;
	esac
done

if [ -z "$EMAIL" ] || [ -z "$NAME" ] || [ -z "$BRANCH" ]; then
	usage
	exit 1
fi

# Symlink .gitconfig and .zshrc to home directory
ln -sf "$PWD/.gitconfig" "$HOME/.gitconfig"
ln -sf "$PWD/.zshrc" "$HOME/.zshrc"

# Install zsh if not present
if ! command -v zsh >/dev/null 2>&1; then
	echo "Installing zsh..."
	sudo apt-get update && sudo apt-get install -y zsh
fi

# Install oh-my-zsh if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
	echo "Installing oh-my-zsh..."
	RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install Powerlevel10k theme if not present
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
	echo "Installing Powerlevel10k theme..."
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
fi

if ! grep -q 'export GIT_EMAIL=' "$HOME/.zshrc"; then
	echo "export GIT_EMAIL=\"$EMAIL\"" >> "$HOME/.zshrc"
else
	sed -i "s|^export GIT_EMAIL=.*|export GIT_EMAIL=\"$EMAIL\"|" "$HOME/.zshrc"
fi

if ! grep -q 'export GIT_NAME=' "$HOME/.zshrc"; then
	echo "export GIT_NAME=\"$NAME\"" >> "$HOME/.zshrc"
else
	sed -i "s|^export GIT_NAME=.*|export GIT_NAME=\"$NAME\"|" "$HOME/.zshrc"
fi

if ! grep -q 'export GIT_BRANCH=' "$HOME/.zshrc"; then
	echo "export GIT_BRANCH=\"$BRANCH\"" >> "$HOME/.zshrc"
else
	sed -i "s|^export GIT_BRANCH=.*|export GIT_BRANCH=\"$BRANCH\"|" "$HOME/.zshrc"
fi

echo "Finished setting up .gitconfig and .zshrc"
