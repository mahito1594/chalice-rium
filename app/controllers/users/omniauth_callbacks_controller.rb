# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def twitter2
    auth = request.env["omniauth.auth"]

    if user_signed_in?
      handle_connect(auth)
    else
      handle_auth(auth)
    end
  end

  def failure
    redirect_to new_user_session_path, alert: "X 認証に失敗しました。もう一度お試しください。"
  end

  private

  def handle_auth(auth)
    user = User.from_omniauth(auth)

    if user
      # 既存の X ユーザーとしてログイン
      set_flash_message(:notice, :success, kind: "X") if is_navigational_format?
      sign_in_and_redirect user, event: :authentication
    else
      # email 衝突チェック（自動マージはアカウント乗っ取りリスクがあるため行わない）
      if auth.info.email.present? && User.find_by(email: auth.info.email)
        redirect_to new_user_session_path,
                    alert: "このメールアドレスはすでに別のアカウントに登録されています。" \
                           "そのアカウントでログイン後、プロフィール設定から X 連携を行ってください。"
        return
      end

      # 新規ユーザー: セッションに保存して username 設定フォームへ
      store_omniauth_in_session(auth)
      redirect_to new_omniauth_setup_path
    end
  end

  def handle_connect(auth)
    # UC2: ログイン済みユーザーへの X 連携
    existing = User.find_by(provider: auth.provider.to_s, uid: auth.uid.to_s)

    if existing
      message = existing == current_user ? "この X アカウントはすでに連携済みです。" \
                                         : "この X アカウントはすでに別のアカウントに連携されています。"
      redirect_to edit_user_path(current_user), notice: message
      return
    end

    current_user.update(provider: auth.provider.to_s, uid: auth.uid.to_s)
    redirect_to edit_user_path(current_user), notice: "X アカウントを連携しました。"
  rescue ActiveRecord::RecordNotUnique
    redirect_to edit_user_path(current_user),
                alert: "この X アカウントはすでに別のアカウントに連携されています。"
  end

  def store_omniauth_in_session(auth)
    session[:omniauth_auth] = {
      "provider" => auth.provider.to_s,
      "uid" => auth.uid.to_s,
      "info" => {
        "name" => auth.info.name,
        "email" => auth.info.email
      }
    }
  end
end
