# frozen_string_literal: true

class Settings::XConnectionsController < ApplicationController
  before_action :authenticate_user!

  def destroy
    unless current_user.can_unlink_x?
      redirect_to edit_user_path(current_user),
                  alert: "X 連携を解除するには、メールアドレスとパスワードの両方が設定されている必要があります。"
      return
    end

    current_user.update!(provider: nil, uid: nil)
    redirect_to edit_user_path(current_user), notice: "X 連携を解除しました。"
  end
end
