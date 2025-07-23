class User < ApplicationRecord
  has_secure_password

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i
  MAXIMUM_AGE = 100

  before_save :downcase_email

  validates :name, presence: true,
            length: {maximum: Settings.maximum_name_length}
  validates :email, presence: true,
            length: {maximum: Settings.maximum_email_length},
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}
  validates :password, length: {minimum: Settings.minimum_password_length}
  validate :valid_birthday

  def downcase_email
    self.email = email.downcase
  end

  def valid_birthday
    return errors.add(:birthday, :blank)   if birthday.blank?
    return errors.add(:birthday, :invalid) unless birthday.is_a?(Date)

    if birthday > Time.zone.today
      errors.add(:birthday, :future)
    elsif birthday < MAXIMUM_AGE.years.ago.to_date
      errors.add(:birthday, :too_old)
    end
  end
end
