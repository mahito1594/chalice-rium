class Dungeon < ApplicationRecord
  belongs_to :user
  has_many :layers, dependent: :destroy
  has_many :dungeon_rites, dependent: :destroy
  has_many :rites, through: :dungeon_rites

  validates :glyph, presence: true, length: { is: 8 }, format: { with: /\A[a-z0-9]+\z/ }
  validates :depth, presence: true, inclusion: { in: 1..5 }
  validates :area, presence: true
  validates :comment, length: { maximum: 255 }

  enum :area, {
    pthumeru: 0,
    loran: 1,
    isz: 2,
    hintertomb: 3
  }
end
