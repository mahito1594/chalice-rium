require "test_helper"

class DeviseMailerTest < ActionMailer::TestCase
  test "confirmation instructions renders styled html email" do
    user = users(:willem)

    mail = Devise::Mailer.confirmation_instructions(user, "confirmation-token")
    body = html_body(mail)

    assert_equal [ user.email ], mail.to
    assert_includes body, "<!DOCTYPE html>"
    assert_includes body, ".email-shell"
    assert_includes body, "class=\"email-card\""
    assert_includes body, "Welcome #{user.username}!"
    # ActionMailer::TestCase does not expose Devise route helpers here, so assert against the rendered absolute URL.
    assert_includes body, "http://example.com/users/confirmation?confirmation_token=confirmation-token"
    assert_includes body, "email-button"
  end

  test "reset password instructions renders styled call to action" do
    user = users(:willem)

    mail = Devise::Mailer.reset_password_instructions(user, "reset-token")
    body = html_body(mail)

    assert_includes body, "Hello #{user.username}!"
    assert_includes body, "パスワードを変更する"
    # Assert the rendered URL directly for the same reason as the confirmation mail test above.
    assert_includes body, "http://example.com/users/password/edit?reset_password_token=reset-token"
  end

  test "password change renders styled notification email" do
    user = users(:willem)

    mail = Devise::Mailer.password_change(user)
    body = html_body(mail)

    assert_includes body, "<div class=\"email-shell\">"
    assert_includes body, "Chalice-rium"
    assert_includes body, "あなたのパスワードが変更されたためメールでお知らせします。"
    assert_includes body, "このリクエストをしていない場合は、お問い合わせください。"
  end

  test "email changed renders pending change details" do
    user = users(:willem)
    user.unconfirmed_email = "updated@example.com"

    mail = Devise::Mailer.email_changed(user)
    body = html_body(mail)

    assert_includes body, "メールアドレスの変更がリクエストされました。"
    assert_includes body, "updated@example.com"
    assert_includes body, "この変更に心当たりがない場合は、アカウント設定を確認してください。"
  end

  private

  def html_body(mail)
    mail.html_part ? mail.html_part.body.decoded : mail.body.decoded
  end
end
