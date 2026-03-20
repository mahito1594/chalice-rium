# frozen_string_literal: true

require "test_helper"

module Form
  class CollectionCheckboxesComponentTest < ViewComponent::TestCase
    def setup
      @dungeon = Dungeon.new
      @rites = Rite.all.to_a
    end

    test "renders checkboxes for collection" do
      with_controller_class(DungeonsController) do
        render_inline(CollectionCheckboxesComponent.new(
          form: form_for(@dungeon), attribute: :rite_ids, collection: @rites,
          value_method: :id, text_method: :translated_name,
          label: "Additional Rites"
        ))

        assert_selector "fieldset"
        assert_selector "legend", text: "Additional Rites"
        assert_selector "input[type='checkbox']", count: @rites.size
      end
    end

    test "renders with checked values" do
      with_controller_class(DungeonsController) do
        checked_ids = @rites.first(2).map(&:id)
        render_inline(CollectionCheckboxesComponent.new(
          form: form_for(@dungeon), attribute: :rite_ids, collection: @rites,
          value_method: :id, text_method: :translated_name,
          label: "Rites", checked: checked_ids
        ))

        assert_selector "input[type='checkbox'][checked]", count: 2
      end
    end

    test "renders disabled checkboxes" do
      with_controller_class(DungeonsController) do
        render_inline(CollectionCheckboxesComponent.new(
          form: form_for(@dungeon), attribute: :rite_ids, collection: @rites,
          value_method: :id, text_method: :translated_name,
          label: "Rites", disabled: true
        ))

        assert_selector "input[type='checkbox'][disabled]", count: @rites.size
        assert_includes rendered_content, "cursor-not-allowed"
      end
    end

    test "disabled checkboxes have muted label styling" do
      with_controller_class(DungeonsController) do
        render_inline(CollectionCheckboxesComponent.new(
          form: form_for(@dungeon), attribute: :rite_ids, collection: @rites,
          value_method: :id, text_method: :translated_name,
          label: "Rites", disabled: true
        ))

        assert_includes rendered_content, "text-gray-500"
      end
    end

    test "requires label parameter" do
      assert_raises(ArgumentError) do
        CollectionCheckboxesComponent.new(
          form: form_for(@dungeon), attribute: :rite_ids, collection: @rites,
          value_method: :id, text_method: :translated_name
        )
      end
    end

    test "applies wrapper_class" do
      with_controller_class(DungeonsController) do
        render_inline(CollectionCheckboxesComponent.new(
          form: form_for(@dungeon), attribute: :rite_ids, collection: @rites,
          value_method: :id, text_method: :translated_name,
          label: "Rites", wrapper_class: "mt-4"
        ))

        assert_selector "fieldset.mt-4"
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
