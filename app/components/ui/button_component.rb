# frozen_string_literal: true

module Ui
  class ButtonComponent < ApplicationComponent
    VARIANT_CLASSES = {
      primary:   "bg-slate-800 hover:bg-slate-700 text-white focus:ring-blue-300/40",
      secondary: "bg-blue-600 hover:bg-blue-700 text-white focus:ring-blue-300/40",
      danger:    "bg-red-600 hover:bg-red-700 text-white focus:ring-blue-300/40",
      outline:   "bg-slate-100 dark:bg-slate-700 text-slate-600 dark:text-slate-200 hover:bg-slate-200 dark:hover:bg-slate-600 focus:ring-blue-300/40"
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
        link_to @href, class: link_classes, **link_options do
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

    def link_classes
      classes = [ button_classes ]
      classes << "block text-center" if @full_width
      classes.join(" ")
    end
  end
end
