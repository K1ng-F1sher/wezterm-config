local wezterm = require 'wezterm'
local session_manager = wezterm.plugin.require("https://github.com/abidibo/wezterm-sessions")
local config = {}
local act = wezterm.action
local mux = wezterm.mux

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
config.window_padding = {
  left = 2,
  right = 2,
  top = 2,
  bottom = "0.3cell",
}
config.colors = {
  tab_bar = {
    active_tab = {
      fg_color = '#073642',
      bg_color = '#84f5ed'
    }
  }
}
config.switch_to_last_active_tab_when_closing_tab = true

wezterm.on("save_session", function(window) session_manager.save_state(window) end)
wezterm.on("load_session", function(window) session_manager.load_state(window) end)
wezterm.on("restore_session", function(window) session_manager.restore_state(window) end)

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
  {
    key = 'a',
    mods = 'LEADER',
    action = act.AttachDomain 'unix',
  },
  {
    key = 'd',
    mods = 'LEADER',
    action = act.DetachDomain { DomainName = 'unix' },
  },
  {
    key = 'r',
    mods = 'LEADER',
    action = act.PromptInputLine {
      description = 'Enter name for the new workspace',
      action = wezterm.action_callback(
        function(window, pane, line)
          if line then
            mux.rename_workspace(
              window:mux_window():get_workspace(),
              line
            )
          end
        end
      ),
    },
  },

  -- Show the launcher in fuzzy selection mode and have it list all workspaces and allow activating one.
  {
    key = 's',
    mods = 'LEADER',
    action = act.ShowLauncherArgs {
      flags = 'FUZZY|WORKSPACES',
    },
  },

  -- Session manager bindings
  {
    key = 's',
    mods = 'LEADER|SHIFT',
    action = act({ EmitEvent = "save_session" }),
  },
  {
    key = 'L',
    mods = 'LEADER|SHIFT',
    action = act({ EmitEvent = "load_session" }),
  },
  {
    key = 'R',
    mods = 'LEADER|SHIFT',
    action = act({ EmitEvent = "restore_session" }),
  },
}

config.unix_domains = {
  {
    name = 'unix',
  },
}

return config
