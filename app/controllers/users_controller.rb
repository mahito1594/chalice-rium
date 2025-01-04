class UsersController < ApplicationController
  def show
    @user = User.find_by(username: params[:username])
    if @user.nil?
      # Todo: should return 404 not found
      redirect_to root_path
    end
  end

  def edit
  end

  def update
  end

  private

  def user_params
    params.require(:user).permit(:email, :username, :display_name)
  end
end
