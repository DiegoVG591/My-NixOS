# Reimplements OMZ's work_in_progress to customize the echo
function work_in_progress() {
  if $(git log -n 1 2>/dev/null | grep -q -c '"/-/-wip/-/-"'); then
    echo "[WIP!!] "
  fi
}

local ret_status="%(?:%F{#4cf20e}/ᐠ –ꞈ –ᐟ\ﾉ:%F{#e81d1d}/ᐠ｡▿｡ᐟ\ˎˊ˗ )"
local git_branch='$(git_prompt_info)%{$reset_color%}'
local git_wip='%{$fg[red]%}$(work_in_progress)%{$reset_color%}'

PROMPT="${ret_status} %{%F{#12e19d}%}%c%{%f%} ${git_branch}${git_wip} %{%F{#6707a6}%}"

ZSH_THEME_GIT_PROMPT_PREFIX="%{%F{#6707a6}%}git:(%{%F{#ffc4ea}%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{%F{#6707a6}%}) %{%F{#f5c834}%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{%F{#6707a6}%})"
