local M = {}

local function get_media_path()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]

  local patterns = {
    "%[.-%]%((.-)%)",  -- [text](path)
    "!%[.-%]%((.-)%)", -- ![alt](path)
  }

  for _, pattern in ipairs(patterns) do
    for path in line:gmatch(pattern) do
      local current_file = vim.api.nvim_buf_get_name(0)
      local current_dir  = vim.fn.fnamemodify(current_file, ":h")

      local full_path    = current_dir .. "/" .. path

      return full_path
    end
  end
  return nil
end

function M.open_media()
  local path = get_media_path()
  if not path then
    vim.notify("No media path found under cursor", vim.log.levels.WARN)
    return
  end

  local ext = path:match("^.+%.(.+)$")
  if not ext then
    vim.notify("Could not determine file type", vim.log.levels.WARN)
    return
  end

  local cmd
  if ext:match("png") or ext:match("jpe?g") or ext:match("gif") or ext:match("webp") then
    cmd = string.format("feh '%s' &", path)
  elseif ext:match("mp4") or ext:match("mkv") or ext:match("webm") or ext:match("avi") then
    cmd = string.format("mpv '%s' &", path)
  else
    vim.notify("Unsupported media type: " .. ext, vim.log.levels.WARN)
    return
  end
  print(cmd)
  vim.fn.system(cmd)
end

function M.follow_link()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- Lua is 1-based

  local patterns = {
    { "%[%[([^|%]]+)|?[^%]]*%]%]", 2 }, -- [[path|label]] or [[path]]
    { "%[.-%]%((.-)%)",            2 }, -- [text](path)
  }

  local link_path = nil

  for _, entry in ipairs(patterns) do
    local pattern = entry[1]

    local start = 1
    while true do
      local s, e, path = line:find(pattern, start)
      if not s then break end

      if col >= s and col <= e then
        link_path = path
        break
      end

      start = e + 1
    end

    if link_path then break end
  end

  if not link_path then
    vim.notify("No link under cursor", vim.log.levels.WARN)
    return
  end

  -- Resolve path
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir  = vim.fn.fnamemodify(current_file, ":h")

  local full_path    = current_dir .. "/" .. link_path

  -- Add .md if missing
  if not full_path:match("%.md$") then
    full_path = full_path .. ".md"
  end

  full_path = vim.fn.resolve(vim.fn.expand(full_path))

  local dir = vim.fn.fnamemodify(full_path, ":h")
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end

  vim.cmd("edit " .. vim.fn.fnameescape(full_path))
end

return M
