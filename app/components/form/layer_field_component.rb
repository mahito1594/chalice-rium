# frozen_string_literal: true

module Form
  class LayerFieldComponent < ApplicationComponent
    LABEL_CLASSES = "block text-sm text-gray-800 dark:text-gray-200"
    INPUT_CLASSES = "block w-full px-4 py-2 mt-2 text-gray-700 bg-white border rounded-lg dark:bg-gray-800 dark:text-gray-300 dark:border-gray-600 focus:border-blue-400 dark:focus:border-blue-300 focus:ring-blue-300/40 focus:outline-hidden focus:ring-3"

    def initialize(form:, **html_options)
      @form = form
      @html_options = html_options
    end

    def label_text
      I18n.t("label.dungeon.attributes.boss_name", level: @form.object.level)
    end
  end
end
