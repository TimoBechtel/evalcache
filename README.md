# evalcache

> zsh plugin to cache the output of a binary initialization command, intended
> to help lower shell startup time.

> [!NOTE]
> This is a fork of https://github.com/mroth/evalcache that automatically re-validates the cache after a specified amount of time.

## What it does

There are lots of shell wrapper tools that follow the pattern of asking you to
eval a specific init command in your shell startup, for example, rbenv asks:

    eval "$(hub alias -s)"

While this is very convenient, the reality is there is a small amount of
overhead associated with shelling out to this, and the output is almost always
actually static in all of the tools I know. So why bear this cost every time
you open a new tab in your shell?

Instead, after you load this plugin, you can replace that same command with:

    _evalcache hub alias -s

The first time this runs, it will cache the output of the command to a file,
which will be sourced in the future instead when it exists.

If you update a tool and expect for some reason that it's initialization might
have changed, you can simply clear the cache and it will be regenerated.

It also gracefully degrades to a no-op if the tool is no longer installed.

## Benchmarks

Some informal benchmarks from my MacBook on my .zshrc:

| command      | without | first run | subsequent runs | savings |
| ------------ | ------: | --------: | --------------: | ------: |
| rbenv init   |   ~65ms |     ~65ms |            ~8ms |     88% |
| hub alias    |   ~30ms |     ~30ms |            ~6ms |     80% |
| scmpuff init |   ~24ms |     ~25ms |           ~10ms |     58% |

The difference isn't huge, but can be handy in shaving down shell startup time,
especially if you use a bunch of these tools. Every millisecond counts!

## Options

- `$ZSH_EVALCACHE_DIR`: cache files storage, default `$HOME/.zsh-evalcache`.
- `$ZSH_EVALCACHE_DISABLE`: set to `true` if you wish to bypass evalcache.
- `$ZSH_EVALCACHE_SECONDS`: how long until to re-evaluate the command in seconds, default `4320` (3 days)
- `$ZSH_EVALCACHE_SHOW_MESSAGES`: set to `true` if you want to display console output

There is a convenience function to clear the cache called `_evalcache_clear`.

## Installation

### [Antigen](https://github.com/zsh-users/antigen)

Add `antigen bundle TimoBechtel/evalcache` to your `.zshrc` with your other bundle commands.

Antigen will handle cloning the plugin for you automatically the next time you start zsh. You can also add the plugin to a running zsh with `antigen bundle TimoBechtel/evalcache` for testing before adding it to your `.zshrc`.

### [Fig](https://fig.io)

Fig adds apps, shortcuts, and autocomplete to your existing terminal.

Install `evalcache` in just one click.

<a href="https://fig.io/plugins/other/evalcache_mroth" target="_blank"><img src="https://fig.io/badges/install-with-fig.svg" /></a>

### [Oh-My-Zsh](http://ohmyz.sh/)

1. Clone this repository into `$ZSH_CUSTOM/plugins` (by default `~/.oh-my-zsh/custom/plugins`)

   ```sh
   git clone https://github.com/TimoBechtel/evalcache ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/evalcache
   ```

2. Edit `~/.zshrc` to add _evalcache_ to your plugin list,
   ```diff
   - plugins=(...)
   + plugins=(... evalcache)
   ```

### [Zgen](https://github.com/tarjoilija/zgen)

Add `zgen load TimoBechtel/evalcache` to your `.zshrc` file in the same function you're doing your other `zgen load` calls in. Zgen will handle automatically cloning the plugin for you the next time you do a `zgen save`.
