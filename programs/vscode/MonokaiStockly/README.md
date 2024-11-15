# README

## How to use

**Step 1:** Link extension in your vscode
- Go to `~/.vscode/extensions`
- If you have the Main repo on your computer, symlink the extension with:
```
ln -s ~/Stockly/Main/dev_tools/MonokaiStockly stockly.monokai-stockly-1.0.0
```
*WARNING*: You might need to replace `~/Stockly/Main` by the path to your Main repo.
- If you **do not** have the Main repo on your computer, download the extension with
```
svn checkout https://github.com/Stockly/Main/trunk/dev_tools/MonokaiStockly stockly.monokai-stockly-1.0.0
```
- In any VS Code window, reload it. (ctrl + shift + p then `Developer: Reload Window`)

**Step 2:** Select theme Monokai Stockly
- Go to your VS Code settings (ctrl + ,)
- Search for setting `Workbench: Color Theme`
- Select `Monokai Stockly`

**Step 3:** Activate semantic highlighting for Rust
This theme semantic highlighting was only tested with Rust. Therefore is it deactivated by default
and needs to be activated specially for rust.
- Go to settings (ctrl + ,)
- Open the file settings (icon 📄 on the upper left)
- Add:
```json
"[rust]": {
	"editor.semanticHighlighting.enabled": true
}
```

You're good to go 🎉

## Explanation

### Booting lag
Semantic highlighting takes a while to kick in. Before it kicks in, VSCode uses syntaxic
highlighting. Therefore, this theme tries to make both highlighting as close as possible. Basically,
semantic highlighting will almost only add more information, such as turning variables in italic if mutable.

### Concepts
**Structure:**
Structure tokens are typically keywords and symbols. They can be of two colors, red to provide a
good visibility of the global structure or light grey because they should not be emphasized. For
example `{` are light grey because scopes are more visible with indentation than with the
character `{`.

**Namespaces & Modules**: Peach

**Structs & Enums:**
Basic structs and enums are blue, type aliases are blue and italic. Variants are purple and italic.
Notably, primitive types are blue and italic

**Variables:**
Variables are orange, if they are mutable they are orange and italic. The next feature would be for
them to be bold if they are not a reference but rust-analyzer doesn't offer the feature yet.

**Traits**: Purple

**Lifetimes:** Purple and italic

**Functions & Macros**: Green

**Primitives:**
Numbers and booleans are purple.
Strings are yellow.

**Format Specifiers:** Green


# Known Bugs
## static refs
Static refs are bold blue when they should have been closer to constants and therefore bold purple.
The problem here is that the sematic analysis tags is as a `struct`, `struct` is not present in the
`semanticTokens` so the mapping adds the textmate scope `entity.name.type.struct.rust` which has
color blue. It keeps the bold from the first syntaxic analysis that identified it as a constant.
