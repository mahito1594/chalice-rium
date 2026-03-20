# frozen_string_literal: true

require "test_helper"

module Ui
  class SectionHeaderComponentTest < ViewComponent::TestCase
    def test_renders_title
      render_inline(SectionHeaderComponent.new(title: "聖杯ダンジョン一覧"))

      assert_selector "h2", text: "聖杯ダンジョン一覧"
    end

    def test_includes_heading_styling
      render_inline(SectionHeaderComponent.new(title: "Title"))

      assert_includes rendered_content, "text-lg"
      assert_includes rendered_content, "font-medium"
      assert_includes rendered_content, "dark:text-white"
    end

    def test_renders_without_action
      render_inline(SectionHeaderComponent.new(title: "Title"))

      assert_selector "div.flex.items-center"
      assert_no_selector "div.justify-between"
    end

    def test_renders_with_action_slot
      render_inline(SectionHeaderComponent.new(title: "Title")) do |header|
        header.with_action { "<button>Action</button>".html_safe }
      end

      assert_selector "div.justify-between"
      assert_selector "button", text: "Action"
    end

    def test_applies_custom_classes
      render_inline(SectionHeaderComponent.new(title: "Title", class: "mt-6 lg:mt-0"))

      assert_selector "div.mt-6"
    end
  end
end
