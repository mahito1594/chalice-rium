# CLAUDE.md

Bloodborne の聖杯ダンジョン用メモアプリ。Rails 8.1 + SQLite3 で、fly.io にデプロイしている。DB はファイルで完結するため、ローカル開発に外部サービスは要らない。

## ドメイン用語

- **glyph**: 聖杯ダンジョンを共有する 8 文字の英数字コード。小文字に正規化して保存する
- **area**: pthumeru / loran / isz / hintertomb。area ごとに取り得る depth（1–5）が決まっている（例: Isz は depth 5 のみ）
- **Layer**: ダンジョンの階層。1 ダンジョンに 3–4 層あり、各層のボス名を記録する
- **Rite**: 追加儀法（オプション）。sinister は他の rite と併用できない
- **username**: `@` から始まる識別子。表示名（display_name）とは別

## 開発コマンド

- `mise run setup` / `mise run dev`: 初回セットアップ / 開発サーバー（Rails + Tailwind watcher）
- `bin/rails test [path[:line]]`: テスト。system test は含まれないので、UI を変えたら `bin/rails test:system` も実行する（CI は両方を実行する）
- `mise run test`: カバレッジ付きの全テスト（`coverage/index.html`）
- `bin/rubocop` / `bin/brakeman`: CI と同じ lint とセキュリティチェック。コミット前に通す

## バグ修正は TDD で

リグレッションテストが本当にそのバグを捉えていることを確かめるため、次の順で進める。

1. バグを再現するテストを書く
2. 修正を適用する前に、そのテストが失敗することを確認する
3. 修正を適用し、テストが通ることを確認する
4. テストと修正を同じコミットに含める

## コミットと PR

- Conventional Commits 形式（`feat:` / `fix:` / `chore:` など）。1 コミットには 1 つの変更
- PR には利用者から見た影響と、ローカルで実行した検証手順を書く。UI の変更にはスクリーンショットを添え、DB・認証・設定の変更は明記する

## ハマりどころ

- Devise の `:confirmable` が有効なので、ユーザー登録後にメール確認が要る。開発環境では http://localhost:3000/letter_opener で確認メールを読める
