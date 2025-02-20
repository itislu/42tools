# Bear

Speed up workspace parsing of your IDE by generating a compilation database in one command with `bear`.

## Prerequisites

### Homebrew

```bash
git clone --depth=1 https://github.com/Homebrew/brew $HOME/.brew &&
echo 'export PATH=$HOME/.brew/bin:$PATH' >> $HOME/.zshrc &&
source $HOME/.zshrc &&
brew update
```

You can now install packages using Homebrew.

---

## Installation

```bash
brew install bear
```

## Usage

```bash
bear -- make re
```

https://github.com/rizsotto/Bear
