local wezterm = require("wezterm")
local act = wezterm.action

-- Use config_builder for validation + better error messages
local config = wezterm.config_builder()

---------------------------------------------------------------------------
-- WSL
---------------------------------------------------------------------------
config.default_domain = "WSL:Ubuntu-24.04"
config.default_cwd = wezterm.home_dir

---------------------------------------------------------------------------
-- Theme
---------------------------------------------------------------------------
config.color_scheme = "Tokyo Night Storm"

---------------------------------------------------------------------------
-- Font
---------------------------------------------------------------------------
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 12.0
config.line_height = 1.15

---------------------------------------------------------------------------
-- Window
---------------------------------------------------------------------------
config.initial_cols = 100
config.initial_rows = 30

config.window_padding = {
  left = 10,
  right = 10,
  top = 8,
  bottom = 8,
}

---------------------------------------------------------------------------
-- Windows 11 appearance
---------------------------------------------------------------------------
config.window_decorations = "TITLE|RESIZE"
config.win32_system_backdrop = "Mica"
config.window_background_opacity = 0.96

---------------------------------------------------------------------------
-- Tab bar
---------------------------------------------------------------------------
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true           -- keeps it out of the way
config.hide_tab_bar_if_only_one_tab = false  -- always visible so workspaces show
config.show_tab_index_in_tab_bar = true

-- Show workspace name in the right status area
wezterm.on("update-right-status", function(window, _)
  local workspace = window:active_workspace()
  local date = wezterm.strftime("%H:%M")
  window:set_right_status(wezterm.format({
    { Foreground = { Color = "#7aa2f7" } },
    { Text = "󱂬 " .. workspace .. "  " },
    { Foreground = { Color = "#565f89" } },
    { Text = date .. "  " },
  }))
end)

---------------------------------------------------------------------------
-- Cursor
---------------------------------------------------------------------------
config.default_cursor_style = "SteadyBar"
config.cursor_blink_rate = 0

---------------------------------------------------------------------------
-- Performance
---------------------------------------------------------------------------
config.front_end = "WebGpu"
config.max_fps = 120
config.animation_fps = 120

---------------------------------------------------------------------------
-- General behaviour
---------------------------------------------------------------------------
config.scrollback_lines = 100000
config.window_close_confirmation = "NeverPrompt"
config.adjust_window_size_when_changing_font_size = false
config.automatically_reload_config = true
config.enable_scroll_bar = false

---------------------------------------------------------------------------
-- Hyperlinks
---------------------------------------------------------------------------
config.hyperlink_rules = wezterm.default_hyperlink_rules()
-- Highlight bare GitHub/GitLab references like "owner/repo"
table.insert(config.hyperlink_rules, {
  regex = [[\b([\w-]+/[\w-]+)#(\d+)\b]],
  format = "https://github.com/$1/issues/$2",
})

---------------------------------------------------------------------------
-- Leader key  (CTRL+a, same finger memory as tmux)
---------------------------------------------------------------------------
config.leader = {
  key = "a",
  mods = "CTRL",
  timeout_milliseconds = 1000,
}

---------------------------------------------------------------------------
-- Keys
---------------------------------------------------------------------------
config.keys = {

  -- ── Copy / Paste ──────────────────────────────────────────
  { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
  { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },

  -- ── Config ────────────────────────────────────────────────
  { key = "r", mods = "CTRL|SHIFT", action = act.ReloadConfiguration },

  -- ── Font size ─────────────────────────────────────────────
  { key = "=", mods = "CTRL", action = act.IncreaseFontSize },
  { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
  { key = "0", mods = "CTRL", action = act.ResetFontSize },

  -- ── Pane splitting ────────────────────────────────────────
  -- LEADER v = vertical split (side by side)
  {
    key = "v",
    mods = "LEADER",
    action = act.SplitPane({ direction = "Right" }),
  },
  -- LEADER s = horizontal split (top / bottom)
  {
    key = "s",
    mods = "LEADER",
    action = act.SplitPane({ direction = "Down" }),
  },

  -- ── Pane navigation (vim-style) ───────────────────────────
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

  -- ── Pane resizing ─────────────────────────────────────────
  { key = "H", mods = "LEADER", action = act.AdjustPaneSize({ "Left",  5 }) },
  { key = "J", mods = "LEADER", action = act.AdjustPaneSize({ "Down",  5 }) },
  { key = "K", mods = "LEADER", action = act.AdjustPaneSize({ "Up",    5 }) },
  { key = "L", mods = "LEADER", action = act.AdjustPaneSize({ "Right", 5 }) },

  -- ── Pane zoom (focus mode) ────────────────────────────────
  { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },

  -- ── Close current pane ────────────────────────────────────
  { key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },

  -- ── Tab management ────────────────────────────────────────
  { key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
  { key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },

  -- Rename tab
  {
    key = ",",
    mods = "LEADER",
    action = act.PromptInputLine({
      description = "Rename tab:",
      action = wezterm.action_callback(function(window, _, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },

  -- ── Workspace management ──────────────────────────────────
  -- Switch workspace (fuzzy launcher)
  {
    key = "w",
    mods = "LEADER",
    action = act.ShowLauncherArgs({ flags = "WORKSPACES" }),
  },

  -- New named workspace
  {
    key = "W",
    mods = "LEADER",
    action = act.PromptInputLine({
      description = "New workspace name:",
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:perform_action(
            act.SwitchToWorkspace({ name = line }),
            pane
          )
        end
      end),
    }),
  },

  -- ── Copy mode (keyboard text selection, no mouse needed) ──
  { key = "[", mods = "LEADER", action = act.ActivateCopyMode },

  -- ── Scrollback search ─────────────────────────────────────
  { key = "f", mods = "LEADER", action = act.Search({ CaseSensitiveString = "" }) },

  -- ── Quick launcher (tabs + workspaces + commands) ─────────
  { key = "Space", mods = "LEADER", action = act.ShowLauncher },

  -- ── Fullscreen ────────────────────────────────────────────
  { key = "F11", mods = "NONE", action = act.ToggleFullScreen },
}

-- LEADER + 1-9 → jump directly to that tab
for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = "LEADER",
    action = act.ActivateTab(i - 1),
  })
end

---------------------------------------------------------------------------
-- Mouse UX (your original bindings, unchanged)
---------------------------------------------------------------------------
config.mouse_bindings = {

  -- Select + auto copy
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = act.CompleteSelection("ClipboardAndPrimarySelection"),
  },

  -- Right click = paste
  {
    event = { Up = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = act.PasteFrom("Clipboard"),
  },

  -- Ctrl + click = open links
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "CTRL",
    action = act.OpenLinkAtMouseCursor,
  },

  -- Shift + drag = block selection
  {
    event = { Drag = { streak = 1, button = "Left" } },
    mods = "SHIFT",
    action = act.ExtendSelectionToMouseCursor("Block"),
  },
}

return config
