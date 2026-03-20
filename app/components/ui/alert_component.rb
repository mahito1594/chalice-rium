# frozen_string_literal: true

module Ui
  class AlertComponent < ApplicationComponent
    ICON_PATH = "M20 3.36667C10.8167 3.36667 3.3667 10.8167 3.3667 20C3.3667 29.1833 10.8167 36.6333 20 36.6333C29.1834 36.6333 36.6334 29.1833 36.6334 20C36.6334 10.8167 29.1834 3.36667 20 3.36667ZM19.1334 33.3333V22.9H13.3334L21.6667 6.66667V17.1H27.25L19.1334 33.3333Z"

    BASE_CLASSES = "flex w-full max-w-sm mx-auto overflow-hidden bg-white rounded-lg shadow-md dark:bg-gray-800"
    ICON_WRAPPER_CLASSES = "flex items-center justify-center w-12 bg-red-500"
    TITLE_CLASSES = "font-semibold text-red-500 dark:text-red-400"
    MESSAGE_CLASSES = "text-sm text-gray-600 dark:text-gray-200"

    def initialize(resource:, inline_error_attributes: [], **html_options)
      @resource = resource
      @inline_error_attributes = inline_error_attributes.map(&:to_sym)
      @html_options = html_options
    end

    def render?
      error_messages.any?
    end

    private

    def alert_classes
      [ BASE_CLASSES, @html_options[:class] ].compact.join(" ")
    end

    def html_attributes
      @html_options.except(:class).merge(
        id: "error_explanation",
        role: "alert",
        aria: { live: "assertive" },
        data: { turbo_cache: "false" }
      )
    end

    def error_messages
      @error_messages ||= @resource.errors
        .reject { |error| @inline_error_attributes.include?(error.attribute.to_sym) }
        .map(&:full_message)
        .uniq
    end
  end
end
