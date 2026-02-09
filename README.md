# Chalice-rium

## 概要
[Bloodborne](https://www.playstation.com/ja-jp/games/bloodborne/) の聖杯ダンジョン用メモアプリです。

### 機能

#### ダンジョン管理
- [X] ユーザーの CRUD
- [X] 聖杯ダンジョンの CRUD
- [X] ユーザーが作成した聖杯ダンジョン一覧の表示
- [ ] 聖杯ダンジョンの検索
    - [x] 聖杯文字による検索
    - [x] 深度によるフィルタリング
    - [x] 区画によるフィルタリング
    - [x] 追加儀法によるフィルタリング
    - [ ] 登録日時による並び替え表示
- [ ] 聖杯ダンジョンのお気に入り登録機能
- [ ] 聖杯ダンジョンへのコメント投稿


## 技術スタック

### バックエンド
- Ruby on Rails
- PostgreSQL

### フロントエンド
- [Tailwind CSS](https://tailwindcss.com/)
- [Meraki UI](https://merakiui.com/)
- [Tabler Icons](https://tabler.io/icons)

### 認証
- [Devise](https://rubygems.org/gems/devise)

### テスト
- minitest

## 開発

### 前提条件
- [mise](https://mise.jdx.dev/)
- [Docker](https://www.docker.com/)（PostgreSQL コンテナ用）

### セットアップ
```bash
mise run setup   # DB コンテナ起動 + 依存関係インストール + DB 準備
```

### 開発サーバーの起動
```bash
mise run dev     # DB コンテナ起動 + Rails サーバー + Tailwind CSS watch
```

### テスト
```bash
mise run test    # DB コンテナ起動 + テスト実行（カバレッジ付き）
```

## その他
- [Favicon.io](https://favicon.io/)
    - ファビコンの作成に利用しました
