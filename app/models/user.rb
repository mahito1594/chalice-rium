class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :username, presence: true, uniqueness: { case_sensitive: false },
            format: { with: /\A@[a-zA-Z0-9_]+\z/, message: "は@から始まる半角英数字とアンダースコアのみ使用できます" },
            length: { minimum: 3, maximum: 32 }
  validates :display_name, presence: true, length: { maximum: 32 }

  before_save :downcase_username

  def to_param
    username
  end
  private

  def downcase_username
    self.username = username.downcase if username.present?
  end
end
