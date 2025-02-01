module ApplicationHelper
  def full_title(page_title = "")
    base_title = "Chalice-rium"
    if page_title.empty?
      base_title
    else
      page_title  + " | " + base_title
    end
  end

  def ogp_description(description = "")
    # TODO: I18n
    default_description = "聖杯ダンジョンをメモできるWebアプリです"
    if description.empty?
      default_description
    else
      description
    end
  end
end
