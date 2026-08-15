# template plugin

テンプレートから plugin を作成したら、Lua module 名を指定して placeholder を置換できます。
`origin` が `plugin-template.nvim` を指している場合は、repository URL も `<PLUGIN_NAME>.nvim` に更新されます。

```sh
make rename PLUGIN_NAME=my_plugin
```

```lua
lua require('my_plugin').hello()
```
