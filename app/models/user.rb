class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  has_secure_password
  attr_accessor :remember_token, :activation_token, :reset_token

  scope :newest, -> {order(created_at: :desc)}

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i
  MAXIMUM_AGE = 100
  USER_PERMIT = %i(name email password password_confirmation birthday).freeze

  before_save :downcase_email
  before_create :create_activation_digest

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

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
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

  def authenticated? attribute, token
    digest = send("#{attribute}_digest")
    return false unless digest

    BCrypt::Password.new(digest).is_password?(token)
  end

  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns reset_digest: User.digest(reset_token),
                   reset_sent_at: Time.zone.now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < Settings.password_reset_expired.hours.ago
  end

  def feed
    Micropost.where("user_id = ?", id)
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
