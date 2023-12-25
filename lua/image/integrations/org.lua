local document = require("image/utils/document")

local function findMatches(input)
  local pattern = "%[%[([^%[%]]-)%]%]"
  local matches = {}
  for start_col, end_col, match in input:gmatch("()" .. pattern .. "()") do
    table.insert(matches, { start_col, end_col, match })
  end
  return matches
end

local function findPatternOccurrences()
  local total_lines = vim.fn.line("$")
  local occurrences = {}
  for start_row = 1, total_lines do
    local line = vim.fn.getline(start_row)
    local start_col = nil
    local end_col = nil
    local url = nil

    local matches = findMatches(line)
    local first_match = matches[1]
    if first_match ~= nil then
      start_col = first_match[1]
      url = first_match[2]
      end_col = first_match[3]
    end

    if start_col ~= nil then
      local end_row = start_row
      local range = { start_row = tonumber(start_row) - 1, start_col = start_col, end_row = tonumber(end_row) - 1, end_col = end_col }
      table.insert(occurrences, {
        node = nil,
        range = range,
        url = url,
      })
    end
  end

  return occurrences
end

return document.create_document_integration({
  name = "org",
  -- debug = true,
  default_options = {
    clear_in_insert_mode = false,
    download_remote_images = true,
    only_render_image_at_cursor = false,
    filetypes = { "org" },
  },
  query_buffer_images = function(buffer)
    local images = findPatternOccurrences()
    return images
  end,
})
