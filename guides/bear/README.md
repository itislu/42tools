# Bear

Speed up workspace parsing of your IDE by generating a compilation database with Bear.

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

```
brew install bear
```

## Usage

```
make fclean ; bear -- make
```

https://github.com/rizsotto/Bear
