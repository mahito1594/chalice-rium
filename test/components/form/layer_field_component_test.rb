# frozen_string_literal: true

require "test_helper"

module Form
  class LayerFieldComponentTest < ViewComponent::TestCase
    def setup
      @dungeon = Dungeon.new
    end

    test "renders label with level and boss_name input" do
      layer = Layer.new(level: 1, dungeon: @dungeon)

      with_controller_class(DungeonsController) do
        render_inline(LayerFieldComponent.new(form: layer_form_for(layer)))

        assert_selector "label", text: I18n.t("label.dungeon.attributes.boss_name", level: 1)
        assert_selector "input[type='text'][name*='boss_name']"
      end
    end

    test "renders hidden_field for level" do
      layer = Layer.new(level: 2, dungeon: @dungeon)

      with_controller_class(DungeonsController) do
        render_inline(LayerFieldComponent.new(form: layer_form_for(layer)))

        assert_selector "input[type='hidden'][name*='level']", visible: :hidden
      end
    end

    test "applies wrapper_class" do
      layer = Layer.new(level: 1, dungeon: @dungeon)

      with_controller_class(DungeonsController) do
        render_inline(LayerFieldComponent.new(form: layer_form_for(layer), wrapper_class: "mt-4"))

        assert_selector "div.mt-4"
      end
    end

    test "includes proper input styling" do
      layer = Layer.new(level: 1, dungeon: @dungeon)

      with_controller_class(DungeonsController) do
        render_inline(LayerFieldComponent.new(form: layer_form_for(layer)))

        assert_includes rendered_content, "rounded-lg"
        assert_includes rendered_content, "dark:bg-gray-800"
      end
    end

    private

    def layer_form_for(layer)
      ActionView::Helpers::FormBuilder.new(
        "dungeon[layers_attributes][0]",
        layer,
        vc_test_controller.view_context,
        {}
      )
    end
  end
end
