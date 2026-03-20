# frozen_string_literal: true

module Form
  class CollectionCheckboxesComponent < ApplicationComponent
    LABEL_CLASSES = "block text-sm text-gray-800 dark:text-gray-200"
    CHECKBOX_CLASSES = "size-4 border rounded-sm dark:bg-gray-800 dark:border-gray-600 focus:border-blue-400 dark:focus:border-blue-300 focus:ring-blue-300/40 focus:outline-hidden focus:ring-3"
    CHECKBOX_LABEL_CLASSES = "text-sm text-gray-800 dark:text-gray-200"

    def initialize(form:, attribute:, collection:, value_method:, text_method:,
                   label:, checked: nil, disabled: false, **html_options)
      @form = form
      @attribute = attribute
      @collection = collection
      @value_method = value_method
      @text_method = text_method
      @label = label
      @checked = checked
      @disabled = disabled
      @html_options = html_options
    end

    private

    def checkbox_classes
      if @disabled
        "size-4 border rounded-sm bg-gray-100 dark:bg-gray-700 dark:border-gray-600 cursor-not-allowed"
      else
        CHECKBOX_CLASSES
      end
    end

    def checkbox_label_classes
      if @disabled
        "text-sm text-gray-500 dark:text-gray-400"
      else
        CHECKBOX_LABEL_CLASSES
      end
    end

    def checked_options
      opts = @checked ? { checked: @checked } : {}
      opts[:include_hidden] = false if @disabled
      opts
    end
  end
end
