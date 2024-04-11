# skel.git

Skeleton (like a ```/etc/skel/``` directory). Mostly contains configuration files to make life in _Bash_, _Git_, and _Vim_ easier.

## Configuration Files

* [.bashrc](#bashrc) [[see file]](home/.bashrc)
* [.gitconfig](#gitconfig) [[see file]](home/.gitconfig)
* [.vimrc](#vimrc) [[see file]](home/.vimrc)

### .bashrc

#### Prompt (PS1)

_Bash_ ```PS1``` variable is modified to display the following state:

* _Git_ repository status, if any:
  * Current branch name (or rebase/cherry-pick commit message if currently on rebase/cherry-pick);
  * Ahead/behind of the origin branch status;
  * Status symbol of the first file listed in ```$ git status```;
  * Count of stash entries;
  * ```git.wip.tgz``` file availability _(see below)_;
* Availability of a saved _Vim_ session(s) in a current directory _(see below)_;
* Shell status:
  * Shell level (```$SHLVL```);
  * Running jobs (```$ man jobs```);
  * New mail (local), if any (```$ man mail```);
  * Exit code of the last shell command, if non-zero (```$?```).

![PS1 example](ps1.example.png "Git rebase example")

> **TODO** Add more descriptive example screenshots.

#### Git Functions

> **TODO** Provide all the descriptions.

```$ ps1.git.enable``` - Enable displaying of a _Git_ repository status (if current directory itself within a _Git_ repository) 
  in a shell prompt (```PS1```). Enabled by default.

```$ ps1.git.disable``` - Suspend displaying of a _Git_ repository status. Could be handy for a large repositories, 
  e.g. when ```$ git status``` evaluation tooks long time.

```$ git.fetch.all [-r]``` - _[WIP]_

```$ git.wip.pack [-u]``` - _TODO_

```$ git.info``` - Short for ```$ git st && git logi```.

```$ git.rmorig``` - Prompted remove of all the ```*.orig``` files within a repository.

```$ git.commit.stats``` - _[WIP]_

```$ git.autofixup [commit]``` - _[WIP]_

#### SVN Functions

```$ svn.vim``` - _TODO_

```$ svn.wip.pack``` - _TODO_

#### Vim Functions

```$ vim.session``` - _TODO_

#### Aliases

```$ colgrep``` - _grep_ with forced color output and ```-RnPH``` flags.

#### PATH

```PATH``` environment variable will be prefixed with ```/path/to/skel.git/bin/``` directory.

### .gitconfig

* Set _Vim_ as an editor, diff and merge tool;
* Set commit signing;
* Aliases.

> **WARNING** Please, set ```rerere``` disabled, if you are not experienced in solving of merge conflicts. That's because 
  the ```rerere``` option may lead to autoresolve remembered resolution of a conflict, that was previously resolved incorrectly. 
  ```$ man git-rerere``` for more info.

> **TODO** Provide more description for aliases.

### .vimrc

> **TODO** Finish.

## Vim Plugins

* [vim-glsl](https://github.com/tikhomirov/vim-glsl) _[submodule]_ Vim syntax highlighting for OpenGL Shading Language.
* [vim-ingo-library](https://github.com/inkarkat/vim-ingo-library) _[submodule]_ Dependency for _vim-mark_.
* [vim-mark](https://github.com/inkarkat/vim-mark) _[submodule]_ Word-highlight plugin by _Ingo Karkat_.

## bin/ Directory

> **TODO** Finish.

## Install

```bash
# install .bashrc
cd /path/to/skel.git/
echo -e "\nsource \"$PWD/home/.bashrc\"" >> "$HOME/.bashrc"
# check
tail -n 1 "$HOME/.bashrc"
#source "/path/to/skel.git/home/.bashrc"

# install .gitconfig
cd /path/to/skel.git/
echo -e "\n[include]\n\tpath = \"$PWD/home/.gitconfig\"" >> "$HOME/.gitconfig"
# check
tail -n 2 "$HOME/.gitconfig"
#[include]
#    path = "/path/to/skel.git/home/.gitconfig"

# install .vimrc
cd /path/to/skel.git/
echo -e "\n:source $PWD/home/.vimrc" >> "$HOME/.vimrc"
# check
tail -n 1 "$HOME/.vimrc"
#:source /path/to/skel.git/home/.vimrc
```

> **TODO** Vim plugins.

## License

All the sources are released under [MIT License](LICENSE).
