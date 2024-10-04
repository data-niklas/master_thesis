# Master thesis

## Setup
For CLI builds:
- Install Typst using your favourite package manager, or install from: https://github.com/typst/typst/releases (has direct Windows support)

## Working on the thesis
1. Either use the https://typst.app web editor. It will automatically detect the added fonts (using the same directory structure)
2. Use your favourite web editor with `Tinymist Typst`:
   1. In VSCode: Install `Tinymist Typst` from the extensions list. Has support for: live preview; clicking on the document to jump to the code
   2. In Neovim: Install https://github.com/chomosuke/typst-preview.nvim . Has support for: live preview; clicking on the document to jump to the code. Will open the preview in the browser. Set the config `dependencies_bin -> typst-preview` to `tinymist`. Install the following dependencies:
      - tinymist: https://github.com/Myriad-Dreamin/tinymist
      - websocat
3. Use your favourite web editor and build from hand:
`typst watch main.typ --font-path=assets/fonts`
Then view the document `main.pdf` using a PDF viewer that supports reloading the document (e.g. zathura on Linux)


## Requirements
### General
- `typst`

### Template
- patched `NewCMMath2-Regular` font
- Dependencies:
  - acrotastic: Acronym support; Extended by Erik Imgrund in /template/acronyms.typ
  - hydra: Proper page headings for print mode
  - equate: Multi-line equations with separate numbering
  - sourcerer: Fancy code blocks wrapping around the default highlighted text
  - codetastic: Generate a QR code to your repository
- A bibliography

### Additional
- `FiraCode` font (for terminal like blocks)
- `Virgil` font (for "hand" drawn text in SVG from excalidraw)
- Dependencies:
  - typpuccino: Styling for terminal like blocks
- For interactive table and code support:
  - Place code files in /assets/code/
  - Place table contents in /assets/code/table_name.csv
  - Store the used file names in /assets/code/index.txt and /assets/table/index.txt so that the deployed page can automatically query the list of tables and code snippets
  - Show tables and code using `csvtable` and `codefile`, pointing to the file, the function will create a table or code block and link to the interactive snippet

# Notes
- The thesis was built using Typst `v0.11.1`. `v0.13` will introduce major breaking changes, probably breaking parts of the template!
