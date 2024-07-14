#!/bin/bash


RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'  # No Color


add_to_zsh_path() {
    local bin_path=$1
    local zshrc_file="$HOME/.zshrc"


    if echo "$PATH" | grep -q "$bin_path"; then
        echo -e "${GREEN}Path $bin_path is already in PATH.${NC}"
        return 0
    fi


    echo "export PATH=\$PATH:$bin_path" >> "$zshrc_file"
    echo -e "${GREEN}Path $bin_path successfully added to PATH in Zsh.${NC}"


    source "$zshrc_file"
}


add_to_bash_path() {
    local bin_path=$1
    local bashrc_file="$HOME/.bashrc"


    if echo "$PATH" | grep -q "$bin_path"; then
        echo -e "${GREEN}Path $bin_path is already in PATH.${NC}"
        return 0
    fi


    echo "export PATH=\$PATH:$bin_path" >> "$bashrc_file"
    echo -e "${GREEN}Path $bin_path successfully added to PATH in Bash.${NC}"


    source "$bashrc_file"
}


add_to_windows_path() {
    local bin_path=$1


    if echo "$PATH" | grep -q "$bin_path"; then
        echo -e "${GREEN}Path $bin_path is already in PATH.${NC}"
        return 0
    fi


    echo "Adding $bin_path to PATH in Windows"
    setx PATH "%PATH%;$bin_path" /M
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Path $bin_path successfully added to PATH in Windows.${NC}"
    else
        echo -e "${RED}Failed to add $bin_path to PATH in Windows.${NC}"
    fi
}




case "$(uname -s)" in
    Linux*|Darwin*)
        echo -e "Operating System: ${GREEN}$(uname -s)${NC}"
        ;;
    CYGWIN*|MINGW32*|MSYS*|MINGW*)
        echo -e "Operating System: ${GREEN}Windows${NC}"
        ;;
    *)
        echo -e "${RED}Error: Unsupported OS: $(uname -s)${NC}"
        exit 1
        ;;
esac


if [ "$(uname -s)" != "Windows" ] && [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: Please run this script as root.${NC}"
    exit 1
fi


while getopts "p:" opt; do
    case $opt in
        p)
            bin_path=$OPTARG
            ;;
        \?)
            echo -e "${RED}Invalid option: -$OPTARG${NC}" >&2
            exit 1
            ;;
    esac
done


if [ -z "$bin_path" ]; then
    echo -e "${RED}Error: -p {path} argument required.${NC}"
    exit 1
fi


if [ "$(uname -s)" != "Windows" ]; then
    add_to_zsh_path "$bin_path"
fi


if [ "$(uname -s)" != "Windows" ]; then
    add_to_bash_path "$bin_path"
fi


if [ "$(uname -s)" == "Windows" ]; then
    add_to_windows_path "$bin_path"
fi
