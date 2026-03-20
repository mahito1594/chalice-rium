# frozen_string_literal: true

module Form
  class ReadOnlyFieldComponent < ApplicationComponent
    LABEL_CLASSES = "block text-sm text-gray-800 dark:text-gray-200"
    VALUE_CLASSES = "block w-full px-4 py-2 mt-2 text-gray-500 bg-gray-100 rounded-lg dark:bg-gray-700 dark:text-gray-400"

    def initialize(form:, attribute:, value:, label: nil, **html_options)
      @form = form
      @attribute = attribute
      @value = value
      @label = label
      @html_options = html_options
    end

    private

    def label_text
      @label || @form.object.class.human_attribute_name(@attribute)
    end

    def wrapper_class
      @html_options[:wrapper_class]
    end
  end
end
