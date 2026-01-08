# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# Plugin Name: less
# Repository: https://github.com/johnstonskj/zsh-less-plugin
#
# Description:
#
#   Zsh plugin to set up environment for the command less.
#
# Public variables:
#
# * `LESS`; plugin-defined global associative array with the following keys:
#   * `_ALIASES`; a list of all aliases defined by the plugin.
#   * `_FUNCTIONS`; a list of all functions defined by the plugin.
#   * `_PLUGIN_DIR`; the directory the plugin is sourced from.
# * `LESSHISTFILE`; the location of the command-specific history file.
#

############################################################################
# Standard Setup Behavior
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# See https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash
declare -gA LESS
LESS[_PLUGIN_DIR]="${0:h}"
LESS[_ALIASES]=""
LESS[_FUNCTIONS]=""

# Saving the current state for any modified global environment variables.
LESS[_OLD_HISTFILE]="${LESSHISTFILE:-}"

############################################################################
# Internal Support Functions
############################################################################

#
# This function will add to the `LESS[_FUNCTIONS]` list which is
# used at unload time to `unfunction` plugin-defined functions.
#
# See https://wiki.zshell.dev/community/zsh_plugin_standard#unload-function
# See https://wiki.zshell.dev/community/zsh_plugin_standard#the-proposed-function-name-prefixes
#
.less_remember_fn() {
    builtin emulate -L zsh

    local fn_name="${1}"
    if [[ -z "${LESS[_FUNCTIONS]}" ]]; then
        LESS[_FUNCTIONS]="${fn_name}"
    elif [[ ",${LESS[_FUNCTIONS]}," != *",${fn_name},"* ]]; then
        LESS[_FUNCTIONS]="${LESS[_FUNCTIONS]},${fn_name}"
    fi
}
.less_remember_fn .less_remember_fn

.less_define_alias() {
    local alias_name="${1}"
    local alias_value="${2}"

    alias ${alias_name}=${alias_value}

    if [[ -z "${LESS[_ALIASES]}" ]]; then
        LESS[_ALIASES]="${alias_name}"
    elif [[ ",${LESS[_ALIASES]}," != *",${alias_name},"* ]]; then
        LESS[_ALIASES]="${LESS[_ALIASES]},${alias_name}"
    fi
}
.less_remember_fn .less_remember_alias

#
# This function does the initialization of variables in the global variable
# `LESS`. It also adds to `path` and `fpath` as necessary.
#
less_plugin_init() {
    builtin emulate -L zsh
    builtin setopt extended_glob warn_create_global typeset_silent no_short_loops rc_quotes no_auto_pushd

    export LESSHISTFILE="${XDG_STATE_HOME}/less/history"
    if [[ ! -d "${LESSHISTFILE}" ]]; then
        mkdir -p "${LESSHISTFILE}"
    fi

    .less_define_alias more 'less'
}
.less_remember_fn less_plugin_init

############################################################################
# Plugin Unload Function
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#unload-function
less_plugin_unload() {
    builtin emulate -L zsh

    # Remove all remembered functions.
    local plugin_fns
    IFS=',' read -r -A plugin_fns <<< "${LESS[_FUNCTIONS]}"
    local fn
    for fn in ${plugin_fns[@]}; do
        whence -w "${fn}" &> /dev/null && unfunction "${fn}"
    done
    
    # Remove all remembered aliases.
    local aliases
    IFS=',' read -r -A aliases <<< "${LESS[_ALIASES]}"
    local alias
    for alias in ${aliases[@]}; do
        unalias "${alias}"
    done

    # Reset global environment variables .
    export LESSHISTFILE="${LESS[_OLD_HISTFILE]}"

    # Remove the global data variable.
    unset LESS

    # Remove this function.
    unfunction less_plugin_unload
}

############################################################################
# Initialize Plugin
############################################################################

less_plugin_init

true
