module UsersHelper
  def gravatar_for user
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{Settings.image_size}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
end
