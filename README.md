# template plugin

テンプレートから plugin を作成したら、Lua module 名を指定して placeholder を置換できます。

```sh
make rename PLUGIN_NAME=my_plugin
```

```lua
lua require('my_plugin').hello()
```
