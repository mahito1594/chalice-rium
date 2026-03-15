# frozen_string_literal: true

module Form
  class SelectComponent < ApplicationComponent
    LABEL_CLASSES = "block text-sm font-medium text-gray-800 dark:text-gray-200 mb-2"
    SELECT_CLASSES = "block w-full px-4 py-2 text-gray-700 bg-white border border-gray-300 rounded-lg dark:bg-gray-800 dark:text-gray-300 dark:border-gray-600 focus:border-blue-400 dark:focus:border-blue-300 focus:ring-blue-300/40 focus:outline-hidden focus:ring-3"

    def initialize(name:, options:, selected: nil, label: nil, label_id: nil, include_blank: nil, **html_options)
      @name = name
      @options = options
      @selected = selected
      @label = label
      @label_id = label_id
      @include_blank = include_blank
      @html_options = html_options
    end

    private

    def wrapper_class
      @html_options[:wrapper_class]
    end

    def select_classes
      [ SELECT_CLASSES, @html_options[:class] ].compact.join(" ")
    end

    def select_html_options
      @html_options.except(:class, :wrapper_class).merge(class: select_classes)
    end
  end
end
