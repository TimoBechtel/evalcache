# Caches the output of a binary initialization command, to avoid the time to
# execute it in the future.
#
# Usage: _evalcache [NAME=VALUE]... COMMAND [ARG]...

# default cache directory
export ZSH_EVALCACHE_DIR=${ZSH_EVALCACHE_DIR:-"$HOME/.zsh-evalcache"}

# cleanup after x seconds
export ZSH_EVALCACHE_SECONDS=${ZSH_EVALCACHE_SECONDS:-"4320"} # every 3 days

function _evalcache () {
  local cmdHash="nohash" data="$*" name

  # use the first non-variable argument as the name
  for name in $@; do
    if [ "${name}" = "${name#[A-Za-z_][A-Za-z0-9_]*=}" ]; then
      break
    fi
  done

  # if command is a function, include its definition in data
  if typeset -f "${name}" > /dev/null; then
    data=${data}$(typeset -f "${name}")
  fi

  if builtin command -v md5 > /dev/null; then
    cmdHash=$(echo -n "${data}" | md5)
  elif builtin command -v md5sum > /dev/null; then
    cmdHash=$(echo -n "${data}" | md5sum | cut -d' ' -f1)
  fi

  local cacheFile="$ZSH_EVALCACHE_DIR/init-${name##*/}-${cmdHash}.sh"

  if [ "$ZSH_EVALCACHE_DISABLE" = "true" ]; then
    eval ${(q)@}
  elif [ -s "$cacheFile" ]; then

    # rebuild cache if it's older than ZSH_EVALCACHE_SECONDS
    local now=$(date +%s)
    local file_modification=$(date -r "$cacheFile" +%s)
    (( diff = (now - file_modification) / ZSH_EVALCACHE_SECONDS ))
    if [ $diff -gt 1 ]; then
      [ "$ZSH_EVALCACHE_SHOW_MESSAGES" = "true" ] && echo "evalcache: cache for $* expired, rebuilding it"
      eval ${(q)@} > "$cacheFile"
    fi

    source "$cacheFile"
  else
    if type "${name}" > /dev/null; then
      [ "$ZSH_EVALCACHE_SHOW_MESSAGES" = "true" ] && echo "evalcache: ${name} initialization not cached, caching output of: $*" >&2
      mkdir -p "$ZSH_EVALCACHE_DIR"
      eval ${(q)@} > "$cacheFile"
      source "$cacheFile"
    else
      echo "evalcache: ERROR: ${name} is not installed or in PATH" >&2
    fi
  fi
}

function _evalcache_clear () {
  rm -i "$ZSH_EVALCACHE_DIR"/init-*.sh
}
