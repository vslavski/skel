# File: home/.bashrc
#
# This file is a part of skel project which is distributed under MIT License.
# See file LICENSE for full license details.
#
# Copyright (c) 2020-present Nikita Zuev (V.Slavski!) <nikita.zuev@gmx.com>

##########################################################################################
### INSTALL
##########################################################################################

# NOTE Add the following line in your '$HOME/.bashrc' file to include this one:
# source "/path/to/skel.git/home/.bashrc"

##########################################################################################
### 1. FORCE COLOR PROMPT
# @warning	Need to be updated in ~/.bashrc
##########################################################################################

#force_color_prompt=yes

##########################################################################################
### 2. COLOR PROMPT WITH GIT, VIM, SHELL STATUS FOR LEVEL, JOBS, NEW MAIL
###    AND LAST EXIT CODE
###    '$PS1_MACHINE_ID' PREFIXED IF DEFINED
##########################################################################################

PS1='`
export PS1_SHELL_EXIT_CODE=$?
ps1.machine_id
exit $PS1_SHELL_EXIT_CODE
`\[\e[01;34m\]\w\[\e[m\]`
export PS1_SHELL_EXIT_CODE=$?
ps1.git.status
ps1.vim.session
ps1.shell.status
exit $PS1_SHELL_EXIT_CODE
`\$ '

function ps1.machine_id() {
	[ -n "$PS1_MACHINE_ID" ] && echo -ne "$PS1_MACHINE_ID|"
}

function ps1.git.enable() {
	PS1_GIT_DISABLE=false
}
function ps1.git.disable() {
	PS1_GIT_DISABLE=true
}
export PS1_GIT_DISABLE=false

function ps1.git.enable.status() {
	PS1_GIT_ENABLE_STATUS=true
}
function ps1.git.disable.status() {
	PS1_GIT_ENABLE_STATUS=false
}
export PS1_GIT_ENABLE_STATUS=true

function ps1.git.status() {
	gitDir=` realpath "$(pwd)" `
	while [ ! -e "$gitDir/.git" ] ; do
		parentGitDir=` dirname "$gitDir" `
		[ "$parentGitDir" = "$gitDir" ]	\
			&& return 0
		gitDir="$parentGitDir"
	done
	$PS1_GIT_DISABLE												\
		&& echo -en "\x01\e[7;31m\x02\$ ps1.git.enable\x01\e[m\x02"	\
		&& return 0
	unicodeArrowUp=` echo -e "\u2191" `
	unicodeArrowDown=` echo -e "\u2193" `
	unicodeArrowRight=` echo -e "\u2192" `
	unicodeIdenticalTo=` echo -e "\u2261" `
	gitBranchFull=`	git -c color.branch=never branch --no-color --verbose 2>/dev/null	\
				|	grep '^\* '															\
				|	sed 's/^\*\s\+//'													`
	gitBranch=
	gitRebaseCommit=''
	gitNoBranchRebasing='(no branch, rebasing '
	[ "${gitBranchFull::${#gitNoBranchRebasing}}" = "$gitNoBranchRebasing" ]	\
		&& gitRebaseCommit="$unicodeArrowDown$(git log -1 --pretty='%s')"
	[ -d "$gitDir/.git/rebase-merge" -o -d "$gitDir/.git/rebase-apply" ]										\
		&& [ -f "$gitDir/.git/REBASE_HEAD" ]																	\
		&& gitRebaseCommit="$unicodeArrowRight$(git log -1 --pretty='%s' ` cat "$gitDir/.git/REBASE_HEAD" ` )"
	[ -n "$gitRebaseCommit" ]					\
		&& gitBranch='\e[01;33mREBASE\e[m'
	gitCherryCommit=
	[ -f "$gitDir/.git/CHERRY_PICK_HEAD" ]																			\
		&& gitBranch='\e[01;33mCHERRY\e[m'																			\
		&& gitCherryCommit="$unicodeArrowRight$(git log -1 --pretty='%s' ` cat "$gitDir/.git/CHERRY_PICK_HEAD" ` ) "
	gitDetachedCommit=`	echo "$gitBranchFull"			\
					|	grep '^(HEAD detached at '		\
					|	sed 's/^(HEAD detached at //
						;	s/^\([^)]\+\).*$/\1/ '		`
	[ -n "$gitDetachedCommit" ]													\
		&& gitBranch='\e[01;31mDETACH\e[m'										\
		&& gitDetachedCommit=" $(git log -1 --pretty='%s' $gitDetachedCommit) "
	[ -z "$gitBranch" ]													\
		&& gitBranch='\e[00;32m'` echo -e "$gitBranchFull"				\
			|	sed 's/^\(\S\+\)\s*.*$/\1/'						`'\e[m'
	gitAhead=`	echo -e "$gitBranchFull"													\
			|	sed 's/^\S\+\s\+\w\+\s\+//'													\
			|	grep -P '^\[(ahead|behind)'													\
			|	sed -r 's/^\[([^]]+)\].*$/\1/
				; s/ahead\s+([0-9]+)(|,\s+)/\x1B[01;32m'$unicodeArrowUp'\1\x1B[m/
				; s/behind\s+([0-9]+)/\x1B[01;31m'$unicodeArrowDown'\1\x1B[m/'				`
	gitBranchDescription=
	git config branch.$(git branch --show-current).description 1>/dev/null 2>&1		\
		&& gitBranchDescription='\e[47;30m'$unicodeIdenticalTo'\e[m'
	gitStatus=
	if $PS1_GIT_ENABLE_STATUS; then
		gitStatus=`	git diff --name-status 2>/dev/null					\
				|	cut -f 1											\
				|	sort -u												\
				|	tr -d '\n0123456789'								`
		[ -n "$gitStatus" ] && gitStatus="\e[00;31m$gitStatus\e[m"
		gitStatusStaged=`	git diff --name-status --staged 2>/dev/null	\
						|	cut -f 1									\
						|	sort -u										\
						|	tr -d '\n0123456789'						`
		[ -n "$gitStatusStaged" ] && gitStatus="\e[00;32m$gitStatusStaged\e[m$gitStatus"
		[ -n "$gitStatus" ] && gitStatus="|$gitStatus"
	fi
	gitStash=
	let gitStashCount=` git stash list | wc -l `
	[ $gitStashCount -gt 0 ]															\
		&& gitStash=` printf "%$(( $gitStashCount / 2 ))s" | tr ' ' ':' `				\
		&& gitStash=$gitStash` printf "%$(( $gitStashCount % 2 ))s" | tr ' ' '.' `		\
		&& gitStash='\e[01;33m'$gitStash'\e[m'
	gitWipPack=
	[ -f "$gitDir/git.wip.tgz" ]		\
		&& gitWipPack='\e[01;35m*\e[m'
	# @todo	Move this description at the begining of the section 2.
	# @hack	Print, and surround non-printable sequences (colors) with
	#		values "0x01" and "0x02" as for PS1 escape sequences "\[" and "\]".
	#		This ensures correct PS1 line length calculation, to eleminate
	#		incorrect text rendering (positioning) while navigating or search bash history.
	# @see	https://stackoverflow.com/a/43462720
	echo -en "|$gitBranchDescription$gitBranch$gitRebaseCommit$gitCherryCommit$gitDetachedCommit$gitAhead$gitStatus$gitStash$gitWipPack"	\
		| sed -r 's/(\x1B\[[0-9;]*m)/\x01\1\x02/g'
	return 0
}

