# rigor: enable all features at once.
#
#   source "$(brew --prefix)/share/rigor/rigor.zsh"
#
# Prefer sourcing the individual feature files if you only want some.

_rigor_dir="${${(%):-%x}:A:h}"
source "$_rigor_dir/autovenv.zsh"
source "$_rigor_dir/pyf.zsh"
source "$_rigor_dir/envup.zsh"
unset _rigor_dir
