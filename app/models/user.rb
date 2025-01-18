class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  has_many :dungeons, dependent: :destroy

  validates :username, presence: true, uniqueness: { case_sensitive: false },
            format: { with: /\A@[a-zA-Z0-9_]+\z/, message: "は@から始まる半角英数字とアンダースコアのみ使用できます" },
            length: { minimum: 3, maximum: 32 }
  validates :display_name, presence: true, length: { maximum: 64 }
  validates :bio, length: { maximum: 500 }
  validates :twitter_link,  allow_blank: true,
            format: { with: /\A[a-zA-Z0-9_]+\z/, message: "は有効な値を入力して下さい" }

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

  private

  def downcase_username
    self.username = username.downcase if username.present?
  end
end
