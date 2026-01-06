# Go Environment Variables

Add these lines to your shell profile (`~/.bashrc`, `~/.zshrc`, or `~/.profile`):

```bash
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GOPATH/bin:/usr/local/go/bin
```

## Apply Changes

```bash
source ~/.bashrc  # or ~/.zshrc or ~/.profile
```

## Verify Installation

```bash
go version
go env GOPATH
```
