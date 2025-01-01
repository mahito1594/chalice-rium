class Dungeon < ApplicationRecord
  belongs_to :user
  has_many :layers, dependent: :destroy
  has_many :dungeon_rites, dependent: :destroy
  has_many :rites, through: :dungeon_rites
  accepts_nested_attributes_for :layers
  attr_accessor :rite_ids

  validates :glyph, presence: true, uniqueness: { case_sensitive: false },
            length: { is: 8 }, format: { with: /\A[a-z0-9]+\z/ }
  validates :depth, presence: true, inclusion: { in: 1..5 }
  validates :area, presence: true
  validates :comment, length: { maximum: 255 }
  validates :layers, length: { minimum: 3, maximum: 4,
                               message: "must have 3 or 4 layers" }

  before_save :downcase_glyph

  enum :area, {
    pthumeru: 0,
    loran: 1,
    isz: 2,
    hintertomb: 3
  }

  private

  def downcase_glyph
    self.glyph = glyph.downcase
  end
end