function ps1.vim.session() {
	_vim.num_sessions									\
		|| echo -en "\x01\e[7;33m\x02vim~\x01\e[m\x02"
	return 0
}

function ps1.shell.level() {
	shellLevel=$SHLVL
	[ -z "$shellLevel" ]	\
		&& return 0
	let shellLevel=$shellLevel-1
	[ $shellLevel -gt 0 ]										\
		&& echo -en "\x01\e[7;34m\x02^$shellLevel\x01\e[m\x02"
	return 0
}
function ps1.shell.jobs() {
	let jobsCount=` jobs | grep -P '^\[\d+\]\S?\s*(Stopped|Running)\b' | wc -l `
	[ $jobsCount -gt 0 ]										\
		&& echo -en "\x01\e[7;32m\x02*$jobsCount\x01\e[m\x02"
	return 0
}
function ps1.shell.mail() {
	mailFile="/var/mail/$USER"
	[ ! -e "$mailFile" ] && return 0
	let mailSize=` ls -s "$mailFile" | cut -d' ' -f1 `
	[ $mailSize -gt 0 ]											\
		&& echo -en "\x01\e[1;33m\x02*\x01\e[m\x02"
	return 0
}
export PS1_SHELL_EXIT_CODE=0
function ps1.shell.exit_code() {
	let exitCode="$PS1_SHELL_EXIT_CODE"
	[ $exitCode -ne 0 ]	\
		&& echo -en "\x01\e[37;41m\x02E$exitCode\x01\e[m\x02"
}
function ps1.shell.status() {
	ps1.shell.level
	ps1.shell.jobs
	ps1.shell.mail
	ps1.shell.exit_code
}

