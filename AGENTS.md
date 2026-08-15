# AGENTS.md

## プロジェクト概要

このリポジトリは Neovim 用 Lua プラグインのテンプレートです。初期状態では Lua モジュール名が `sample` になっています。

## ディレクトリ構成

- `lua/sample/`: プラグイン本体。テンプレートから作成した後は `lua/<PLUGIN_NAME>/` にリネームされます。
- `dev/init.lua`: 開発用 Neovim 設定。リポジトリを runtimepath に追加してプラグインを読み込みます。
- `scripts/rename-plugin.sh`: プレースホルダー名の置換とディレクトリ・origin URL の更新を行います。
- `Makefile`: 開発、リネーム、整形、lint の入口です。

## 開発ルール

- Lua の変更は `lua/<module-name>/` に置き、公開 API は既存の `setup` / `hello` パターンと整合させます。
- Lua の公開 API、設定値、モジュール内部の主要なデータ構造には Lua annotation（`---@param`、`---@return`、`---@class` など）を付け、型と意図を明記します。
- Lua は StyLua、Markdown・JSON・TOML などは dprint の設定に従います。既存の引用符、インデント、改行形式を尊重してください。
- テンプレートのプレースホルダー `sample` を変更する場合は、手作業で一部だけ置換せず `make rename PLUGIN_NAME=<lowercase_lua_module_name>` を使います。
- `make rename` は `origin` URL も更新するため、実行前に対象の remote と作業ツリーを確認してください。
- 秘密情報やローカル環境固有の設定をコミットしないでください。

## よく使うコマンド

```sh
# 開発用 Neovim を起動
make nvim

# テンプレートをプラグイン名に変換
make rename PLUGIN_NAME=my_plugin

# Lua と各種ドキュメントを整形（ファイルを変更します）
make fmt

# typo 検査
make lint

# lint と整形を実行
make check
```

現時点で自動テスト suite はありません。コード変更後は少なくとも `make lint` と `make fmt` を実行し、Lua の変更は `make nvim` で手動確認してください。
