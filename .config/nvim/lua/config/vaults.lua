local M = {}

-- Define Obsidian vaults here. Add more as needed.
M.vaults = {
  {
    name = "work",
    path = "~/vaults/work",
  },
}

---Check if current working directory is inside any vault
---@return boolean
function M.in_any_vault()
  local cwd = vim.fn.getcwd()
  for _, vault in ipairs(M.vaults) do
    if vim.startswith(cwd, vim.fn.expand(vault.path)) then
      return true
    end
  end
  return false
end

---Get expanded absolute paths of all vaults
---@return string[]
function M.get_paths()
  local paths = {}
  for _, vault in ipairs(M.vaults) do
    table.insert(paths, vim.fn.expand(vault.path))
  end
  return paths
end

return M
