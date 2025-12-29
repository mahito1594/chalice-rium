# frozen_string_literal: true

SimpleCov.start "rails" do
  # Enable coverage tracking for parallel test workers
  enable_for_subprocesses true

  # Enable branch coverage (Ruby 2.5+)
  enable_coverage :branch

  # Primary coverage criterion (used for overall percentage)
  primary_coverage :branch

  # Exclude non-application code from coverage
  add_filter "/test/"
  add_filter "/config/"
  add_filter "/db/"
  add_filter "/vendor/"
end
