# frozen_string_literal: true

require "test_helper"

module Form
  class SelectComponentTest < ViewComponent::TestCase
    test "renders select with label" do
      render_inline(SelectComponent.new(
        name: "filter[area]",
        options: [ [ "Pthumeru", "pthumeru" ], [ "Loran", "loran" ] ],
        label: "Area",
        label_id: :filter_area
      ))

      assert_selector "label[for='filter_area']", text: "Area"
      assert_selector "select[name='filter[area]']"
      assert_selector "option[value='pthumeru']", text: "Pthumeru"
      assert_selector "option[value='loran']", text: "Loran"
    end

    test "renders without label" do
      render_inline(SelectComponent.new(
        name: "filter[area]",
        options: [ [ "Pthumeru", "pthumeru" ] ]
      ))

      assert_no_selector "label"
      assert_selector "select[name='filter[area]']"
    end

    test "renders with selected value" do
      render_inline(SelectComponent.new(
        name: "filter[area]",
        options: [ [ "Pthumeru", "pthumeru" ], [ "Loran", "loran" ] ],
        selected: "loran"
      ))

      assert_selector "option[value='loran'][selected]"
    end

    test "renders with include_blank" do
      render_inline(SelectComponent.new(
        name: "filter[area]",
        options: [ [ "Pthumeru", "pthumeru" ] ],
        include_blank: "All"
      ))

      assert_selector "option[value='']", text: "All"
    end

    test "includes proper styling classes" do
      render_inline(SelectComponent.new(
        name: "filter[area]",
        options: [ [ "Pthumeru", "pthumeru" ] ]
      ))

      assert_includes rendered_content, "rounded-lg"
      assert_includes rendered_content, "dark:bg-gray-800"
      assert_includes rendered_content, "border-gray-300"
    end

    test "applies wrapper_class" do
      render_inline(SelectComponent.new(
        name: "filter[area]",
        options: [ [ "Pthumeru", "pthumeru" ] ],
        wrapper_class: "mt-4"
      ))

      assert_selector "div.mt-4"
    end

    test "applies custom html options" do
      render_inline(SelectComponent.new(
        name: "filter[area]",
        options: [ [ "Pthumeru", "pthumeru" ] ],
        id: "my-select",
        data: { controller: "custom" }
      ))

      assert_selector "select#my-select[data-controller='custom']"
    end
  end
end
