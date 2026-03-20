# frozen_string_literal: true

module Ui
  class DescriptionItemComponent < ApplicationComponent
    LABEL_CLASSES = "text-sm font-medium text-gray-500 dark:text-gray-400"
    VALUE_CLASSES = "mt-1 text-lg text-gray-700 dark:text-gray-200"

    def initialize(label:, value:, **html_options)
      @label = label
      @value = value
      @html_options = html_options
    end
  end
end
