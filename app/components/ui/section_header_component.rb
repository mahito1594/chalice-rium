# frozen_string_literal: true

module Ui
  class SectionHeaderComponent < ApplicationComponent
    HEADING_CLASSES = "text-lg font-medium text-gray-800 dark:text-white"

    renders_one :action

    def initialize(title:, **html_options)
      @title = title
      @html_options = html_options
    end

    private

    def wrapper_classes
      classes = [ "mb-4", "flex", "items-center" ]
      classes << "justify-between" if action?
      custom = @html_options[:class]
      classes << custom if custom
      classes.join(" ")
    end
  end
end
