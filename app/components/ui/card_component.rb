# frozen_string_literal: true

module Ui
  class CardComponent < ApplicationComponent
    renders_one :header
    renders_one :footer

    SIZE_CLASSES = {
      sm: "max-w-sm",
      md: "max-w-2xl",
      lg: "max-w-7xl"
    }.freeze

    def initialize(size: :sm, centered: true, **html_options)
      @size = size
      @centered = centered
      @html_options = html_options
    end

    private

    def card_classes
      [
        base_classes,
        SIZE_CLASSES[@size],
        centered_class,
        @html_options[:class]
      ].compact.join(" ")
    end

    def base_classes
      "w-full bg-white rounded-lg shadow-md dark:bg-gray-800 overflow-hidden"
    end

    def content_classes
      "p-6"
    end

    def centered_class
      @centered ? "mx-auto" : nil
    end

    def html_attributes
      @html_options.except(:class)
    end
  end
end
