# frozen_string_literal: true

module Ui
  class CardComponent < ApplicationComponent
    renders_one :header

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
      "w-full p-6 bg-white rounded-lg shadow-md dark:bg-gray-800"
    end

    def centered_class
      @centered ? "mx-auto" : nil
    end

    def html_attributes
      @html_options.except(:class)
    end
  end
end
