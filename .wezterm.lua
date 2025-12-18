---@type Wezterm
local wezterm = require 'wezterm'
local session_manager = wezterm.plugin.require("https://github.com/abidibo/wezterm-sessions")
---@type Config
local config = {}
local act = wezterm.action
local mux = wezterm.mux

-- For better error messages:
if wezterm.config_builder then
  config = wezterm.config_builder()
end

wezterm.log_error('Home ' .. wezterm.home_dir)
config.background = {
  {
    source = { File = wezterm.home_dir .. "/.wezterm/lava-blossom.jpg" },
    hsb = { brightness = 0.03 }
  }
}
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

wezterm.on('format-window-title', function()
  return 'Wezterm -[ ' .. wezterm.mux.get_active_workspace() .. ' ]-'
end)

wezterm.on("save_session", function(window) session_manager.save_state(window) end)
wezterm.on("load_session", function(window) session_manager.load_state(window) end)
wezterm.on("restore_session", function(window) session_manager.restore_state(window) end)

config.leader = {
  key = 'Space',
  mods = 'CTRL',
  timeout_milliseconds = 2000,
}

config.keys = {
  -- TABS
  -- Rename tab
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
    key = 't',
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
    mods = 'ALT',
    action = act.ActivatePaneDirection 'Left',
  },
  {
    key = 'l',
    mods = 'ALT',
    action = act.ActivatePaneDirection 'Right',
  },
  {
    key = 'k',
    mods = 'ALT',
    action = act.ActivatePaneDirection 'Up',
  },
  {
    key = 'j',
    mods = 'ALT',
    action = act.ActivatePaneDirection 'Down',
  },
  {
    key = '{',
    mods = 'LEADER|SHIFT',
    action = act.PaneSelect { mode = 'SwapWithActiveKeepFocus' }
  },
  -- Switch to another pane using a selector
  {
    key = 'p',
    mods = 'ALT',
    action = wezterm.action { PaneSelect = { alphabet = 'jkl;asdfgh' } }
  },
  -- Close all but the active pane in the current tab.
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

  -- WORKSPACES
  {
    key = 'n', -- New workspace
    mods = 'ALT',
    action = act.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = 'Bold' } },
        { Foreground = { AnsiColor = 'Fuchsia' } },
        { Text = 'Enter name for new workspace' },
      },
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:perform_action(
            act.SwitchToWorkspace {
              name = line,
            },
            pane
          )
        end
      end),
    },
  },
  {
    key = 'e', -- edit workspace name
    mods = 'ALT',
    action = act.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = 'Bold' } },
        { Foreground = { AnsiColor = 'Fuchsia' } },
        { Text = 'Enter new name for the current workspace (' .. wezterm.mux.get_active_workspace() .. ')' },
      },
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
  -- Fuzzy search workspaces or create a new one.
  {
    key = 's',
    mods = 'LEADER',
    action = act.ShowLauncherArgs {
      flags = 'FUZZY|WORKSPACES',
    },
  },

  -- SESSIONS
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
    key = 's',
    mods = 'ALT',
    action = act({ EmitEvent = "save_session" }),
  },
  {
    key = 'l',
    mods = 'LEADER',
    action = act({ EmitEvent = "load_session" }),
  },
  {
    key = 'r',
    mods = 'ALT',
    action = act({ EmitEvent = "restore_session" }),
  },
  {
    key = 'd',
    mods = 'ALT',
    action = act({ EmitEvent = "delete_session" }),
  },
  {
    key = 'j',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ActivateTab(0),
  },
  {
    key = 'k',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ActivateTab(1),
  },
  {
    key = 'l',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ActivateTab(2),
  },
  {
    key = 'm',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ActivateTab(3),
  },
  {
    key = 'n',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ActivateTab(4),
  },
}

for i = 1, 8 do
  -- CTRL+ALT + number to move to that position
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'CTRL|ALT',
    action = wezterm.action.MoveTab(i - 1),
  })
end


config.unix_domains = {
  {
    name = 'unix',
  },
}

return config
