# frozen_string_literal: true

require "test_helper"

module Ui
  class ButtonComponentTest < ViewComponent::TestCase
    test "renders primary button by default" do
      render_inline(ButtonComponent.new) { "Click me" }

      assert_selector "button.bg-btn-primary", text: "Click me"
      assert_selector "button[type='button']"
    end

    test "renders secondary button variant" do
      render_inline(ButtonComponent.new(variant: :secondary)) { "Submit" }

      assert_selector "button.bg-blue-600", text: "Submit"
    end

    test "renders danger button variant" do
      render_inline(ButtonComponent.new(variant: :danger)) { "Delete" }

      assert_selector "button.bg-red-600", text: "Delete"
    end

    test "renders outline button variant" do
      render_inline(ButtonComponent.new(variant: :outline)) { "Cancel" }

      assert_selector "button.bg-btn-outline", text: "Cancel"
    end

    test "renders full width button" do
      render_inline(ButtonComponent.new(full_width: true)) { "Full Width" }

      assert_selector "button.w-full"
    end

    test "renders as link when href provided" do
      render_inline(ButtonComponent.new(href: "/path")) { "Link Button" }

      assert_selector "a[href='/path']", text: "Link Button"
      assert_no_selector "button"
    end

    test "renders submit type button" do
      render_inline(ButtonComponent.new(type: :submit)) { "Submit" }

      assert_selector "button[type='submit']"
    end

    test "applies custom HTML options" do
      render_inline(ButtonComponent.new(data: { controller: "test" })) { "Test" }

      assert_selector "button[data-controller='test']"
    end

    test "supports different sizes" do
      render_inline(ButtonComponent.new(size: :sm)) { "Small" }
      assert_selector "button.text-xs"

      render_inline(ButtonComponent.new(size: :lg)) { "Large" }
      assert_selector "button.text-base"
    end


    test "renders medium size by default" do
      render_inline(ButtonComponent.new) { "Medium" }

      assert_selector "button.text-sm.px-6"
    end

    test "renders disabled button" do
      render_inline(ButtonComponent.new(disabled: true)) { "Disabled" }

      assert_selector "button[disabled].cursor-not-allowed.opacity-60"
    end

    test "does not render disabled attribute by default" do
      render_inline(ButtonComponent.new) { "Enabled" }

      assert_no_selector "button[disabled]"
    end

    test "renders full width link as block element" do
      render_inline(ButtonComponent.new(href: "/path", full_width: true)) { "Link" }

      assert_selector "a.w-full.block.text-center[href='/path']"
    end

    test "applies variant and custom HTML options to link" do
      render_inline(ButtonComponent.new(href: "/path", variant: :danger, class: "ml-2",
                                        data: { turbo_method: :delete })) { "Delete" }

      assert_selector "a.bg-red-600.ml-2[data-turbo-method='delete']"
    end
  end
end
