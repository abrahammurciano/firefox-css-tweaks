#!/usr/bin/env bash

# Show usage information and exit with status 1
usage() {
	echo "Usage: $0 [install|uninstall|help] [options]"
	echo
	echo "Options:"
	echo "  install               Install tweaks."
	echo "  uninstall             Uninstall all tweaks."
	echo "  --all                 Install/uninstall all available tweaks on all available profiles."
	echo "  --all-tweaks          Install all the available tweaks instead of prompting for selection."
	echo "  --all-profiles        Install tweaks to all Firefox profiles instead of prompting for selection."
	echo "  -p, --profile <path>  Specify the path to the Firefox profile to install the tweaks to."
	echo "  help, -h, --help      Display this help message."
	exit 1
}

# Prints a message to stderr
print() {
	echo "$1" >&2
}

# Prints an error message to stderr and exits with status 1
error() {
	print "Error: $1"
	exit 1
}

show-choices() {
	local options=("$@")
	echo "----------------------------------"
	for i in "${!options[@]}"; do
		echo "$((i + 1)). ${options[i]}"
	done
	echo "----------------------------------"
}

# Prompts the user to select multiple options from a list of options
# $1: The prompt message
# $...: The options to choose from
# Writes the selected options to stdout
choices() {
	print "${1:-Please select one or more options (space separated):}"
	shift
	local options=("$@")
	show-choices "${options[@]}" > /dev/stderr

	local selected=()
	while true; do
		read -r -p "Enter your choices (1-${#options[@]}) (separated by spaces; press enter for all): " indices < /dev/tty
		if [ -z "$indices" ]; then
			printf "%s\n" "${options[@]}"
			return
		fi
		for index in $indices; do
			if ! [[ "$index" =~ ^[0-9]+$ ]] || ((index < 1 || index > ${#options[@]})); then
				print "Invalid choice. Please enter only numbers between 1 and ${#options[@]}."
				selected=()
				break
			fi
			selected+=("${options[index - 1]}")
		done
		if [ ${#selected[@]} -gt 0 ]; then
			printf "%s\n" "${selected[@]}"
			break
		fi
	done
}

# Parse command line arguments
parse-args() {
	ACTION="$1"
	ALL_TWEAKS=false
	ALL_PROFILES=false
	PROFILE=""
	shift

	if [ "$ACTION" != "install" ] && [ "$ACTION" != "uninstall" ]; then
		usage
	fi

	while [ "$#" -gt 0 ]; do
		case "$1" in
			--all)
				ALL_TWEAKS=true
				ALL_PROFILES=true
				;;
			--all-tweaks)
				ALL_TWEAKS=true
				;;
			--all-profiles)
				ALL_PROFILES=true
				;;
			-p|--profile)
				PROFILE="$2"
				shift
				;;
			-h|--help)
				usage
				;;
			*)
				echo "Unknown option: $1"
				usage
				;;
		esac
		shift
	done
}

# Find all Firefox profiles
all-profiles() {
	find ~/.mozilla/firefox -maxdepth 1 -type d -name "*.default*"
}

# Get the correct Firefox profile
get-profiles() {
	local available=($(all-profiles))
	if [ ${#available[@]} -eq 0 ]; then
		error "No Firefox profiles found. You can specify the path to your profile manually with --profile."
	fi

	if [ "$ALL_PROFILES" = true ]; then
		printf "%s\n" "${available[@]}"
		return
	fi

	if [ -n "$PROFILE" ]; then
		if [ -d "$PROFILE" ]; then
			echo "$PROFILE"
			return
		fi
		error "The specified profile does not exist: $PROFILE"
	fi

	if [ ${#available[@]} -eq 1 ]; then
		echo "${available[0]}"
		return
	fi

	echo $(choices "Select Firefox profile(s):" "${available[@]}")
}


# Clone the repository to a temporary directory
clone-repo() {
	git clone https://github.com/abrahammurciano/firefox-css-tweaks.git "$1"
}

# Enable a tweak in userChrome.css
enable-tweak() {
	local user_chrome="$1"
	local tweak="$2"
	local css_import='@import "./tweaks/'"$tweak"'/index.css";'
	local css_comment="/\* $css_import \*/"
	touch "$user_chrome"
	sed -i "s|$css_comment||g" "$user_chrome"
	if ! grep -q "$css_import" "$user_chrome"; then
		{ tail -c1 "$user_chrome" | grep --quiet '^$' || echo; } >> "$user_chrome"
		echo "$css_import" >> "$user_chrome"
		echo "Enabled tweak: $tweak"
	else
		echo "Tweak already enabled: $tweak"
	fi
}

get-tweaks() {
	local tweaks_dir="$1"
	local available=($(find "$tweaks_dir" -maxdepth 1 -mindepth 1 -type d -printf "%f\n"))
	if [ "$ALL_TWEAKS" = true ]; then
		printf "%s\n" "${available[@]}"
	else
		choices "Select tweaks:" "${available[@]}"
	fi
}

copy-tweak() {
	local tweak="$1"
	local profile="$2"
	local repo="$3"

	tmp=$(mktemp -d)
	trap "rm -rf $tmp" EXIT
	mv "$profile/chrome/tweaks/$tweak/custom-options.css" "$tmp" || true
	cp -rv "$repo/tweaks/$tweak" "$profile/chrome/tweaks"
	mv "$tmp/custom-options.css" "$profile/chrome/tweaks/$tweak" || true
}

# Install the tweaks
install() {
	local repo="$1"
	local profile="$2"

	print "Installing tweaks to $profile"

	mkdir -p "$profile/chrome/tweaks"
	get-tweaks "$repo/tweaks" | while read -r tweak; do
		copy-tweak "$tweak" "$profile" "$repo"
		enable-tweak "$profile/chrome/userChrome.css" "$tweak"
	done
	print "Tweaks installed successfully."
}

# Uninstall all tweaks
uninstall() {
	local profile="$1"

	print "Uninstalling tweaks from $profile"

	rm -rf "$profile/chrome/tweaks"
	sed -i '/@import "\.\/tweaks\//d' "$profile/chrome/userChrome.css"
	print "Tweaks uninstalled successfully."
}


main() {
	parse-args "$@"

	local repo=$(mktemp -d)
	trap "rm -rf $repo" EXIT
	clone-repo "$repo" > /dev/stderr
	local profiles=$(get-profiles)
	for profile in $profiles; do
		if [ "$ACTION" = "install" ]; then
			install "$repo" "$profile"
		elif [ "$ACTION" = "uninstall" ]; then
			uninstall "$profile"
		fi
	done
}

main "$@"