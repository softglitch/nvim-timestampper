# nvim-timestampper

A Neovim plugin to easily convert various timestamp formats (Epoch, ISO 8601, Compact) into a human-readable `YYYY-MM-DD:HH-MM-SS` format directly within your buffer.

## Features

- **Epoch Detection**: Automatically identifies 10-digit epoch timestamps (seconds) and 13-digit epoch timestamps (milliseconds).
- **ISO 8601 Support**: Converts `YYYY-MM-DDTHH:MM:SS` format.
- **Compact Format Support**: Converts `YYYYMMDD HH:MM:SS` format.
- **Configurable**: Customize the output format and enable/disable specific detectors.

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'softglitch/nvim-timestampper',
  config = true, -- Runs setup() with default options
}
```

## Usage

Open any file containing timestamps (e.g., log files) and run:

```vim
:TimestampConvert
```

### Example

**Before:**
```
1768546642: Connection established
20260116 08:57:22.857 Error occurred
2026-01-16T07:14:05 Server start
```

**After:**
```
2026-01-16:07-17-22: Connection established
2026-01-16:08-57-22.857 Error occurred
2026-01-16:07-14-05 Server start
```

## Configuration

You can customize the behavior by passing options to the `setup` function.

```lua
require('timestampper').setup({
  -- Target format (follows Lua os.date format)
  -- Default: "%Y-%m-%d:%H-%M-%S"
  format = "%Y-%m-%d %H:%M:%S",

  -- Enable or disable specific detectors
  detectors = {
    epoch = true,    -- 10-digit timestamps (seconds)
    epoch_ms = true, -- 13-digit timestamps (milliseconds)
    compact = true,  -- YYYYMMDD HH:MM:SS
    iso = true,      -- YYYY-MM-DDTHH:MM:SS
  }
})
```

## License

GLWTS
