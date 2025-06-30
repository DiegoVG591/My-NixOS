# /home/krieg/mysystem/zsh/themes/cool-cats.zsh-theme

# Ensure Zsh's color and prompt systems are ready
autoload -Uz colors && colors
setopt PROMPT_SUBST

# --- Work In Progress Function (Keep this!) ---
function work_in_progress() {
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
if git log -n 1 --format=%s 2>/dev/null | grep -q -i -e "/-/-wip/-/-" -e "WIP"; then
  echo "%F{red}[WIP!!]%f " # Output with Zsh colors and a space
fi
fi
}

# --- Prompt Elements ---
local ret_status="%(?:%F{#4cf20e}/ᐠ –ꞈ –ᐟ\ﾉ:%F{#e81d1d}/ᐠ｡▿｡ᐟ\ˎˊ˗ )"
local current_dir_prompt="%F{#12e19d}%c%f"

# --- Conditionally Define the Git Part ---
# This means: If $currentGitBranch is not empty, substitute with "git:(#a6e3a1)$currentGitBranch%f) ".

# --- Define the '✗' Part ---
# We always show the yellow ✗
local yellow_cross="%F{#f5c834}✗"

# --- Define the Prompt Symbol Part ---
# We use pink for the prompt symbol
local prompt_symbol="%F{#ffc4ea} "

# --- Build the FINAL PROMPT ---
# Structure: status dir git_info wip_info yellow_cross prompt_symbol
PROMPT="${ret_status} ${current_dir_prompt} \${currentGitBranch}$(work_in_progress)${yellow_cross} ${prompt_symbol}"
