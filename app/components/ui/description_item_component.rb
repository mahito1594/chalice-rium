# frozen_string_literal: true

module Ui
  class DescriptionItemComponent < ApplicationComponent
    LABEL_CLASSES = "text-sm font-medium text-slate-500 dark:text-slate-400"
    VALUE_CLASSES = "mt-1 text-lg text-slate-700 dark:text-slate-200"

    def initialize(label:, value:, **html_options)
      @label = label
      @value = value
      @html_options = html_options
    end
  end
end
