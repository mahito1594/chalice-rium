# frozen_string_literal: true

# 開発環境では OmniAuth のログを Rails.logger に向けてデバッグしやすくする
OmniAuth.config.logger = Rails.logger if Rails.env.development?

# 開発環境用の OmniAuth モック設定
# credentials または環境変数に x.client_id が設定されていない場合のみ有効になる
# 実 OAuth フローを確認する場合は bin/rails credentials:edit または X_CLIENT_ID 環境変数を設定する
x_client_id = Rails.application.credentials.dig(:x, :client_id) || ENV["X_CLIENT_ID"]
if Rails.env.development? && x_client_id.nil?
  OmniAuth.config.test_mode = true

  OmniAuth.config.mock_auth[:twitter2] = OmniAuth::AuthHash.new({
    provider: "twitter2",
    uid: "dev_uid_12345",
    info: {
      name: "Dev Test User",
      email: "devtest@example.com"
    }
  })
end
