# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name: less
# @brief: Set the environment for the command `less`.
# @repository: https://github.com/johnstonskj/zsh-less-plugin
# @version: 0.1.1
# @license: MIT AND Apache-2.0
#
# Public variables:
#
# * `LESSHISTFILE`; the location of the command-specific history file.
# * `PAGER`; the pager command to use.
#

############################################################################
# @section Lifecycle
# @description Plugin lifecycle functions.
#

less_plugin_init() {
    builtin emulate -L zsh

    @zplugins_envvar_save less LESSHISTFILE
    typeset -g LESSHISTFILE="${XDG_STATE_HOME}/less/history"
    if [[ ! -d "${LESSHISTFILE}" ]]; then
        mkdir -p "${LESSHISTFILE}"
    fi

    @zplugins_envvar_save less PAGER
    typeset -g PAGER=less

    @zplugins_define_alias less more 'less'
}

less_plugin_unload() {
    builtin emulate -L zsh

    @zplugins_envvar_restore less LESSHISTFILE
    @zplugins_envvar_restore less PAGER
}
