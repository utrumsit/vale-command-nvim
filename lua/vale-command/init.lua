vim.api.nvim_create_user_command("Vale", function()
  local file = vim.api.nvim_buf_get_name(0)
  local output = vim.fn.system("vale --output=JSON " .. file)
  local results, err = vim.fn.json_decode(output)

  if err then
    print("Error parsing Vale output: " .. err)
    return
  end

  local qf_list = {}
  for filename, errors in pairs(results) do
    for _, error in ipairs(errors) do
      table.insert(qf_list, {
        filename = filename,
        lnum = error.Line,
        col = error.Span[1],
        text = error.Message,
        type = string.sub(error.Severity, 1, 1):upper(),
      })
    end
  end

  if #qf_list > 0 then
    vim.fn.setqflist(qf_list)
    vim.cmd("copen")
  else
    print("No issues found by Vale.")
  end
end, {})