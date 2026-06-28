# frozen_string_literal: true

# 開発環境では OmniAuth のログを Rails.logger に向けてデバッグしやすくする
OmniAuth.config.logger = Rails.logger if Rails.env.development?

# 開発環境用の OmniAuth モック設定
# credentials に x.client_id が設定されていない場合のみ有効になる
# 実 OAuth フローを確認する場合は bin/rails credentials:edit で x.client_id / x.client_secret を設定する
if Rails.env.development? && Rails.application.credentials.dig(:x, :client_id).nil?
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
