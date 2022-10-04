

_esamatti_dotfiles_init() {
    local dir=$1
    export PATH="$dir/bin:$PATH"

}

_esamatti_dotfiles_init "${0:A:h}"