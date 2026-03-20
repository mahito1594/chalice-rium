# frozen_string_literal: true

require "test_helper"

module Ui
  class AlertComponentTest < ViewComponent::TestCase
    def test_renders_error_messages
      user = User.new
      user.errors.add(:username, "can't be blank")

      render_inline(AlertComponent.new(resource: user))

      assert_selector "#error_explanation"
      assert_selector "span", text: I18n.t("label.general.error")
      assert_selector "li", text: /can't be blank/
    end

    def test_does_not_render_when_no_errors
      user = User.new

      render_inline(AlertComponent.new(resource: user))

      assert_no_selector "div"
    end

    def test_renders_multiple_error_messages
      user = User.new
      user.errors.add(:username, "can't be blank")
      user.errors.add(:email, "is invalid")

      render_inline(AlertComponent.new(resource: user))

      assert_selector "li", count: 2
    end

    def test_includes_error_icon
      user = User.new
      user.errors.add(:username, "can't be blank")

      render_inline(AlertComponent.new(resource: user))

      assert_selector "svg path[d]"
    end

    def test_includes_base_styling
      user = User.new
      user.errors.add(:username, "can't be blank")

      render_inline(AlertComponent.new(resource: user))

      assert_selector "div.rounded-lg.shadow-md"
      assert_selector "div.bg-red-500"
    end

    def test_includes_turbo_cache_false
      user = User.new
      user.errors.add(:username, "can't be blank")

      render_inline(AlertComponent.new(resource: user))

      assert_selector "[data-turbo-cache='false']"
    end

    def test_applies_custom_html_options
      user = User.new
      user.errors.add(:username, "can't be blank")

      render_inline(AlertComponent.new(resource: user, class: "mt-4"))

      assert_includes rendered_content, "mt-4"
    end

    def test_excludes_inline_error_attributes
      user = User.new
      user.errors.add(:username, "can't be blank")
      user.errors.add(:base, "something went wrong")

      render_inline(AlertComponent.new(resource: user, inline_error_attributes: [ :username ]))

      assert_no_selector "li", text: /can't be blank/
      assert_selector "li", text: /something went wrong/
    end

    def test_does_not_render_when_only_inline_errors
      user = User.new
      user.errors.add(:username, "can't be blank")

      render_inline(AlertComponent.new(resource: user, inline_error_attributes: [ :username ]))

      assert_no_selector "div"
    end
  end
end
