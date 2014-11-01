#!/usr/bin/env ruby

require_relative '../bash_colors'

class PostMergeHandler
  attr_reader :files_changed
  def initialize
    @files_changed = `git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD`.strip.split("\n")
  end

  def handle
    run_bundle if gemfile_changed?
    run_rake if pending_migrations?
  end

  private

  def gemfile_changed?
    files_changed.include? "Gemfile"
  end

  def pending_migrations?
    files_changed.each do |file|
      return true if file =~ /^db\/migrate\/.*\.rb/
    end
    false
  end

  def run_bundle
    system("bundle install", out: $stdout, err: :out)
  end

  def run_rake
    system("bundle exec rake db:migrate db:seed", out: $stdout, err: :out)
  end

end

PostMergeHandler.new.handle

