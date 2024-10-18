# Ultimate valgrind command for minishell

Run `valms` to start minishell with all valgrind flags, suppression file and no reports from external binaries.

### Usage

```bash
valms
```

### Setup

This will add the `valms` function to zsh and bash:

```bash
echo '
valms() {
    bash -c '"'"'
    export SUPPRESSION_FILE=$(mktemp)
    curl -s https://raw.githubusercontent.com/LeaYeh/42_minishell_tester/master/utils/minishell.supp > $SUPPRESSION_FILE
    export VALGRIND=$(which valgrind)
    export VALGRINDFLAGS="--errors-for-leak-kinds=all --leak-check=full --read-var-info=yes --show-error-list=yes --show-leak-kinds=all --suppressions=$SUPPRESSION_FILE --trace-children=yes --track-origins=yes"
    export VALGRINDFDFLAGS="--track-fds=all"
    export IGNORED_PATHS="/bin/* /usr/bin/* /usr/sbin/* $(which -a norminette)"
    export VALGRINDFLAGS+=" --trace-children-skip=$(echo $IGNORED_PATHS | sed '"'\"'\"'"'s/ /,/g'"'\"'\"'"')"
    export PATH="/bin:/usr/bin:/usr/sbin:$PATH"
    $VALGRIND $VALGRINDFLAGS $VALGRINDFDFLAGS ./minishell
    EXIT_CODE=$?
    rm -f $SUPPRESSION_FILE
    echo "Exit code: $EXIT_CODE"
    exit $EXIT_CODE
    '"'"'
}
' | tee -a ~/.zshrc ~/.bashrc >/dev/null
exec $SHELL
```
