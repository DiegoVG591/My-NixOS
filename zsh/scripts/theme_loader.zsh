# /home/krieg/mysystem/zsh/theme_loader.zsh

# Define the base directory for themes
ZSH_CUSTOM_THEMES_DIR="$HOME/mysystem/zsh/themes"
ZSH_LIB_DIR="$HOME/mysystem/lib" # Define a directory for your utility scripts

# --- Source Utility Scripts (like git.zsh) ---
if [[ -d "$ZSH_LIB_DIR" ]]; then
  if [[ -f "$ZSH_LIB_DIR/git.zsh" ]]; then
    source "$ZSH_LIB_DIR/git.zsh"
    # echo "theme_loader.zsh: Loaded $ZSH_LIB_DIR/git.zsh" # Optional confirmation
  fi
fi
# -----------------------------------------

# Function to load a Zsh theme
Themes() {
  local theme_name="$1"
  local theme_file="$ZSH_CUSTOM_THEMES_DIR/${theme_name}.zsh-theme"

  if [[ -z "$theme_name" ]]; then
    echo "Themes: Please provide a theme name." >&2
    return 1
  fi

  if [[ -f "$theme_file" ]]; then
    setopt PROMPT_SUBST

    # Source the theme file
    source "$theme_file"
    # echo "Themes: Loaded theme '$theme_name'."
    return 0
  else
    echo "Themes: Theme '$theme_name' not found at '$theme_file'." >&2
    return 1
  fi
}
