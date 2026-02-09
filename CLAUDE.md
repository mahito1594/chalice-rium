# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

Bloodborne の聖杯ダンジョン用メモアプリ（Ruby on Rails 8.0 + PostgreSQL）

## 開発コマンド

### 開発サーバーの起動
```bash
bin/dev  # foreman で Rails サーバー + Tailwind CSS watch を同時起動
```

### テストの実行
```bash
bin/rails test                              # 全テスト実行
bin/rails test test/models/user_test.rb     # 単一ファイル実行
bin/rails test test/models/user_test.rb:10  # 特定行のテスト実行
RAILS_ENV=test COVERAGE=1 bin/rails test    # カバレッジ取得（coverage/index.html に出力）
```

### Lint とセキュリティチェック
```bash
bin/rubocop           # RuboCop（rubocop-rails-omakase スタイル）
bin/brakeman          # セキュリティ脆弱性チェック
```

### データベース
```bash
bin/rails db:prepare  # DB作成とマイグレーション
bin/rails db:seed     # シードデータ投入
```

### セットアップ
```bash
bin/setup             # 依存関係インストール + DB準備 + サーバー起動
bin/setup --skip-server  # サーバー起動なしでセットアップ
```

## アーキテクチャ

### ドメインモデル
- **User**: Devise による認証。username（@から始まる識別子）と display_name を持つ
- **Dungeon**: 聖杯ダンジョン。glyph（8文字のコード）、depth（1-5）、area（pthumeru/loran/isz/hintertomb）
- **Layer**: ダンジョンの階層（3-4層）。各階層にボス名を記録
- **Rite**: 追加儀法（オプショナルな修飾子）
- **DungeonRite**: Dungeon と Rite の多対多中間テーブル

### 主要な関係性
```
User has_many Dungeons
Dungeon has_many Layers (3-4層、レベル順)
Dungeon has_many Rites through DungeonRites
```

### バリデーションルール
- Dungeon の area と depth には組み合わせ制約がある（例: Isz は depth 5 のみ）
- sinister rite は他の rite と併用不可
- ユーザー名は `@[a-zA-Z0-9_]+` 形式

### フロントエンド
- Tailwind CSS 4.x + Hotwire (Turbo/Stimulus)
- ビューテンプレートは ERB
- ViewComponent でフォーム・UI要素をコンポーネント化
  - `Form::FieldComponent`, `Form::CheckboxComponent`
  - `Ui::CardComponent`, `Ui::BadgeComponent`, `Ui::ButtonComponent`

### 開発環境
- mise でツールバージョン管理（Ruby は `.ruby-version` を参照）
- PostgreSQL は Docker Compose（`compose.yaml`）で起動（ポート 5432）
- `mise run setup` でセットアップ、`mise run dev` で開発サーバー起動
- ポート 3000 が Rails サーバー
