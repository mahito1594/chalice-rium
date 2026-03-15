# frozen_string_literal: true

require "test_helper"

module Form
  class ReadOnlyFieldComponentTest < ViewComponent::TestCase
    def setup
      @user = User.new(username: "@willem")
      @dungeon = Dungeon.new
    end

    test "renders label and value" do
      with_controller_class(UsersController) do
        render_inline(ReadOnlyFieldComponent.new(
          form: form_for(@user), attribute: :username, value: @user.username
        ))

        assert_selector "label", text: I18n.t("activerecord.attributes.user.username")
        assert_text "@willem"
      end
    end

    test "renders with custom label" do
      with_controller_class(UsersController) do
        render_inline(ReadOnlyFieldComponent.new(
          form: form_for(@user), attribute: :username, value: @user.username, label: "Custom Label"
        ))

        assert_selector "label", text: "Custom Label"
      end
    end

    test "applies wrapper_class" do
      with_controller_class(UsersController) do
        render_inline(ReadOnlyFieldComponent.new(
          form: form_for(@user), attribute: :username, value: @user.username, wrapper_class: "w-full mt-4"
        ))

        assert_selector "div.w-full.mt-4"
      end
    end

    test "includes read-only styling" do
      with_controller_class(UsersController) do
        render_inline(ReadOnlyFieldComponent.new(
          form: form_for(@user), attribute: :username, value: @user.username
        ))

        assert_includes rendered_content, "bg-gray-100"
        assert_includes rendered_content, "text-gray-500"
        assert_includes rendered_content, "dark:bg-gray-700"
      end
    end

    test "renders translated value" do
      with_controller_class(DungeonsController) do
        render_inline(ReadOnlyFieldComponent.new(
          form: form_for(@dungeon), attribute: :area, value: "トゥメル"
        ))

        assert_text "トゥメル"
      end
    end

    private

    def form_for(object)
      ActionView::Helpers::FormBuilder.new(
        object.class.model_name.param_key,
        object,
        vc_test_controller.view_context,
        {}
      )
    end
  end
end
