local M = {}

M.setup = function()
  local signs = {
    { name = "DiagnosticSignError", text = "" },
    { name = "DiagnosticSignWarn", text = "" },
    { name = "DiagnosticSignHint", text = "" },
    { name = "DiagnosticSignInfo", text = "" },
  }

  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
  end

  local config = {
    virtual_text = false,
    signs = {
      active = signs,
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focusable = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = ""
    },
  }

  vim.diagnostic.config(config)

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded"
  })

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded"
  })
end

local lsp_keymaps = function(bufnr)
  local opts = { noremap = true, silent = true }
  local set_keymap = vim.api.nvim_buf_set_keymap
  -- Go To Declaration
  set_keymap(bufnr, "n", "gD", "<cmd> lua vim.lsp.buf.declaration()<CR>", opts)
  -- Go To Definition
  set_keymap(bufnr, "n", "gd", "<cmd> lua vim.lsp.buf.definition()<CR>", opts)
  -- Hover
  set_keymap(bufnr, "n", "K", "<cmd> lua vim.lsp.buf.hover()<CR>", opts)
  -- Go To Implementation
  set_keymap(bufnr, "n", "gi", "<cmd> lua vim.lsp.buf.implementation()<CR>", opts)
  -- Display Signature Help
  set_keymap(bufnr, "n", "<C-k>", "<cmd> lua vim.lsp.buf.signature_help()<CR>", opts)
  -- References
  set_keymap(bufnr, "n", "gr", "<cmd> lua vim.lsp.buf.references()<CR>", opts)
  -- Rename Symbol
  -- set_keymap(bufnr, "n", "<leader>rn", "<cmd> lua vim.lsp.buf.rename()<CR>", opts)
  -- Code Action
  set_keymap(bufnr, "n", "<leader>ca", "<cmd> lua vim.lsp.buf.code_action()<CR>", opts)
  -- [[ set_keymap(bufnr, "n", "<leader>f", "<cmd> lua vim.lsp.diagnostic.open_float()<CR>", opts) ]]
  set_keymap(bufnr, "n", "[g", '<cmd> lua vim.lsp.diagnostic.goto_prev({ border = "rounded" })<CR>', opts)
  set_keymap(bufnr, "n", "]g", '<cmd> lua vim.lsp.diagnostic.goto_next({ border = "rounded" })<CR>', opts)
  set_keymap(bufnr, "n", "gl", '<cmd> lua vim.lsp.diagnostic.show_line_diagnostics({ border = "rounded" })<CR>', opts)
  set_keymap(bufnr, "n", "<leader>q", '<cmd> lua vim.diagnostic.setloclist()<CR>', opts)

  vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]
end

-- it's highlighting a symbol under the cursor
local function lsp_highlight_document(client)
  -- Set autocommands conditional on server capabilities
  if client.resolved_capabilities.document_highlight then
    vim.api.nvim_exec(
      [[
        augroup lsp_document_highlight
          autocmd! * <buffer>
          autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
          autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
        augroup END
      ]],
        false
    )
  end
end

local on_attach = function(client, bufnr)
  --[[ lsp_keymaps(bufnr)
  lsp_highlight_document(client) ]]
  print "on_attach"

end

require('lspconfig')['tsserver'].setup{
    on_attach = on_attach,
}

local capabilities = vim.lsp.protocol.make_client_capabilities()

-- checks that 'cmd_nvim_lsp' is available
local status_ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if not status_ok then
  return
end

M.capabilities = cmp_nvim_lsp.update_capabilities(capabilities)

return M

