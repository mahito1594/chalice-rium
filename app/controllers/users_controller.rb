class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[edit update destroy]
  before_action :correct_user, only: %i[edit update destroy]

  def show
    @user = User.find_by!(username: params[:username])
    @dungeons = @user.dungeons
                     .includes(:rites)
                     .order(created_at: :desc)
                     .page(params[:page])
  end

  def edit; end

  def update
    if @user.update(update_user_params)
      redirect_to user_path(@user), notice: "プロフィールが更新されました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to root_path, status: :see_other, notice: "アカウントが削除されました。"
  end

  private

  def update_user_params
    params.require(:user).permit(:display_name)
  end

  def correct_user
    @user = User.find_by!(username: params[:username])
    redirect_to(root_url, status: :see_other) if current_user != @user
  end
end
