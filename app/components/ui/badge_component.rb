# frozen_string_literal: true

module Ui
  class BadgeComponent < ApplicationComponent
    VARIANT_CLASSES = {
      default: "bg-slate-100 text-slate-700 dark:bg-slate-700 dark:text-slate-200",
      success: "bg-green-100 text-green-700 dark:bg-green-900 dark:text-green-200",
      danger:  "bg-red-100 text-red-700 dark:bg-red-900 dark:text-red-200",
      warning: "bg-amber-100 text-amber-700 dark:bg-amber-900 dark:text-amber-200"
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
