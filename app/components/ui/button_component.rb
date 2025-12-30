# frozen_string_literal: true

module Ui
  class ButtonComponent < ApplicationComponent
    VARIANT_CLASSES = {
      primary: "bg-gray-800 hover:bg-gray-700 text-white focus:ring-gray-300/50",
      secondary: "bg-blue-600 hover:bg-blue-500 text-white focus:ring-blue-300/80",
      danger: "bg-red-600 hover:bg-red-500 text-white focus:ring-red-300/80",
      outline: "bg-gray-100 dark:bg-gray-700 text-gray-500 dark:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-600 focus:ring-gray-300/50"
    }.freeze

    SIZE_CLASSES = {
      sm: "px-4 py-1.5 text-xs",
      md: "px-6 py-2.5 text-sm",
      lg: "px-8 py-3 text-base"
    }.freeze

    def initialize(variant: :primary, size: :md, full_width: false, href: nil, type: :button, **html_options)
      @variant = variant
      @size = size
      @full_width = full_width
      @href = href
      @type = type
      @html_options = html_options
    end

    def call
      if @href
        link_to @href, class: button_classes, **link_options do
          content
        end
      else
        content_tag :button, content, type: @type, class: button_classes, **@html_options
      end
    end

    private

    def button_classes
      [
        base_classes,
        VARIANT_CLASSES[@variant],
        SIZE_CLASSES[@size],
        width_class,
        @html_options[:class]
      ].compact.join(" ")
    end

    def base_classes
      "font-medium tracking-wide capitalize transition-colors duration-300 transform rounded-lg focus:outline-hidden focus:ring-3"
    end

    def width_class
      @full_width ? "w-full" : nil
    end

    def link_options
      @html_options.except(:class)
    end
  end
end
