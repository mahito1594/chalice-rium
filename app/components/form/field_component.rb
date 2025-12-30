# frozen_string_literal: true

module Form
  class FieldComponent < ApplicationComponent
    INPUT_CLASSES = "block w-full px-4 py-2 mt-2 text-gray-700 bg-white border rounded-lg dark:bg-gray-800 dark:text-gray-300 dark:border-gray-600 focus:border-blue-400 dark:focus:border-blue-300 focus:ring-blue-300/40 focus:outline-hidden focus:ring-3"
    LABEL_CLASSES = "block text-sm text-gray-800 dark:text-gray-200"
    HINT_CLASSES = "text-sm text-gray-600 dark:text-gray-400"
    ERROR_CLASSES = "mt-1 text-sm text-red-600 dark:text-red-400"

    def initialize(form:, attribute:, type: :text, label: nil, required: false, hint: nil, **input_options)
      @form = form
      @attribute = attribute
      @type = type
      @label = label
      @required = required
      @hint = hint
      @input_options = input_options
    end

    def label_text
      @label || @form.object.class.human_attribute_name(@attribute)
    end

    def input_method
      case @type
      when :email then :email_field
      when :password then :password_field
      when :number then :number_field
      when :tel then :telephone_field
      when :url then :url_field
      when :textarea then :text_area
      when :select then :select
      else :text_field
      end
    end

    def errors?
      @form.object.errors[@attribute].any?
    end

    def error_messages
      @form.object.errors.full_messages_for(@attribute)
    end

    private

    def input_classes
      base = INPUT_CLASSES
      base += " border-red-500" if errors?
      custom = @input_options[:class]
      custom ? "#{base} #{custom}" : base
    end

    def input_html_options
      @input_options.except(:class, :wrapper_class, :choices, :options).merge(
        class: input_classes,
        required: @required
      )
    end
  end
end
