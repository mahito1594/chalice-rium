class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[edit update destroy]
  before_action :correct_user, only: %i[edit update destroy]

  def show
    @user = User.find_by(username: params[:username])
    if @user.nil?
      # Todo: should return 404 not found
      redirect_to root_path
    end
  end

  def edit; end

  def update
    if @user.update(update_user_params)
      redirect_to user_path(@user), notice: "Profile was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # TODO
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
