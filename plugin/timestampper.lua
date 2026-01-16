if vim.g.loaded_timestampper == 1 then
  return
end
vim.g.loaded_timestampper = 1

vim.api.nvim_create_user_command('TimestampConvert', function()
  require('timestampper').convert()
end, {})
