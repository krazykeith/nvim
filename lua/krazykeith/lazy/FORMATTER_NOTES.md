# Formatter Configuration Notes

## Project Settings Priority

The formatter configuration is set up to **always prioritize project-specific settings** over global Neovim settings.

### How it works:

1. **Biome Formatter**:
   - Searches for project config files in this order:
     - `biome.json`
     - `biome.jsonc`
     - `.biome.json`
     - `package.json` (for biome config section)
   - Runs from the project root directory where config is found
   - Falls back to current working directory if no config found

2. **File Path Resolution**:
   - Uses `--stdin-file-path` with the actual file path
   - This ensures Biome can find and use project-specific configs
   - Project settings in biome.json will override any global settings

3. **Working Directory**:
   - The `cwd` function ensures formatters run from the project root
   - This allows formatters to find their config files correctly

### Supported File Types with Biome:
- TypeScript (.ts, .tsx)
- JavaScript (.js, .jsx)
- JSON
- CSS/SCSS
- HTML
- Markdown

### To disable formatting for a project:
1. Set `vim.g.disable_autoformat = true` globally
2. Set `vim.b.disable_autoformat = true` for specific buffers
3. Or configure format_on_save in your project's biome.json

### Example project biome.json:
```json
{
  "$schema": "https://biomejs.dev/schemas/1.9.4/schema.json",
  "formatter": {
    "enabled": true,
    "indentStyle": "tab",  // Project prefers tabs
    "indentWidth": 4,      // Project uses 4-width indents
    "lineWidth": 120       // Project uses 120 char lines
  }
}
```

These project settings will automatically override any Neovim defaults.

