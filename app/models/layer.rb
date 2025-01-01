class Layer < ApplicationRecord
  belongs_to :dungeon

  validates :level, presence: true,
            numericality: { only_integer: true, greater_than: 0, less_than: 5 }
end
