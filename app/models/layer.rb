class Layer < ApplicationRecord
  belongs_to :dungeon

  validates :level, presence: true,
            uniqueness: { scope: :dungeon_id },
            inclusion: { in: 1..4 }
end