##########################################################################################
### 3. HELPERS
##########################################################################################

function _vcs.wip.pack() {
	vcsType=` echo ${FUNCNAME[1]} | sed 's/\.wip\.pack//g' `
	wipTgz=
	[ "$vcsType" == 'git' ] && wipTgz='git.wip.tgz'
	[ "$vcsType" == 'svn' ] && wipTgz='svn.wip.tgz'
	[ -z "$wipTgz" ]														\
		&& echo "ERROR: Unknown VCS (invoked from <${FUNCNAME[1]}>)!" >&2 	\
		&& return 1
	if [ "$1" = '-u' ] ; then
		[ ! -f "$wipTgz" ]								\
			&& echo "ERROR: <$wipTgz> not exists!" >&2 	\
			&& return 1
		trap 'false' SIGINT
		echo 'Applying WIP... (press ^C to interrupt)'
		wipTmp=` mktemp -d `
		tar -zf "$wipTgz" -C "$wipTmp" -x
		wipDir="$PWD"
		cd "$wipTmp"
		find ./																	\
			-type f																\
			-exec test -f "$wipDir"'/{}' \;										\
			\(																	\
				-exec diff -q '{}' "$wipDir"'/{}' \;							\
				-or																\
				-exec vim -R -c 'cd "'"$wipDir"'"' -d '{}' "$wipDir"'/{}' \;	\
				-exec echo -n 'Apply changes? [y/n]: ' \;						\
				-ok cp '{}' "$wipDir"'/{}' \;									\
				-exec /bin/true \;												\
			\)																	\
			-or																	\
			-exec test ! -f "$wipDir"'/{}' \;									\
			-not -type d														\
			\(																	\
				-exec echo 'New file: ''{}' \;									\
				-exec cp '{}' "$wipDir"'/{}' \;									\
			\)																	\
			-or																	\
			-type d																\
			\(																	\
				-exec test -d "$wipDir"'/{}' \;									\
				-or																\
				-exec echo -n 'Create directory <{}>? [y/n]: ' \;				\
				-ok mkdir "$wipDir"'/{}' \;										\
			\)
		let findStatus=$?
		cd "$wipDir"
		rm -rf "$wipTmp"
		trap - SIGINT
		if [ $findStatus -ne 130 ]; then # no SIGINT
			echo -n "Remove <$wipTgz> file? [Y/n]: "
			read wipRemove
			[ "$wipRemove" = 'Y' ] && rm "$wipDir/$wipTgz"
		fi
	else
		[ -f "$wipTgz" ]									\
			&& echo "ERROR: <$wipTgz> already exists!" >&2 	\
			&& return 1
		wipFiles=
		[ "$vcsType" == 'git' ] && wipFiles=` git status -s | sed 's/^...//g' `
		[ "$vcsType" == 'svn' ] && wipFiles=` svn status -q | sed 's/^\S\+\s*//g' `
		[ -z "$wipFiles" ]							\
			&& echo "ERROR: No files to pack!" >&2	\
			&& return 1
		tar -z -c -f "$wipTgz" $* $wipFiles
	fi
}

##########################################################################################
### 4. GIT UTILS
##########################################################################################

function git.fetch.all() {
	maxDepth=
	[ "$1" = '-r' ] || maxDepth='-maxdepth 1'
	find .									\
		$maxDepth							\
		-type d								\
		-name \*.git						\
		-not -regex '.*/\.git/?.*'			\
		-exec echo 'Fetching: {}...' \;		\
		-exec git -C '{}' fetch --all \;	\
		-exec git -C '{}' status -sb \;
}

function git.wip.pack() {
	_vcs.wip.pack $@
}

function git.info() {
	git st
	git logi
}

function git.rmorig() {
	find . -type f -name \*.orig
	echo -n "Remove this files? [Y/n]: "
	read removeYes
	[ "$removeYes" = 'Y' ] && find . -type f -name \*.orig -delete
}

function git.commit.stats() {
	rebases=` git reflog | grep ': rebase (start)' | wc -l `
	commits=` git reflog | grep ': commit' | wc -l `
	echo "$commits.$rebases" >> GIT_COMMIT_STATS
	echo "$commits.$rebases (commits.rebases)"
}

