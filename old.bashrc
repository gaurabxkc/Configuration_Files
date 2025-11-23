# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar



# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# =========================================================================
# The following section is for the default prompt.
# I have commented this out to prevent it from conflicting with your custom prompt.
# =========================================================================

# set a fancy prompt (non-color, unless we know we "want" color)
# case "$TERM" in
#       xterm-color|*-256color) color_prompt=yes;;
# esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

# if [ -n "$force_color_prompt" ]; then
#       if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
#       # We have color support; assume it's compliant with Ecma-48
#       # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
#       # a case would tend to support setf rather than setaf.)
#       color_prompt=yes
#       else
#       color_prompt=
#       fi
# fi

# if [ "$color_prompt" = yes ]; then
#       PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
# else
#       PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# fi
# unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
# case "$TERM" in
# xterm*|rxvt*)

#       PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#       ;;
# *)
#       ;;
# esac

# =========================================================================
# End of default prompt section.
# =========================================================================


# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.   Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Custom additions
export EDITOR=nano
export PATH="$HOME/.local/bin:$PATH"

# Custom aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cls='clear'
alias h='history'
alias tree='tree -C'

# # =========================================================================
# # --- Custom Prompt Additions ---
# # This function will be executed before each prompt is displayed.
update_prompt() {
    # Capture the exit code of the last command executed.
    # This must be the first line of the function.
    local exit_code=$?

    # 1. Define ANSI color codes for the prompt.
    # These are the escape sequences for colors in the terminal.
    local GREEN='\033[38;2;148;255;228m'
    local MAGENTA='\[\e[35m\]'
    local WHITE='\[\e[97m\]'
    # Using 'bright black' as a good approximation for 'light grey'
    local LGREY='\[\e[38;5;252m\]'
    local RESET='\[\e[0m\]' # Resets all text formatting.

    # 2. Build the "context" part of the prompt (◉ hostname)
    # This replicates your `POWERLEVEL9K_CONTEXT_DEFAULT_CONTENT_EXPANSION='◉ %m'`
    # In Bash, `\h` is the hostname.
    local context="${LGREY}◉ \h${RESET}"

    # --- ADDITION FOR VIRTUAL ENVIRONMENTS ---
    # Check if a virtual environment is active.
    if [[ -n "$VIRTUAL_ENV" ]]; then
        # Extract the name of the venv (the last part of the path)
        local venv_name=$(basename "$VIRTUAL_ENV")
        # Add the venv name to the context part of the prompt
        context="${LGREY}◉ \h${RESET}${LGREY} [${venv_name}]${RESET}"
    fi
    # ----------------------------------------

    # 3. Build the current directory part of the prompt.
    # We will format this to show '.../current' as requested.
    local current_dir
    local full_path=$(pwd)
    local home_dir="$HOME"

    if [[ "$full_path" == "$home_dir" ]]; then
      #   If we are in the home directory, just show a tilde.
      # current_name=$(basename "$full_path")
      current_dir="../gaurab"
    elif [[ "$full_path" == "/" ]]; then
        # If we are in the root directory, just show a slash.
        current_dir="/"
    else
        # For all other paths, get only the last directory name.
        local current_name=$(basename "$full_path")
        current_dir="../$current_name"
    fi

    local formatted_dir="${WHITE}${current_dir}${RESET}"

    # 4. Determine the prompt symbol and color based on the exit code.
    # This replicates your PROMPT_CHAR settings.
    local prompt_symbol
    if [ $exit_code -eq 0 ]; then
        # Last command succeeded (exit code 0)
        prompt_symbol="${GREEN}❯${RESET}"
    else
        # Last command failed (non-zero exit code)
        prompt_symbol="${MAGENTA}❯${RESET}"
    fi

    # 5. Assemble the final PS1 string.
    # We add a newline `\n` at the beginning to replicate `POWERLEVEL9K_PROMPT_ADD_NEWLINE=true`.
    PS1="\n${context} ${formatted_dir} ${prompt_symbol} "
}

# The PROMPT_COMMAND variable holds a command to be executed just before
# Bash displays the prompt (PS1). We set it to our function name.
PROMPT_COMMAND=update_prompt
# =========================================================================
# End of custom prompt additions.
# =========================================================================
# Append history instead of overwriting
shopt -s histappend

# Save and reload history after every command
PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"
export PATH="/c/msys64/usr/bin:$PATH"


# eval "$(starship init bash)"