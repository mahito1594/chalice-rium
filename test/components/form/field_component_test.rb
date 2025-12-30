# frozen_string_literal: true

require "test_helper"

module Form
  class FieldComponentTest < ViewComponent::TestCase
    def setup
      @user = User.new
    end

    test "renders text field with label" do
      with_controller_class(UsersController) do
        render_inline(FieldComponent.new(form: form_for(@user), attribute: :username))

        assert_selector "label", text: I18n.t("activerecord.attributes.user.username")
        assert_selector "input[type='text'][name='user[username]']"
      end
    end

    test "renders email field" do
      with_controller_class(UsersController) do
        render_inline(FieldComponent.new(form: form_for(@user), attribute: :email, type: :email))

        assert_selector "input[type='email'][name='user[email]']"
      end
    end

    test "renders password field" do
      with_controller_class(UsersController) do
        render_inline(FieldComponent.new(form: form_for(@user), attribute: :password, type: :password))

        assert_selector "input[type='password'][name='user[password]']"
      end
    end

    test "renders textarea field" do
      with_controller_class(DungeonsController) do
        @dungeon = Dungeon.new
        render_inline(FieldComponent.new(form: form_for(@dungeon), attribute: :comment, type: :textarea))

        assert_selector "textarea[name='dungeon[comment]']"
      end
    end

    test "renders with custom label" do
      with_controller_class(UsersController) do
        render_inline(FieldComponent.new(form: form_for(@user), attribute: :username, label: "Custom Label"))

        assert_selector "label", text: "Custom Label"
      end
    end

    test "marks field as required" do
      with_controller_class(UsersController) do
        render_inline(FieldComponent.new(form: form_for(@user), attribute: :username, required: true))

        assert_selector "input[required]"
      end
    end

    test "displays error messages when field has errors" do
      with_controller_class(UsersController) do
        @user.errors.add(:username, "can't be blank")

        render_inline(FieldComponent.new(form: form_for(@user), attribute: :username))

        assert_selector "p.text-red-600"
        assert_includes rendered_content, "border-red-500"
      end
    end

    test "applies custom input options" do
      with_controller_class(UsersController) do
        render_inline(FieldComponent.new(
          form: form_for(@user),
          attribute: :username,
          placeholder: "@username",
          maxlength: 20
        ))

        assert_selector "input[placeholder='@username']"
        assert_selector "input[maxlength='20']"
      end
    end

    test "includes proper styling classes" do
      with_controller_class(UsersController) do
        render_inline(FieldComponent.new(form: form_for(@user), attribute: :username))

        assert_includes rendered_content, "block w-full"
        assert_includes rendered_content, "rounded-lg"
        assert_includes rendered_content, "dark:bg-gray-800"
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
