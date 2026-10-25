# frozen_string_literal: true

require "test_helper"

module Ui
  class BadgeComponentTest < ViewComponent::TestCase
    test "renders default badge" do
      render_inline(BadgeComponent.new) { "Default" }

      assert_selector "span.bg-slate-100.text-slate-700", text: "Default"
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

      assert_selector "span.bg-amber-100.text-amber-700", text: "Pending"
    end

    test "applies custom HTML options" do
      render_inline(BadgeComponent.new(data: { controller: "badge" })) { "Test" }

      assert_selector "span[data-controller='badge']"
    end


    test "appends custom class" do
      render_inline(BadgeComponent.new(class: "ml-2")) { "Custom" }

      assert_selector "span.rounded-full.bg-slate-100.ml-2"
    end

    test "renders without variant classes for unknown variant" do
      render_inline(BadgeComponent.new(variant: :unknown)) { "Unknown" }

      assert_selector "span.rounded-full", text: "Unknown"
      assert_no_selector "span.bg-slate-100"
    end
  end
end
