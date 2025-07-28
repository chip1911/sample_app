class User < ApplicationRecord
  has_secure_password
  attr_accessor :remember_token

  scope :newest, -> {order(created_at: :desc)}

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i
  MAXIMUM_AGE = 100
  USER_PERMIT = %i(name email password password_confirmation birthday).freeze

  before_save :downcase_email

  validates :name, presence: true,
            length: {maximum: Settings.maximum_name_length}
  validates :email, presence: true,
            length: {maximum: Settings.maximum_email_length},
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}
  validates :password, presence: true,
            length: {minimum: Settings.minimum_password_length},
            allow_nil: true
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

  # Returns remember token digest.
  def remember
    self.remember_token = User.new_token
    update_column :remember_digest, User.digest(remember_token)
    remember_digest
  end

  def session_token
    remember_digest || remember
  end

  def forget
    update_column :remember_digest, nil
  end

  def authenticated? remember_token
    return false if remember_digest.blank?

    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost:
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end
end
