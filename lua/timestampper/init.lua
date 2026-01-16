local M = {}

-- Default configuration
M.config = {
    -- Target format for os.date
    format = "%Y-%m-%d:%H-%M-%S",
    -- Enable/disable specific detections
    detectors = {
        epoch = true,
        epoch_ms = true,
        compact = true,
        iso = true,
    }
}

---Converts an epoch string to the configured format
---@param str string The epoch timestamp string
---@return string The formatted date string or original string if invalid
local function convert_epoch(str)
    local epoch = tonumber(str)
    -- Check for reasonable epoch range (approx year 2000 to 2038)
    -- 946684800 is year 2000
    -- 2147483647 is max 32-bit integer (Year 2038)
    -- Extended slightly for future proofing/past data
    if epoch and epoch > 900000000 and epoch < 2200000000 then
        return os.date(M.config.format, epoch)
    end
    return str
end

---Converts a millisecond epoch string to the configured format
---@param str string The 13-digit epoch timestamp string
---@return string The formatted date string with milliseconds
local function convert_epoch_ms(str)
    local epoch_s = tonumber(str:sub(1, 10))
    local ms = str:sub(11, 13)

    if epoch_s and epoch_s > 900000000 and epoch_s < 2200000000 then
        return os.date(M.config.format, epoch_s) .. "." .. ms
    end
    return str
end

---Process a single line and replace timestamps
---@param line string
---@return string
function M.process_line(line)
    if M.config.detectors.compact then
        -- 1. YYYYMMDD HH:MM:SS(.mmm) -> YYYY-MM-DD:HH-MM-SS(.mmm)
        -- Handles "20260116 08:57:22.857"
        line = line:gsub("(%d%d%d%d)(%d%d)(%d%d)%s+(%d%d):(%d%d):(%d%d)", "%1-%2-%3:%4-%5-%6")
    end

    if M.config.detectors.iso then
        -- 2. ISO like YYYY-MM-DDTHH:MM:SS -> YYYY-MM-DD:HH-MM-SS
        -- Handles "2026-01-16T07:07:28"
        line = line:gsub("(%d%d%d%d)-(%d%d)-(%d%d)[T ](%d%d):(%d%d):(%d%d)", "%1-%2-%3:%4-%5-%6")
    end

    if M.config.detectors.epoch_ms then
        -- 3. Epoch Milliseconds (13 digits)
        -- Using %f[%d] frontier pattern to match whole numbers
        line = line:gsub("%f[%d]%d%d%d%d%d%d%d%d%d%d%d%d%d%f[%D]", convert_epoch_ms)
    end

    if M.config.detectors.epoch then
        -- 4. Epoch (10 digits)
        -- Using %f[%d] frontier pattern to match whole numbers
        line = line:gsub("%f[%d]%d%d%d%d%d%d%d%d%d%d%f[%D]", convert_epoch)
    end

    return line
end

---Main conversion function
function M.convert()
    local buf = vim.api.nvim_get_current_buf()
    local line_count = vim.api.nvim_buf_line_count(buf)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, line_count, false)

    local new_lines = {}
    for _, line in ipairs(lines) do
        table.insert(new_lines, M.process_line(line))
    end

    vim.api.nvim_buf_set_lines(buf, 0, line_count, false, new_lines)
    vim.notify(string.format("Timestamps converted in %d lines", line_count), vim.log.levels.INFO)
end

---Setup function for configuration
---@param opts table|nil User configuration
function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

return M
