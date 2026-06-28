# frozen_string_literal: true

class Users::OmniauthSetupsController < ApplicationController
  before_action :redirect_if_no_omniauth_session
  before_action :redirect_if_signed_in

  def new
    @user = User.new(display_name: omniauth_data.dig("info", "name"))
  end

  def create
    @user = User.new(
      provider: omniauth_data["provider"],
      uid: omniauth_data["uid"],
      email: omniauth_data.dig("info", "email").presence,
      display_name: user_params[:display_name],
      username: user_params[:username]
    )
    @user.skip_confirmation!

    if @user.save
      session.delete(:omniauth_auth)
      sign_in @user
      redirect_to root_path, notice: "X アカウントで登録しました。ようこそ！"
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def redirect_if_no_omniauth_session
    return if session[:omniauth_auth].present?
    redirect_to new_user_registration_path,
                alert: "セッションが切れました。もう一度お試しください。"
  end

  def redirect_if_signed_in
    redirect_to root_path if user_signed_in?
  end

  def omniauth_data
    session[:omniauth_auth] || {}
  end

  def user_params
    params.require(:user).permit(:username, :display_name)
  end
end
