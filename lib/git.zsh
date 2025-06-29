# ~/lib/git.zsh (Make sure this is the content!)

autoload -Uz vcs_info add-zsh-hook
setopt PROMPT_SUBST

# --- Configure vcs_info ---
# Set the format to ONLY be the branch name.
zstyle ':vcs_info:*' formats       "%b"
zstyle ':vcs_info:*' actionformats "%b"
zstyle ':vcs_info:*' enable git

# --- Global Variables ---
update_git_info() {
    # Check if we are inside a git repo *first*
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        # If yes, run vcs_info and set the branch name
        vcs_info
        currentGitBranch="%F{#6707a6}git:(%{%F{#ffc4ea}%}${vcs_info_msg_0_}%{%F{#6707a6}%}) %f"
    else
        # If no, ensure the branch name is EMPTY
        currentGitBranch=""
    fi
    # You can add echo "DEBUG: Branch is '$currentGitBranch'" here to test
}

add-zsh-hook precmd update_git_info
