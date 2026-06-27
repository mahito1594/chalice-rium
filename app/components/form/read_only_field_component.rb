# frozen_string_literal: true

module Form
  class ReadOnlyFieldComponent < ApplicationComponent
    LABEL_CLASSES = "block text-sm text-slate-800 dark:text-slate-200"
    VALUE_CLASSES = "block w-full px-4 py-2 mt-2 text-slate-500 bg-slate-100 rounded-lg dark:bg-slate-700 dark:text-slate-400"

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
