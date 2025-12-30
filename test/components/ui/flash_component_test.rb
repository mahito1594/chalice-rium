# frozen_string_literal: true

require "test_helper"

module Ui
  class FlashComponentTest < ViewComponent::TestCase
    def test_renders_notice_flash
      render_inline(FlashComponent.new(type: :notice, message: "Success!"))

      assert_selector "div.bg-blue-500"
      assert_text "Success!"
    end

    def test_renders_alert_flash
      render_inline(FlashComponent.new(type: :alert, message: "Error!"))

      assert_selector "div.bg-red-500"
      assert_text "Error!"
    end

    def test_does_not_render_when_message_is_nil
      render_inline(FlashComponent.new(type: :notice, message: nil))

      assert_no_selector "div"
    end

    def test_does_not_render_when_message_is_blank
      render_inline(FlashComponent.new(type: :notice, message: ""))

      assert_no_selector "div"
    end

    def test_includes_stimulus_controller
      render_inline(FlashComponent.new(type: :notice, message: "Test"))

      assert_selector "[data-controller='flash']"
    end

    def test_includes_dismiss_button
      render_inline(FlashComponent.new(type: :notice, message: "Test"))

      assert_selector "button[data-action='click->flash#delete']"
    end

    def test_includes_icon
      render_inline(FlashComponent.new(type: :notice, message: "Test"))

      assert_selector "svg path[d]"
    end

    def test_applies_custom_html_options
      render_inline(FlashComponent.new(type: :notice, message: "Test", id: "my-flash", data: { custom: "value" }))

      assert_selector "#my-flash[data-custom='value']"
    end

    def test_defaults_to_notice_for_unknown_type
      render_inline(FlashComponent.new(type: :unknown, message: "Test"))

      assert_selector "div.bg-blue-500"
    end

    def test_renders_base_classes
      render_inline(FlashComponent.new(type: :notice, message: "Test"))

      assert_selector "div.w-full.text-white"
    end
  end
end
