local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.automatically_reload_config = true
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 12.0
config.use_ime = true
config.window_background_opacity = 0.75
config.macos_window_background_blur = 20
config.color_scheme = "Catppuccin Mocha"

----------------------------------------------------
-- Tab
----------------------------------------------------
-- タイトルバーを非表示
config.window_decorations = "RESIZE"
-- タブバーの表示
config.show_tabs_in_tab_bar = true
-- タブが一つの時は非表示
config.hide_tab_bar_if_only_one_tab = true
-- falseにするとタブバーの透過が効かなくなる
-- config.use_fancy_tab_bar = false

-- タブバーの透過
config.window_frame = {
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
}

-- タブバーを背景色に合わせる
config.window_background_gradient = {
  colors = { "#000000" },
}

-- タブの追加ボタンを非表示
config.show_new_tab_button_in_tab_bar = false
-- nightlyのみ使用可能
-- タブの閉じるボタンを非表示
config.show_close_tab_button_in_tabs = false

-- タブ同士の境界線を非表示、背景を透過
config.colors = {
  tab_bar = {
    background = "rgba(0,0,0,0)",
    inactive_tab_edge = "none",
  },
  cursor_bg = "#cba6f7",
  cursor_fg = "#1e1e2e",
  cursor_border = "#cba6f7",
  compose_cursor = "#f38ba8",
}

-- タブの形をカスタマイズ
-- タブの左側の装飾
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
-- タブの右側の装飾
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local background = "#5c6d74"
  local foreground = "#FFFFFF"
  local edge_background = "none"
  if tab.is_active then
    background = "#ae8b2d"
    foreground = "#FFFFFF"
  end
  local edge_foreground = background
  local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "
  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_LEFT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

----------------------------------------------------
-- ステータスバー
----------------------------------------------------
wezterm.on("update-status", function(window, pane)
  local battery = ""
  for _, b in ipairs(wezterm.battery_info()) do
    local icon = ""
    if b.state == "Charging" then
      icon = wezterm.nerdfonts.md_battery_charging
    elseif b.state_of_charge >= 0.8 then
      icon = wezterm.nerdfonts.md_battery_high
    elseif b.state_of_charge >= 0.4 then
      icon = wezterm.nerdfonts.md_battery_medium
    else
      icon = wezterm.nerdfonts.md_battery_low
    end
    battery = icon .. " " .. string.format("%.0f%%", b.state_of_charge * 100)
  end

  local date = wezterm.strftime("%m/%d %H:%M")

  local leader = ""
  if window:leader_is_active() then
    leader = "LEADER  "
  end

  window:set_right_status(wezterm.format({
    { Foreground = { Color = "#f38ba8" } },
    { Text = leader },
    { Foreground = { Color = "#a6e3a1" } },
    { Text = battery .. "  " },
    { Foreground = { Color = "#89b4fa" } },
    { Text = date .. " " },
  }))
end)

----------------------------------------------------
-- keybinds
----------------------------------------------------
config.disable_default_key_bindings = true
config.keys = require("keybinds").keys
config.key_tables = require("keybinds").key_tables
config.leader = { key = "q", mods = "CTRL", timeout_milliseconds = 2000 }

return config
