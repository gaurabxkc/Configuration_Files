# ~/.bashrc: executed by bash(1) for non-login shells.

# --- 1. BASIC CHECKS ---
[[ $- != *i* ]] && return

# --- 2. HISTORY & WINDOW SETTINGS ---
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize

# --- 3. PATHS & EXPORTS ---
export EDITOR=nano
export PATH="$HOME/.local/bin:$PATH"
export PATH="/c/msys64/usr/bin:$PATH"

# --- 4. ALIASES ---
# Smart 'ls' alias
if command -v lsd &> /dev/null; then
    alias ls='lsd'
    alias ll='lsd -l'
    alias la='lsd -a'
    alias tree='lsd --tree'
else
    alias ls='ls --color=auto'
    alias ll='ls -alF'
    alias la='ls -A'
fi

alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias cls='clear'
alias h='history'
# --- HISTORY SEARCH ---
# Bind Up Arrow to search backward based on what you already typed
bind '"\e[A": history-search-backward'
# Bind Down Arrow to search forward based on what you already typed
bind '"\e[B": history-search-forward'

# --- 5. THE POWERFUL PROMPT ---
update_prompt() {
    local exit_code=$?

    # --- A. Colors ---
    local MINT='\[\033[38;2;148;255;228m\]'
    local RED='\[\e[35m\]'
    local YELLOW='\[\e[33m\]'
    local BLUE='\[\e[34m\]'
    local GREEN='\[\e[32m\]'
    local LGREY='\[\e[38;5;252m\]'
    local RESET='\[\e[0m\]'


    # --- B. Context (Hostname) ---
    local context="${LGREY}◉ \h${RESET}"

    # --- C. Directory Logic (Your Custom Style) ---
    local full_path="$PWD"
    local current_dir
    
    if [[ -n "$VIRTUAL_ENV" ]]; then
        # Extract the name of the venv (the last part of the path)
    local venv_name=$(basename "$VIRTUAL_ENV")
        # Add the venv name to the context part of the prompt
    context="${LGREY}◉ \h${RESET}${LGREY} [${venv_name}]${RESET}"
    fi

    
    if [[ "$full_path" == "$HOME" ]]; then
        current_dir="../gaurab"
    elif [[ "$full_path" == "/" ]]; then
        current_dir="/"
    else
        current_dir="../${full_path##*/}"
    fi
    local formatted_dir="${WHITE}${current_dir}${RESET}"
# --- Git (Icon Only) ---
    local git_info=""
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        # Check if dirty
        if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
            # Yellow Icon (Dirty)
            git_info=" ${YELLOW}${RESET}"
        else
            # Green Icon (Clean)
            git_info=" ${GREEN}${RESET}"
        fi
    fi

   # --- Language (Icon Only) ---
    local lang_info=""
    
    # 1. Web Development (Node, JS, TS, HTML, CSS)
    # Checks for package.json, or any .js/.ts/.html/.css files
    if [[ -f "package.json" ]] || compgen -G "*.js" > /dev/null || compgen -G "*.ts" > /dev/null || compgen -G "*.html" > /dev/null; then
        lang_info="${lang_info} ${GREEN}⬢${RESET}"
    fi
    
    # 2. Python
    # Checks for .py files or requirements.txt
    if compgen -G "*.py" > /dev/null || [[ -f "requirements.txt" ]]; then
        lang_info="${lang_info} ${GREEN}${RESET}"
    fi

    # 3. C Language
    # Checks for .c, .h files or a Makefile
    if compgen -G "*.c" > /dev/null || compgen -G "*.h" > /dev/null || [[ -f "Makefile" ]]; then
         lang_info="${lang_info} ${BLUE}C${RESET}"
    fi



    # --- F. The Arrow (Error Detection) ---
    local prompt_symbol
    if [ $exit_code -eq 0 ]; then
        prompt_symbol="${MINT}❯${RESET}"
    else
        prompt_symbol="${RED}❯${RESET}" # Changed to RED for better visibility on error
    fi

    # --- G. Assemble ---
    # Layout: Context -> Dir -> Git -> Lang -> Arrow
    PS1="\n${context} ${formatted_dir}${git_info}${lang_info} ${prompt_symbol} "
}

# --- 6. EXECUTION ---
# Run prompt update BEFORE history commands to capture exit code correctly
PROMPT_COMMAND="update_prompt; history -a; history -n"



cd() {
    builtin cd "$@" || return

    # List of common venv names
    local venv_names=("venv" ".venv" "env" ".env" "myenv")

    # Flag to check if we activated something
    local activated=false

    for name in "${venv_names[@]}"; do
        if [ -d "$name" ]; then
            # Check for Windows-style (Scripts)
            if [ -f "$name/Scripts/activate" ]; then
                source "$name/Scripts/activate"
                activated=true
                break
            # Check for Unix-style (bin) - just in case
            elif [ -f "$name/bin/activate" ]; then
                source "$name/bin/activate"
                activated=true
                break
            fi
        fi
    done

    # If we didn't find a venv, but one is currently active, deactivate it
    if [ "$activated" = false ] && [ -n "$VIRTUAL_ENV" ]; then
        deactivate
    fi
}