function git.autofixup() {
	function PS1_git_autofixup_usage() {
		echo "
Usage:

	git.autofixup [ <fixup_commit_hash> ] [ <files...> ]

		<fixup_commit_hash>		If specified, commit hash deduction stage will be bypassed. Given hash will be used.
		<files...>				Files to fixup.
"
		unset PS1_git_autofixup_usage
	}

	fileNames="$@"
	fixupCommit=
	( echo "$1" | grep -s '^[0-9a-f]\+$' )			\
		&& fixupCommit="$1"							\
		&& fileNames=` echo "$fileNames"			\
			| sed "s/^$fixupCommit//g"				\
			`
	fileNames=` git diff --staged --name-only $fileNames `
	echo "git.autofixup.fileNames: <$fileNames>"

	[ -z "$fileNames" ]								\
		&& echo "git.autofixup.WARNING: No files changed (forget to stage?)." \
		&& return

	if [ -z "$fixupCommit" ]; then
		echo 'git.autofixup.fixupCommit: guessing...'
		for fileName in $fileNames; do
			echo "git.autofixup.fileName: $fileName"
			notCommittedRegex='^0\+ (Not Committed Yet '
			commitHash=` git blame $fileName			\
				| grep -C1 "$notCommittedRegex"			\
				| grep -v "$notCommittedRegex"			\
				| grep -v -- '^--$'						\
				| sed 's/^^\?\<\([0-9a-f]\+\)\>.*/\1/g'	\
				| sort -u								\
				`
			echo "git.autofixup.commitHash: $commitHash"
			for h in $commitHash; do
				git log --oneline -1 "$h"
			done
			[ $( echo "$commitHash" | wc -w ) -ne 1 ]	\
				&& echo "git.autofixup.ERROR: Different commits found surrounding fixup code. Can't guess the fixup commit." >&2 \
				&& PS1_git_autofixup_usage				\
				&& return 1
			[ -z "$fixupCommit" ] && fixupCommit="$commitHash"
			[ "$fixupCommit" != "$commitHash" ]			\
				&& echo "git.autofixup.ERROR: Different files belongs to different commits. Can't guess the fixup commit." >&2 \
				&& PS1_git_autofixup_usage				\
				&& return 1
		done
	fi
	echo "git.autofixup.fixupCommit: $fixupCommit"

	git commit --fixup="$fixupCommit"
	let result=$?
	unset PS1_git_autofixup_usage
	return $result
}

##########################################################################################
### 5. SVN UTILS
##########################################################################################

function svn.vim() {
	svn diff --diff-cmd=svn.vimdiff.wrapper $@
}

function svn.wip.pack() {
	_vcs.wip.pack $@
}

##########################################################################################
### 6. VIM UTILS
##########################################################################################

function _vim.num_sessions() {
	sessionsList=`
		grep -H '^let SessionLoad = 1$' *.vim 2>/dev/null	\
			| sed 's/:let SessionLoad = 1\$//g'
		`
	let sessionsCount=`
		echo -n "$sessionsList"	\
			| wc -w
		`
	[ "$1" = 'list' ]			\
		&& echo $sessionsList
	return $sessionsCount
}

function vim.session() {
	sessionsList=(` _vim.num_sessions list `)
	let sessionsCount=$?
	[ $sessionsCount -eq 0 ]								\
		&& echo -e "\e[31mNo VIM sessions found.\e[m"		\
		&& return 0
	sessionsList=(` ls -t ${sessionsList[*]} `)
	if [ $sessionsCount -eq 1 ] ; then
		vim -S $sessionsList
		return $?
	fi
	ellipsis=
	[ $sessionsCount -gt 9 ]		\
		&& ellipsis="[*] ...\n"		\
		&& let sessionsCount=9
	let i=0
	while [ $i -lt $sessionsCount ]
		do let i+=1
		editDate=` ls -l "${sessionsList[$i-1]}"				\
			| sed -E 's/^([^ ]+ +){5}(([^ ]+ +){3}).*/\2/g'		\
			`
		echo -e "\e[32m[$i] \e[36m$editDate\e[m${sessionsList[$i-1]}"
	done
	echo -en "$ellipsis"
	echo -e "\e[31m[0]\e[m Do not open VIM."
	read -sn 1 index
	[ "$index" == "" ]	\
		&& let index=1
	[ "$index" -ge '0' ] 2>/dev/null	\
		|| return 0
	[ $index -eq 0 -o $index -gt $sessionsCount ] 	\
		&& return 0
	vim -S "${sessionsList[$index-1]}"
	return $?
}

##########################################################################################
### 7. COMMON ALIASES
##########################################################################################

alias colgrep='grep -RnPH --color=always'

##########################################################################################
### 8. ADD BIN DIRECTORY TO THE PATH
##########################################################################################

PATH="$HOME/bin/:$PATH"
