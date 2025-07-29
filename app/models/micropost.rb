class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: Settings.resize_limit
  end

  scope :recent_posts, -> {order created_at: :desc}
  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: Settings.digit_140}
  validates :image,
            content_type: {in: %w(image/jpeg image/gif image/png),
                           message: :invalid_format},
            size: {less_than: Settings.digit_5.megabytes,
                   message: :too_large}
end
