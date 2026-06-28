# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  protected

  # UC3: X のみユーザーは current_password なしで email/password を設定できる
  def update_resource(resource, params)
    if resource.x_only?
      params.delete(:current_password)
      resource.update(params)
    else
      super
    end
  end
end
