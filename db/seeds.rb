# Crate Rites at first
Rite.names.each do |name, _value|
  Rite.create!(name: name)
end

# Create example users
User.create!(username: "@willem",
             display_name: "Master Willem",
             email: "willem@example.com",
             password: "foobar",
             password_confirmation: "foobar",
             confirmed_at: Time.new(2015, 3, 26))

User.create!(username: "@laurence",
             display_name: "Laurence, the First Vicar",
             email: "laurence@example.com",
             password: "foobar",
             password_confirmation: "foobar",
             confirmed_at: Time.new(2015, 3, 26))

User.create!(username: "@gehrman",
             display_name: "Gehrman, the First Hunter",
             email: "gehrman@example.com",
             password: "foobar",
             password_confirmation: "foobar",
             confirmed_at: Time.new(2015, 3, 26))

User.create!(username: "@maria",
             display_name: "Lady Maria of the Astral Clocktower",
             email: "maria@example.com",
             password: "foobar",
             password_confirmation: "foobar",
             confirmed_at: Time.new(2015, 3, 26))

User.create!(username: "@ludwig",
             display_name: "Ludwig, the Holy Blade",
             email: "ludwig@example.com",
             password: "foobar",
             password_confirmation: "foobar",
             confirmed_at: Time.new(2015, 3, 26))

# Samples for bosses
BOSS_NAMES = [
  'Watchdog of the Old Lords',
  'Keeper of the Old Lords',
  'Pthumerian Elder',
  'Pthumerian Descendant',
  'Bloodletting Beast',
  'Abhorrent Beast',
  'Celestial Emissary',
  'Ebrietas',
  'Merciless Watchers'
]

# Create sample chalices
User.all.each do |user|
  10.times do
    layer_count = rand(3..4)
    layers_attributes = []
    layer_count.times do |i|
      layers_attributes << { level: i + 1, boss_name: BOSS_NAMES.sample }
    end

    dungeon = user.dungeons.create!(glyph: SecureRandom.alphanumeric(8).downcase,
                                    area: Dungeon.areas.keys.filter { |x| x != "hintertomb" }.sample,
                                    depth: 5,
                                    is_open: [ true, false ].sample,
                                    comment: [
                                      "",
                                      "May the good blood guide your way.",
                                      "Fear the old blood.",
                                      "Seek the paleblood." ].sample,
                                    layers_attributes: layers_attributes)

    selected_rites = Rite.all.filter { |x| x.name != "sinister" }
    dungeon.rites << selected_rites
  end
end
