# frozen_string_literal: true

require "test_helper"

module Ui
  class DescriptionItemComponentTest < ViewComponent::TestCase
    def test_renders_label_and_value
      render_inline(DescriptionItemComponent.new(label: "Area", value: "Pthumeru"))

      assert_selector "p", text: "Area"
      assert_selector "p", text: "Pthumeru"
    end

    def test_includes_label_styling
      render_inline(DescriptionItemComponent.new(label: "Area", value: "Pthumeru"))

      assert_includes rendered_content, "text-sm"
      assert_includes rendered_content, "font-medium"
      assert_includes rendered_content, "text-gray-500"
    end

    def test_includes_value_styling
      render_inline(DescriptionItemComponent.new(label: "Area", value: "Pthumeru"))

      assert_includes rendered_content, "text-lg"
      assert_includes rendered_content, "text-gray-700"
    end

    def test_renders_numeric_value
      render_inline(DescriptionItemComponent.new(label: "Depth", value: 5))

      assert_selector "p", text: "5"
    end

    def test_applies_custom_class
      render_inline(DescriptionItemComponent.new(label: "Area", value: "Pthumeru", class: "mt-4"))

      assert_selector "div.mt-4"
    end
  end
end
