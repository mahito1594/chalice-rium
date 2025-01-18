module UsersHelper
  def link_to_twitter_profile(user, options = { class: nil })
    return unless user.twitter_link.present?

    css_classes = options[:class] || "text-blue-500 dark:text-blue-400 hover:underline"

    link_to("@#{user.twitter_link}",
            "https://x.com/#{user.twitter_link}",
            target: "_blank",
            rel: "noreferrer noopener",
            class: css_classes)
  end
end
