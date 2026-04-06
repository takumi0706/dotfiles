local wezterm = require("wezterm")

local M = {}

-- ===========================================================
-- カスタマイズ可能な設定
-- ===========================================================
M.config = {
  bottom_height = 0.30,
  nvim_socket_dir = "/tmp",
  default_bottom_tool = "terminal",
  editor_cmd = "nvim",
}

-- ===========================================================
-- IDE状態管理
-- ===========================================================
-- ワークスペース名をキーにした状態テーブル
M._state = {}

local function get_state(workspace)
  if not M._state[workspace] then
    M._state[workspace] = {
      nvim_pane_id = nil,
      bottom_pane_id = nil,
      bottom_visible = false,
      bottom_tool = M.config.default_bottom_tool,
      project_dir = nil,
      nvim_socket = nil,
    }
  end
  return M._state[workspace]
end

-- ペインが生存しているか確認するヘルパー
local function pane_alive(pane_id)
  if not pane_id then
    return false
  end
  local pane = wezterm.mux.get_pane(pane_id)
  return pane ~= nil
end

-- ===========================================================
-- IDEレイアウト構築
-- ===========================================================
function M.create_ide_layout(window, pane, project_dir)
  local cwd_url = pane:get_current_working_dir()
  local dir = project_dir
  if not dir and cwd_url then
    dir = cwd_url.file_path
  end
  if not dir then
    dir = wezterm.home_dir
  end

  local workspace = window:active_workspace()
  local state = get_state(workspace)

  -- 既にIDEレイアウトが存在し、ペインが生存していれば何もしない
  if pane_alive(state.nvim_pane_id) then
    return
  end

  state.project_dir = dir

  -- ソケットパスを生成 (ワークスペース名ベース)
  local safe_ws = workspace:gsub("[^%w]", "_")
  local socket_name = "nvim-ide-" .. safe_ws
  state.nvim_socket = M.config.nvim_socket_dir .. "/" .. socket_name .. ".sock"

  -- Step 1: 現在のペインをNeovimペインとして使用
  state.nvim_pane_id = pane:pane_id()
  pane:send_text(M.config.editor_cmd .. " --listen " .. state.nvim_socket .. " " .. dir .. "\n")

  -- Step 2: 下パネルを作成
  local bottom_pane = pane:split({
    direction = "Bottom",
    size = M.config.bottom_height,
    cwd = dir,
  })
  state.bottom_pane_id = bottom_pane:pane_id()
  state.bottom_visible = true

  -- Neovimペインにフォーカスを戻す
  pane:activate()
end

-- ===========================================================
-- 下パネルトグル
-- ===========================================================
function M.toggle_bottom(window, pane)
  local workspace = window:active_workspace()
  local state = get_state(workspace)

  if state.bottom_visible and pane_alive(state.bottom_pane_id) then
    -- 下パネルを閉じる
    local bottom_pane = wezterm.mux.get_pane(state.bottom_pane_id)
    if bottom_pane then
      bottom_pane:send_text("\x03")
      bottom_pane:send_text("exit\n")
    end
    state.bottom_visible = false
    state.bottom_pane_id = nil
  else
    -- 下パネルを再作成
    local nvim_pane = nil
    if pane_alive(state.nvim_pane_id) then
      nvim_pane = wezterm.mux.get_pane(state.nvim_pane_id)
    end
    if not nvim_pane then
      return
    end

    local dir = state.project_dir or wezterm.home_dir
    local bottom_pane = nvim_pane:split({
      direction = "Bottom",
      size = M.config.bottom_height,
      cwd = dir,
    })
    state.bottom_pane_id = bottom_pane:pane_id()
    state.bottom_visible = true

    -- 以前のツールを復元
    if state.bottom_tool == "lazygit" then
      bottom_pane:send_text("lazygit\n")
    end
  end
end

-- ===========================================================
-- フォーカスモード (Zoom)
-- ===========================================================
function M.toggle_focus_mode(window, pane)
  local tab = pane:tab()
  if not tab then
    return
  end

  -- Neovimペインをアクティブにしてからzoomトグル
  local workspace = window:active_workspace()
  local state = get_state(workspace)
  if pane_alive(state.nvim_pane_id) then
    local nvim_pane = wezterm.mux.get_pane(state.nvim_pane_id)
    if nvim_pane then
      nvim_pane:activate()
    end
  end

  window:perform_action(wezterm.action.TogglePaneZoomState, pane)
end

-- ===========================================================
-- 下パネルツール切り替え
-- ===========================================================
function M.switch_bottom_tool(window, pane, tool)
  local workspace = window:active_workspace()
  local state = get_state(workspace)

  if not pane_alive(state.bottom_pane_id) then
    return
  end
  local bottom_pane = wezterm.mux.get_pane(state.bottom_pane_id)
  if not bottom_pane then
    return
  end

  -- 現在のプロセスを中断してプロンプトに戻す
  bottom_pane:send_text("\x03")
  bottom_pane:send_text("\n")

  if tool == "terminal" then
    -- シェルに戻るだけ
    state.bottom_tool = "terminal"
  elseif tool == "lazygit" then
    bottom_pane:send_text("lazygit\n")
    state.bottom_tool = "lazygit"
  end

  bottom_pane:activate()
end

-- ===========================================================
-- ツール循環切り替え
-- ===========================================================
local tool_cycle = { "terminal", "lazygit" }

function M.cycle_bottom_tool(window, pane)
  local workspace = window:active_workspace()
  local state = get_state(workspace)
  local current = state.bottom_tool or "terminal"

  local next_index = 1
  for i, t in ipairs(tool_cycle) do
    if t == current then
      next_index = (i % #tool_cycle) + 1
      break
    end
  end

  M.switch_bottom_tool(window, pane, tool_cycle[next_index])
end

return M
