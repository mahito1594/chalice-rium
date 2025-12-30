# frozen_string_literal: true

require "test_helper"

module Ui
  class CardComponentTest < ViewComponent::TestCase
    test "renders card with content" do
      render_inline(CardComponent.new) { "Card content" }

      assert_selector "div.bg-white.rounded-lg.shadow-md", text: "Card content"
    end

    test "renders small card by default" do
      render_inline(CardComponent.new) { "Small" }

      assert_selector "div.max-w-sm"
    end

    test "renders medium card" do
      render_inline(CardComponent.new(size: :md)) { "Medium" }

      assert_selector "div.max-w-2xl"
    end

    test "renders large card" do
      render_inline(CardComponent.new(size: :lg)) { "Large" }

      assert_selector "div.max-w-7xl"
    end

    test "renders centered card by default" do
      render_inline(CardComponent.new) { "Centered" }

      assert_selector "div.m-auto.mx-auto"
    end

    test "renders non-centered card when specified" do
      render_inline(CardComponent.new(centered: false)) { "Not centered" }

      assert_no_selector "div.m-auto"
    end

    test "renders with header slot" do
      render_inline(CardComponent.new) do |component|
        component.with_header { "<h3>Card Title</h3>".html_safe }
        "Card body"
      end

      assert_selector "h3", text: "Card Title"
      assert_text "Card body"
    end

    test "renders without header when not provided" do
      render_inline(CardComponent.new) { "Just body" }

      assert_text "Just body"
    end

    test "includes dark mode classes" do
      render_inline(CardComponent.new) { "Dark mode" }

      assert_includes rendered_content, "dark:bg-gray-800"
    end

    test "applies custom HTML options" do
      render_inline(CardComponent.new(id: "my-card", data: { controller: "card" })) { "Test" }

      assert_selector "div#my-card"
      assert_selector "div[data-controller='card']"
    end
  end
end
