# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name less
# @brief Zsh plugin to set up environment for the command less.
# @repository https://github.com/johnstonskj/zsh-less-plugin
#

############################################################################
# @section Lifecycle
# @description Plugin lifecycle functions.
#

less_plugin_init() {
    builtin emulate -L zsh

    @zplugins_envvar_save less LESSHISTFILE
    export LESSHISTFILE="${XDG_STATE_HOME}/less/history"
    if [[ ! -d "${LESSHISTFILE}" ]]; then
        mkdir -p "${LESSHISTFILE}"
    fi

    @zplugins_envvar_save less PAGER
    export PAGER=less

    @zplugins_define_alias less more 'less'
}

less_plugin_unload() {
    builtin emulate -L zsh

    @zplugins_envvar_restore less LESSHISTFILE
    @zplugins_envvar_restore less PAGER
}
