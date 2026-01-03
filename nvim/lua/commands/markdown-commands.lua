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
      return path
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

  vim.fn.system(cmd)
  vim.notify("Opened " .. path, vim.log.levels.INFO)
end

vim.keymap.set("n", "gx", M.open_media, { desc = "Open media externally", buffer = true })

function M.follow_link()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]

  local patterns = {
    "%[%[(.-)%]%]",   -- [[path]]
    "%[.-%]%((.-)%)", -- [text](path)
  }

  for _, pattern in ipairs(patterns) do
    for path in line:gmatch(pattern) do
      local current_file = vim.api.nvim_buf_get_name(0)
      local current_dir = vim.fn.fnamemodify(current_file, ":h")
      local full_path = current_dir .. "/" .. path

      full_path = vim.fn.resolve(vim.fn.expand(full_path))

      if vim.fn.filereadable(full_path) == 1 then
        vim.cmd("edit " .. vim.fn.fnameescape(full_path))
        return
      else
        vim.notify("File not found: " .. full_path, vim.log.levels.WARN)
        return
      end
    end
  end
  vim.notify("No link found under cursor", vim.log.levels.WARN)
end

vim.keymap.set("n", "gf", M.follow_link, { desc = "Follow markdown link", buffer = true })

return M
