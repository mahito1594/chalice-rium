# frozen_string_literal: true

require "test_helper"

module Form
  class CheckboxComponentTest < ViewComponent::TestCase
    def setup
      @dungeon = Dungeon.new
    end

    test "renders checkbox with label" do
      with_controller_class(DungeonsController) do
        render_inline(CheckboxComponent.new(form: form_for(@dungeon), attribute: :is_open))

        assert_selector "input[type='checkbox'][name='dungeon[is_open]']"
        assert_selector "label"
      end
    end

    test "renders with custom label" do
      with_controller_class(DungeonsController) do
        render_inline(CheckboxComponent.new(form: form_for(@dungeon), attribute: :is_open, label: "Public dungeon"))

        assert_selector "label", text: "Public dungeon"
      end
    end

    test "renders checked by default when specified" do
      with_controller_class(DungeonsController) do
        render_inline(CheckboxComponent.new(form: form_for(@dungeon), attribute: :is_open, checked: true))

        assert_selector "input[checked]"
      end
    end

    test "renders disabled checkbox" do
      with_controller_class(DungeonsController) do
        render_inline(CheckboxComponent.new(form: form_for(@dungeon), attribute: :is_open, disabled: true))

        assert_selector "input[disabled]"
        assert_includes rendered_content, "cursor-not-allowed"
      end
    end

    test "displays error messages when field has errors" do
      with_controller_class(DungeonsController) do
        @dungeon.errors.add(:is_open, "must be accepted")

        render_inline(CheckboxComponent.new(form: form_for(@dungeon), attribute: :is_open))

        assert_selector "p.text-red-600"
      end
    end

    test "applies custom HTML options" do
      with_controller_class(DungeonsController) do
        render_inline(CheckboxComponent.new(
          form: form_for(@dungeon),
          attribute: :is_open,
          data: { controller: "toggle" }
        ))

        assert_selector "input[data-controller='toggle']"
      end
    end

    test "includes proper styling classes" do
      with_controller_class(DungeonsController) do
        render_inline(CheckboxComponent.new(form: form_for(@dungeon), attribute: :is_open))

        assert_includes rendered_content, "size-4"
        assert_includes rendered_content, "rounded-sm"
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
