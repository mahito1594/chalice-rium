class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :omniauthable, omniauth_providers: [ :twitter2 ]

  has_many :dungeons, dependent: :destroy

  validates :username, presence: true, uniqueness: { case_sensitive: false },
            format: { with: /\A@[a-zA-Z0-9_]+\z/, message: "は@から始まる半角英数字とアンダースコアのみ使用できます" },
            length: { minimum: 3, maximum: 32 }
  validates :display_name, presence: true, length: { maximum: 64 }
  validates :bio, length: { maximum: 500 }
  validates :twitter_link, allow_blank: true,
            format: { with: /\A[a-zA-Z0-9_]+\z/, message: "は有効な値を入力して下さい" }
  validates :uid, uniqueness: { scope: :provider }, allow_nil: true

  before_validation { self.bio = bio&.strip }
  before_save :downcase_username

  def to_param
    username
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if conditions[:username].nil?
      where(conditions).first
    else
      where(username: conditions[:username]).first
    end
  end

  def self.from_omniauth(auth)
    find_by(provider: auth.provider.to_s, uid: auth.uid.to_s)
  end

  def x_only?
    provider.present? && encrypted_password.blank?
  end

  def email_required?
    !x_only?
  end

  def password_required?
    return false if x_only?
    super
  end

  def can_unlink_x?
    email.present? && encrypted_password.present?
  end

  def send_password_change_notification?
    # X-only users have no email yet when setting email+password simultaneously (UC3).
    # email goes to unconfirmed_email at that point, so email is still nil here.
    email.present? && super
  end

  private

  def downcase_username
    self.username = username.downcase if username.present?
  end
end
