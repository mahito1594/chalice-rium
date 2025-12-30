# frozen_string_literal: true

module Ui
  class BadgeComponent < ApplicationComponent
    VARIANT_CLASSES = {
      default: "bg-gray-100 text-gray-700 dark:bg-gray-700 dark:text-gray-200",
      success: "bg-green-100 text-green-700",
      danger: "bg-red-100 text-red-700",
      warning: "bg-yellow-100 text-yellow-700"
    }.freeze

    def initialize(variant: :default, **html_options)
      @variant = variant
      @html_options = html_options
    end

    private

    def badge_classes
      [
        base_classes,
        VARIANT_CLASSES[@variant],
        @html_options[:class]
      ].compact.join(" ")
    end

    def base_classes
      "px-3 py-1 text-sm rounded-full"
    end

    def html_attributes
      @html_options.except(:class)
    end
  end
end
