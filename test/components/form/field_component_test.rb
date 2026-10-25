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

    test "renders number field" do
      with_controller_class(DungeonsController) do
        @dungeon = Dungeon.new
        render_inline(FieldComponent.new(form: form_for(@dungeon), attribute: :depth, type: :number))

        assert_selector "input[type='number'][name='dungeon[depth]']"
      end
    end

    test "renders telephone field" do
      with_controller_class(UsersController) do
        render_inline(FieldComponent.new(form: form_for(@user), attribute: :username, type: :tel))

        assert_selector "input[type='tel'][name='user[username]']"
      end
    end

    test "renders url field" do
      with_controller_class(UsersController) do
        render_inline(FieldComponent.new(form: form_for(@user), attribute: :twitter_link, type: :url))

        assert_selector "input[type='url'][name='user[twitter_link]']"
      end
    end

    test "renders select field" do
      with_controller_class(DungeonsController) do
        @dungeon = Dungeon.new
        render_inline(FieldComponent.new(
          form: form_for(@dungeon),
          attribute: :area,
          type: :select,
          choices: [ [ "Pthumeru", "pthumeru" ], [ "Loran", "loran" ] ]
        ))

        assert_selector "select[name='dungeon[area]']"
      end
    end

    test "applies custom class to input" do
      with_controller_class(UsersController) do
        render_inline(FieldComponent.new(
          form: form_for(@user),
          attribute: :username,
          class: "custom-class"
        ))

        assert_includes rendered_content, "custom-class"
      end
    end

    test "renders hint text when provided" do
      with_controller_class(UsersController) do
        render_inline(FieldComponent.new(
          form: form_for(@user),
          attribute: :password,
          type: :password,
          hint: "※6文字以上"
        ))

        assert_selector "p.text-slate-600", text: "※6文字以上"
      end
    end

    test "renders tooltip with info icon when provided" do
      with_controller_class(UsersController) do
        render_inline(FieldComponent.new(
          form: form_for(@user),
          attribute: :username,
          tooltip: "tooltip text here"
        ))

        assert_selector "button[aria-label='tooltip text here'][tabindex='0']"
        assert_selector "svg"
        assert_selector "[role='tooltip']#tooltip-username", text: "tooltip text here"
        assert_selector "input[aria-describedby='tooltip-username']"
        assert_includes rendered_content, "click->tooltip#show"
      end
    end

    test "does not render tooltip when not provided" do
      with_controller_class(UsersController) do
        render_inline(FieldComponent.new(form: form_for(@user), attribute: :username))

        assert_no_selector "[role='tooltip']"
        assert_no_selector "button[aria-label]"
      end
    end

    test "renders tooltip and hint together" do
      with_controller_class(UsersController) do
        render_inline(FieldComponent.new(
          form: form_for(@user),
          attribute: :password,
          type: :password,
          hint: "hint text",
          tooltip: "tooltip text"
        ))

        assert_selector "[role='tooltip']", text: "tooltip text"
        assert_selector "p", text: "hint text"
      end
    end

    test "does not render hint when not provided" do
      with_controller_class(UsersController) do
        render_inline(FieldComponent.new(form: form_for(@user), attribute: :username))

        assert_no_selector "p.text-slate-600"
      end
    end

    test "does not mark field as required by default" do
      with_controller_class(UsersController) do
        render_inline(FieldComponent.new(form: form_for(@user), attribute: :username))

        assert_no_selector "input[required]"
        assert_no_selector "input[aria-describedby]"
        assert_no_selector "input[aria-invalid]"
      end
    end

    test "marks input as invalid and describes it with error messages" do
      with_controller_class(UsersController) do
        @user.errors.add(:username, "can't be blank")

        render_inline(FieldComponent.new(form: form_for(@user), attribute: :username))

        assert_selector "input[aria-invalid='true'][aria-describedby='error-username']"
        assert_selector "div#error-username p", text: /can't be blank/
      end
    end

    test "describes input with hint" do
      with_controller_class(UsersController) do
        render_inline(FieldComponent.new(form: form_for(@user), attribute: :password, type: :password, hint: "hint"))

        assert_selector "p#hint-password", text: "hint"
        assert_selector "input[aria-describedby='hint-password']"
      end
    end

    test "describes input with tooltip, hint and error in order" do
      with_controller_class(UsersController) do
        @user.errors.add(:username, "can't be blank")

        render_inline(FieldComponent.new(form: form_for(@user), attribute: :username, hint: "hint", tooltip: "tooltip"))

        assert_selector "input[aria-describedby='tooltip-username hint-username error-username']"
      end
    end

    test "renders select field with choices and options" do
      with_controller_class(DungeonsController) do
        @dungeon = Dungeon.new(area: "loran")
        render_inline(FieldComponent.new(
          form: form_for(@dungeon),
          attribute: :area,
          type: :select,
          choices: [ [ "Pthumeru", "pthumeru" ], [ "Loran", "loran" ] ],
          options: { include_blank: "Select" }
        ))

        assert_selector "select[name='dungeon[area]'] option", count: 3
        assert_selector "option[value='']", text: "Select"
        assert_selector "option[value='loran'][selected]", text: "Loran"
        assert_no_selector "select[choices]"
      end
    end

    test "falls back to text field for unknown type" do
      with_controller_class(UsersController) do
        render_inline(FieldComponent.new(form: form_for(@user), attribute: :username, type: :unknown))

        assert_selector "input[type='text'][name='user[username]']"
      end
    end

    test "applies wrapper_class to wrapper instead of input" do
      with_controller_class(UsersController) do
        render_inline(FieldComponent.new(form: form_for(@user), attribute: :username, wrapper_class: "mt-4"))

        assert_selector "div.mt-4.relative > div > label"
        assert_no_selector "input.mt-4"
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
