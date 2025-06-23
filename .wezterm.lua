local wezterm = require 'wezterm'
local config = {}

config.default_prog = { 'pwsh.exe', '-NoLogo' }
config.color_scheme = 'Tokyo Night'

config.leader = {
  key = 'a',
  mods = 'CTRL',
  timeout_milliseconds = 2000,
}

return config
