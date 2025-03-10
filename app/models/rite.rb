class Rite < ApplicationRecord
  has_many :dungeon_rites
  has_many :dungeons, through: :dungeon_rites

  validates :name, presence: true

  enum :name, {
    fetid: 0,
    rotted: 1,
    cursed: 2,
    sinister: 3
  }

  def translated_name
    I18n.t("enums.rite.name.#{name}")
  end
end
