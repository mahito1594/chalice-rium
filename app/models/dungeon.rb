class Dungeon < ApplicationRecord
  belongs_to :user
  has_many :layers, -> { order(level: :asc) }, dependent: :destroy
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

  after_initialize :ensure_required_layers, if: :new_record?

  before_save :downcase_glyph
  before_save :remove_empty_fourth_layer

  enum :area, {
    pthumeru: 0,
    loran: 1,
    isz: 2,
    hintertomb: 3
  }

  def prepare_for_form
    ensure_forth_layer
    self.rite_ids = rites.map(&:id)
    self
  end

  private

  def downcase_glyph
    self.glyph = glyph.downcase
  end

  def remove_empty_fourth_layer
    fourth_layer = layers.find { |layer| layer.level == 4 }
    fourth_layer&.mark_for_destruction if fourth_layer&.boss_name.blank?
  end

  def ensure_required_layers
    3.times do |i|
      layers.build(level: i + 1) unless layers.any? { |l| l.level == i + 1 }
    end
  end

  def ensure_forth_layer
    layers.build(level: 4) unless layers.any? { |l| l.level == 4 }
  end
end
