local wezterm = require 'wezterm'
local config = {}
local act = wezterm.action

-- For better error messages:
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.default_cwd = "D:/git"
config.default_prog = { 'pwsh.exe', '-NoLogo' }
config.color_scheme = 'Tokyo Night'
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = true
config.tab_max_width = 32
config.colors = {
  tab_bar = {
    active_tab = {
      fg_color = '#073642',
      bg_color = '#84f5ed'
    }
  }
}
config.switch_to_last_active_tab_when_closing_tab = true

config.leader = {
  key = 'Space',
  mods = 'CTRL',
  timeout_milliseconds = 2000,
}

config.keys = {
  {
    key = ',',
    mods = 'LEADER',
    action = act.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = 'Bold' } },
        { Foreground = { AnsiColor = 'Fuchsia' } },
        { Text = 'Enter name for this tab' },
      },
      action = wezterm.action_callback(
        function(window, pane, line)
          if line then
            window:active_tab():set_title(line)
          end
        end
      ),
    },
  },
  {
    key = 'w',
    mods = 'LEADER',
    action = act.ShowTabNavigator,
  },

  -- PANES
  -- Vertical split
  {
    -- |
    key = '|',
    mods = 'LEADER|SHIFT',
    action = act.SplitPane {
      direction = 'Right',
      size = { Percent = 50 },
    },
  },
  -- Horizontal split
  {
    -- -
    key = '-',
    mods = 'LEADER',
    action = act.SplitPane {
      direction = 'Down',
      size = { Percent = 50 },
    },
  },
  {
    key = 'p',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Prev',
  },
  {
    key = 'n',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Next',
  },
  {
    key = 'h',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Left',
  },
  {
    key = 'l',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Right',
  },
  {
    key = 'k',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Up',
  },
  {
    key = 'j',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Down',
  },
  {
    key = '{',
    mods = 'LEADER|SHIFT',
    action = act.PaneSelect { mode = 'SwapWithActiveKeepFocus' }
  },
  {
    key = 'o',
    mods = 'LEADER',
    action = wezterm.action_callback(function(win, pane)
      local tab = win:active_tab()
      for _, p in ipairs(tab:panes()) do
        if p:pane_id() ~= pane:pane_id() then
          p:activate()
          win:perform_action(act.CloseCurrentPane { confirm = false }, p)
        end
      end
    end),
  },
}

return config
