# PS1
## Structure
The ps1 is structured in 6 parts:
- current username
- current computer
- location (path to working directory)
- git info
- invite
- date

For example in:
```
elrendio@scylla:~/Stockly/Main(47 FIX-RemoveRequiredPhoneNumber !?Δ⇢ ✯)
±                                                                                           20:49:52
```

 - `elrendio`: is the username
 - `scylla`: the computer
 - `~/Stockly/Main`: the current directory
 - `47 FIX-RemoveRequiredPhoneNumber !?Δ⇢ ✯`: Indicates information about the current git repository
 - `±`: is the invite (where you type commands)
 - `20:49:52`: is the date at which was prompted the commande (not the current date)

## Current directory
The Stockly theme tries to print a maximum information without overloading your terminal. Therefore when it considers the path to be too long it might shorten it.
When in a git directory instead of `~/super/mega/ultra/long/path/to/git/repo/with/sub/path` to `with/sub/path`. And when sub path in directory is too long `repo/.../current_dir`.

## Git information
### Structure
The git information part is splitted in 4 parts:
- Number of commits behind `origin/master`
- Number of commits ahead `origin/master`
- Location (Name of branch or commit)
- Information about working tree

For example in `47 FIX-RemoveRequiredPhoneNumber !?Δ⇢ ✯`:
- `4`: is the number behind `origin/master`
- ``: Indicates the position towards the remote branch:
  - Purple means late
  - Green means is sync
  - Yellow means ahead
- `7`: is the number behind `origin/master`
- `FIX-RemoveRequiredPhoneNumber`: Name of the current branch
- `!?+Δ⇢ ✯`: Concise information about the working tree:
  - `!`: Means a file was deleted
  - `?`: Means there's un untracked file
  - `+`: Means a file was added
  - `Δ`: Means a file was modified
  - `⇢`: Means a file was renamed
  - `✯`: Means the stash list is not empty
 => Blue means unstaged and yellow means staged 

# Setup
*Note*: On Stockly shared monsters, this theme has already been setup and you can move to last step.

## Install custom font
This theme is best use with font `fira-code` (which you can install on ArchLinux which `yay ttf-fira-code`) and must have font `powerline-symbols` (on ArchLinux `yay powerline-fonts`) installed to print the special characters (notably ).

## Upgrade ZSH
In order to get access to all the git information required you must update `zsh`. For this replace the file `$ZSH/lib/git.zsh` by `Main/dev_tools/ZshTheme/git.zsh` (`cp ~/Stockly/Main/dev_tools/ZshTheme/git.zsh $ZSH/lib/git.zsh`).

## Register the theme
For zsh to be able to access you need to copy `stockly.zsh-theme` to `$ZSH/themes/` (`cp ~/Stockly/Main/dev_tools/ZshTheme/stockly.zsh-theme $ZSH/themes/stockly.zsh-theme`)

## Update your `.zshrc`
Finally you need to select the theme in your `.zshrc`, set the variable `ZSH_THEME` to `stockly`
