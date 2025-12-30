# frozen_string_literal: true

require "test_helper"

module Ui
  class BadgeComponentTest < ViewComponent::TestCase
    test "renders default badge" do
      render_inline(BadgeComponent.new) { "Default" }

      assert_selector "span.bg-gray-100.text-gray-700", text: "Default"
      assert_selector "span.rounded-full"
    end

    test "renders success badge" do
      render_inline(BadgeComponent.new(variant: :success)) { "Open" }

      assert_selector "span.bg-green-100.text-green-700", text: "Open"
    end

    test "renders danger badge" do
      render_inline(BadgeComponent.new(variant: :danger)) { "Closed" }

      assert_selector "span.bg-red-100.text-red-700", text: "Closed"
    end

    test "renders warning badge" do
      render_inline(BadgeComponent.new(variant: :warning)) { "Pending" }

      assert_selector "span.bg-yellow-100.text-yellow-700", text: "Pending"
    end

    test "applies custom HTML options" do
      render_inline(BadgeComponent.new(data: { controller: "badge" })) { "Test" }

      assert_selector "span[data-controller='badge']"
    end

    test "includes base styling classes" do
      render_inline(BadgeComponent.new) { "Base" }

      assert_selector "span.px-3"
      assert_selector "span.py-1"
      assert_selector "span.text-sm"
    end

    test "includes dark mode classes for default variant" do
      render_inline(BadgeComponent.new) { "Dark" }

      assert_includes rendered_content, "dark:bg-gray-700"
      assert_includes rendered_content, "dark:text-gray-200"
    end
  end
end
