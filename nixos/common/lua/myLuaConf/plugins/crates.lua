local crates  = require('crates')
crates.setup({
    smart_insert = true,
    insert_closing_quote = true,
    avoid_prerelease = true,
})
-- require('cmp').setup.buffer({
  -- sources = { { name = "crates" }}
-- })
crates.show()
