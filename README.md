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
開発には [devcontainer](https://containers.dev/) を利用します。
詳細は各エディタ・IDE のマニュアルを参照してください

## その他
- [Favicon.io](https://favicon.io/)
    - ファビコンの作成に利用しました
