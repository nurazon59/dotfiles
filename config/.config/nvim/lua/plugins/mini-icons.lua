return {
  "nvim-mini/mini.icons",
  opts = function(_, opts)
    opts = opts or {}
    opts.extension = opts.extension or {}
    opts.file = opts.file or {}
    opts.filetype = opts.filetype or {}

    opts.extension.go = { glyph = "" }
    opts.extension.ts = { glyph = "" }
    opts.extension.tsx = { glyph = "" }
    opts.extension.test = { glyph = "" }
    opts.extension.spec = { glyph = "" }
    opts.extension["test.js"] = { glyph = "" }
    opts.extension["test.jsx"] = { glyph = "" }
    opts.extension["test.ts"] = { glyph = "" }
    opts.extension["test.tsx"] = { glyph = "" }
    opts.extension["spec.js"] = { glyph = "" }
    opts.extension["spec.jsx"] = { glyph = "" }
    opts.extension["spec.ts"] = { glyph = "" }
    opts.extension["spec.tsx"] = { glyph = "" }
    opts.filetype.go = { glyph = "" }
    opts.filetype.typescript = { glyph = "" }
    opts.filetype.typescriptreact = { glyph = "" }
    opts.file["go.mod"] = { glyph = "" }
    opts.file["go.sum"] = { glyph = "" }
    opts.file["go.work"] = { glyph = "" }
  end,
}
