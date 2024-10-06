# conflict-marker.nvim


The simple git conflict resolver for neovim


![image](https://github.com/user-attachments/assets/c4478663-0ec3-4f72-9b0d-e4ad98cf5e38)


You can customize these colors, I just picked something at random :P


<!--toc:start-->
- [conflict-marker.nvim](#conflict-markernvim)
  - [Philosophy](#philosophy)
  - [User commands](#user-commands)
  - [Highlighting](#highlighting)
    - [Groups](#groups)
  - [Config](#config)
<!--toc:end-->


## Philosophy

- it has to be simple (in fact whole plugin is under 300 lua loc)
- performance-first (finding conflicts does not load whole buf into extra memory)


## User commands

- `ConflictOurs`: resolves the conflict under the cursor with our changes
- `ConflictTheirs`: resolves the conflict under the cursor with their changes
- `ConflictBoth`: resolves the conflict under the cursor with both changes (removes markers)
- `ConflictNone`: resolves the conflict the best way possible, just removing it xd

## Highlighting

Highlighting is enabled by default but can be disabled by setting `highlights = false` in config

Note for `nvimdiff` users !!!: if highlighting is enabled, the `Diff*` hl groups are disabled in buffers which have a
conflict, because those groups interfere heavily with `conflict-marker.nvim` highlighting

### Groups

- `ConflictOurs`
- `ConflictTheirs`


## Config

```lua
require("conflict-marker").setup({
    highlights = true,
    on_attach = function() end,
})
```

