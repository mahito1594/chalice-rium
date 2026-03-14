class DeviseMailer < Devise::Mailer
  layout "mailer"

  def confirmation_instructions(record, token, opts = {})
    @token = token
    devise_mail_with_layout(record, :confirmation_instructions, opts)
  end

  def reset_password_instructions(record, token, opts = {})
    @token = token
    devise_mail_with_layout(record, :reset_password_instructions, opts)
  end

  def unlock_instructions(record, token, opts = {})
    @token = token
    devise_mail_with_layout(record, :unlock_instructions, opts)
  end

  def email_changed(record, opts = {})
    devise_mail_with_layout(record, :email_changed, opts)
  end

  def password_change(record, opts = {})
    devise_mail_with_layout(record, :password_change, opts)
  end

  private

  def devise_mail_with_layout(record, action, opts = {})
    devise_mail(record, action, opts) do |format|
      format.html { render layout: "mailer" }
    end
  end
end
