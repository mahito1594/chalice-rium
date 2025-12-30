# frozen_string_literal: true

SimpleCov.start "rails" do
  # Enable coverage tracking for parallel test workers
  enable_for_subprocesses true

  # Enable branch coverage (Ruby 2.5+)
  enable_coverage :branch

  # Primary coverage criterion (used for overall percentage)
  primary_coverage :branch

  # Minimum coverage thresholds (fail if coverage drops below)
  minimum_coverage line: 80, branch: 75

  # Exclude non-application code from coverage
  add_filter "/test/"
  add_filter "/config/"
  add_filter "/db/"
  add_filter "/vendor/"

  # Exclude files with no meaningful logic to test
  add_filter "app/controllers/static_pages_controller.rb"

  # Custom groups for ViewComponents
  add_group "ViewComponents", "app/components"
end
