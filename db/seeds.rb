# Example users
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
