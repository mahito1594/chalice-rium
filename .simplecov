# frozen_string_literal: true

# Configuration only. Coverage tracking is started in config/boot.rb.
SimpleCov.configure do
  load_profile "rails"

  # Enable coverage tracking for parallel test workers
  merge_subprocesses true

  # Enable branch coverage (Ruby 2.5+)
  enable_coverage :branch

  # Primary coverage criterion (used for overall percentage)
  primary_coverage :branch

  # Minimum coverage thresholds (fail if coverage drops below)
  minimum_coverage line: 80, branch: 75

  # Exclude non-application code from coverage
  skip "/test/"
  skip "/config/"
  skip "/db/"
  skip "/vendor/"

  # Exclude files with no meaningful logic to test
  skip "app/controllers/static_pages_controller.rb"

  # Custom groups for ViewComponents
  group "ViewComponents", "app/components"
end
