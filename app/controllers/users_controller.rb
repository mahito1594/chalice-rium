class UsersController < ApplicationController
  def show
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
