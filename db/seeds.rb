User.create!(
  name: "Example User",
  email: "example@railstutorial.org",
  password: "foobar",
  password_confirmation: "foobar",
  birthday: Date.new(1990, 1, 1),
  admin: true,
  activated: true,
  activated_at: Time.zone.now
)

29.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  birthday = Faker::Date.birthday(min_age: 18, max_age: 80)

  User.create!(
    name: name,
    email: email,
    password: password,
    password_confirmation: password,
    birthday: birthday,
    activated: true,
    activated_at: Time.zone.now
  )
end
