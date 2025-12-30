# frozen_string_literal: true

module Ui
  class FlashComponent < ApplicationComponent
    TYPE_CONFIGS = {
      notice: {
        bg_class: "bg-blue-500",
        icon_path: "M20 3.33331C10.8 3.33331 3.33337 10.8 3.33337 20C3.33337 29.2 10.8 36.6666 20 36.6666C29.2 36.6666 36.6667 29.2 36.6667 20C36.6667 10.8 29.2 3.33331 20 3.33331ZM21.6667 28.3333H18.3334V25H21.6667V28.3333ZM21.6667 21.6666H18.3334V11.6666H21.6667V21.6666Z"
      },
      alert: {
        bg_class: "bg-red-500",
        icon_path: "M20 3.36667C10.8167 3.36667 3.3667 10.8167 3.3667 20C3.3667 29.1833 10.8167 36.6333 20 36.6333C29.1834 36.6333 36.6334 29.1833 36.6334 20C36.6334 10.8167 29.1834 3.36667 20 3.36667ZM19.1334 33.3333V22.9H13.3334L21.6667 6.66667V17.1H27.25L19.1334 33.3333Z"
      }
    }.freeze

    def initialize(type:, message:, **html_options)
      @type = type.to_sym
      @message = message
      @html_options = html_options
      @config = TYPE_CONFIGS[@type] || TYPE_CONFIGS[:notice]
    end

    def render?
      @message.present?
    end

    private

    def flash_classes
      [
        base_classes,
        @config[:bg_class],
        @html_options[:class]
      ].compact.join(" ")
    end

    def base_classes
      "w-full text-white"
    end

    def icon_path
      @config[:icon_path]
    end

    def html_attributes
      @html_options.except(:class)
    end
  end
end
