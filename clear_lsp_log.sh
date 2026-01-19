#!/bin/bash

# Script to clear LSP log file if it gets too large
# Using Mason-installed terraform-ls and terraform (Homebrew version removed)
LSP_LOG="/Users/keithlassila/.local/state/nvim/lsp.log"
MAX_SIZE_MB=10

if [ -f "$LSP_LOG" ]; then
    # Get file size in MB
    SIZE_MB=$(du -m "$LSP_LOG" | cut -f1)
    
    if [ "$SIZE_MB" -gt "$MAX_SIZE_MB" ]; then
        echo "LSP log file is ${SIZE_MB}MB, clearing it..."
        echo "" > "$LSP_LOG"
        echo "LSP log file cleared."
    else
        echo "LSP log file is ${SIZE_MB}MB, no action needed."
    fi
else
    echo "LSP log file not found at $LSP_LOG"
fi
