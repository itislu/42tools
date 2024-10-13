# Automatic commit message labels for modularized projects

This alias automatically puts the numbers of the current module and the current exercise at the very front as the scope of the commit. The numbers are extracted from the current directory.

**Example:**<br>
You are in the directory `cpp00/ex00` -> the scope would be `00/00`.

The alias also conveniently formats your commit messages according to the [Conventional Commits](https://www.conventionalcommits.org/) - first a keyword, then the message.<br>
It puts the first argument as the type of the commit, everything else as the message. The type is usually one of the following: `feat`, `fix`, `refactor`, `style`, `test`, `docs`, `chore`. The message is a short description of the commit.

### Usage

This is how you can use the alias:

```bash
git cmm feat Convert program arguments to uppercase
```

**Result:**

```
[00/00] feat: Convert program arguments to uppercase
```

### Setup

To set this alias up just for your CPP repository (so not globally across all repositories), run the following command:

```bash
git config alias.cmm '!f() {
    local exercise_path=$(echo "$GIT_PREFIX" | sed '"'"'s/^..\///'"'"' | grep -oE '"'"'.*(/|^)ex[0-9]{2}(/|$)'"'"');
    local module=$(dirname "$exercise_path" | xargs basename | sed '"'"'s/^\.$//'"'"');
    local exercise=$(basename "$exercise_path");
    if [ -z "$module" ] && [ -z "$exercise" ]; then
        module=$(basename "$GIT_PREFIX");
    fi;
    local module_num=$(echo "$module" | grep -oE '"'"'[0-9]+'"'"');
    local exercise_num=$(echo "$exercise" | grep -oE '"'"'[0-9]{2}'"'"');
    local type=$1;
    shift;
    local message="$@";
    local scope="";
    if [ -n "$module_num" ] && [ -n "$exercise_num" ]; then
        scope="[$module_num/$exercise_num] ";
    elif [ -n "$module" ]; then
        scope="[$module] ";
    elif [ -n "$exercise" ]; then
        scope="[$exercise] ";
    fi;
    git commit -m "$scope$type: $message";
}; f'
```

## Pre-populate the scope in the commit message file

If you prefer to use `git commit` to edit your commit messages in your editor, you can use a git hook to automatically pre-populate the scope in the commit message file.

This means when you `git commit`, the file that opens already has the scope of your commit in the first line.

### Setup

1. **Make sure you are in the root of your repository.**

2. Run the following command:
   ```bash
   cat << 'EOF' >> .git/hooks/prepare-commit-msg
   #!/bin/sh

   COMMIT_MSG_FILE=$1
   COMMIT_SOURCE=$2
   SHA1=$3

   # Remove the "# Please enter the commit message..." help message.
   /usr/bin/perl -i.bak -ne 'print unless(m/^. Please enter the commit message/..m/^#$/)' "$COMMIT_MSG_FILE"

   # Only use if it's a regular commit without -m or -F
   case "$2,$3" in
   	,|template,)
   		# Prepend the scope to the commit message file
   		exercise_path=$(echo "$GIT_PREFIX" | sed 's/^..\///' | grep -oE '.*(/|^)ex[0-9]{2}(/|$)')
   		module=$(dirname "$exercise_path" | xargs basename | sed 's/^\.$//')
   		exercise=$(basename "$exercise_path")
   		if [ -z "$module" ] && [ -z "$exercise" ]; then
   			module=$(basename "$GIT_PREFIX")
   		fi
   		module_num=$(echo "$module" | grep -oE '[0-9]+')
   		exercise_num=$(echo "$exercise" | grep -oE '[0-9]{2}')
   		scope=""
   		if [ -n "$module_num" ] && [ -n "$exercise_num" ]; then
   			scope="[$module_num/$exercise_num] "
   		elif [ -n "$module" ]; then
   			scope="[$module] "
   		elif [ -n "$exercise" ]; then
   			scope="[$exercise] "
   		fi
   		sed -i "1i$scope" "$COMMIT_MSG_FILE"
   		;;
   	*) ;;
   esac
   EOF
   chmod +x .git/hooks/prepare-commit-msg
   ```
