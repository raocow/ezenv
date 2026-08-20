# rigorish: enable all features at once.
#
#   source "$(brew --prefix)/share/rigorish/rigorish.zsh"
#
# Prefer sourcing the individual feature files if you only want some.

_rigorish_dir="${${(%):-%x}:A:h}"
source "$_rigorish_dir/autovenv.zsh"
source "$_rigorish_dir/pyf.zsh"
source "$_rigorish_dir/envup.zsh"
unset _rigorish_dir
