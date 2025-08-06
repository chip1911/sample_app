class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: Settings.resize_limit
  end

  MICROPOST_PERMIT = %i(content image).freeze

  scope :recent_posts, -> {order created_at: :desc}
  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: Settings.digit_140}
  validates :image,
            content_type: {in: Settings.microposts.type_image,
                           message: :invalid_format},
            size: {less_than: Settings.digit_5.megabytes,
                   message: :too_large}
end
