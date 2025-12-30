# frozen_string_literal: true

module Form
  class CheckboxComponent < ApplicationComponent
    CHECKBOX_CLASSES = "size-4 border rounded-sm dark:bg-gray-800 dark:border-gray-600 focus:border-blue-400 dark:focus:border-blue-300 focus:ring-blue-300/40 focus:outline-hidden focus:ring-3"
    LABEL_CLASSES = "text-sm text-gray-800 dark:text-gray-200"
    ERROR_CLASSES = "mt-1 text-sm text-red-600 dark:text-red-400"

    def initialize(form:, attribute:, label: nil, checked: false, disabled: false, **input_options)
      @form = form
      @attribute = attribute
      @label = label
      @checked = checked
      @disabled = disabled
      @input_options = input_options
    end

    def label_text
      @label || @form.object.class.human_attribute_name(@attribute)
    end

    def has_errors?
      @form.object.errors[@attribute].any?
    end

    def error_messages
      @form.object.errors.full_messages_for(@attribute)
    end

    private

    def checkbox_classes
      base = CHECKBOX_CLASSES
      base += " cursor-not-allowed" if @disabled
      custom = @input_options[:class]
      custom ? "#{base} #{custom}" : base
    end

    def checkbox_html_options
      opts = @input_options.except(:class, :wrapper_class).merge(
        class: checkbox_classes,
        disabled: @disabled
      )
      opts[:checked] = @checked if @checked
      opts
    end
  end
end
