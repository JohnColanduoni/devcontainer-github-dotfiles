#! /bin/bash

set -exo pipefail

CHECKOUT_PATH=/workspaces/.codespaces/.persistedshare/dotfiles
install_script_options=("install.sh" "install" "bootstrap.sh" "script/bootstrap" "setup.sh" "setup" "script/setup")

# Fix volume permissions
if [ "$(id -u)" != "0" ]; then
    sudo chown -R "$USER:$USER" "$CHECKOUT_PATH"
fi

if [ ! -d "$CHECKOUT_PATH/.git" ]; then
    set +e
    output=`ssh -T git@github.com 2>&1`
    set -e
    username_regex='Hi ([a-zA-Z0-9-]+)(.*)'
    if [[ $output =~ $username_regex ]]; then
        GITHUB_USERNAME="${BASH_REMATCH[1]}"
    else
        echo "Unable to detect user from SSH key, unable to pull GitHub dotfiles" >&2
        exit 1
    fi

    git clone "git@github.com:$GITHUB_USERNAME/dotfiles.git" "$CHECKOUT_PATH"
fi

# Run install script
cd "$CHECKOUT_PATH"
for candidate in "${install_script_options[@]}"
do
    if [ ! -f "./$candidate" ]; then
        continue
    fi
    set +e
    "./$candidate"
    exit $?
done
