# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require 'file_transactions'

require 'minitest/autorun'
require 'tmpdir'

module FileTransactions
  class Test < Minitest::Test
    PROJECT_TAR = File.expand_path('data/project.tar.gz', __dir__).freeze
    PROJECT_DIRECTORY = 'project'

    def tmp_dir
      @tmp_dir ||= Dir.mktmpdir
    end

    def project_path
      return @project_path if defined? @project_path

      Dir.chdir(tmp_dir) { `tar xzf #{PROJECT_TAR}` }
      @project_path = File.join(tmp_dir, PROJECT_DIRECTORY)
    end

    def in_project
      raise 'No block given' unless block_given?
      Dir.chdir(project_path) { yield }
    end

    def teardown
      FileUtils.remove_dir tmp_dir
    end

    def assert_clean_project
      output = in_project { `git status --short` }
      assert output.empty?, "Project is dirty: \n#{output}"
    end

    def refute_clean_project
      output = in_project { `git status --short` }
      refute output.empty?, "Project is clean! It was expected to be dirty"
    end

    def assert_file_exist(file)
      assert File.exist?(file), "Expected file \"#{file}\" does not exist!"
    end

    def refute_file_exist(file)
      refute File.exist?(file), "Expected file \"#{file}\" to not exist!"
    end

    def assert_dir_exist(dir)
      assert Dir.exist?(dir), "Expected dir \"#{dir}\" does not exist!"
    end

    def refute_dir_exist(dir)
      refute Dir.exist?(dir), "Expected dir \"#{dir}\" to not exist!"
    end

    def assert_file_content(file, expected)
      assert_file_exist file
      actual = File.read(file)
      assert_equal(expected, actual, <<~MSG)
        File content does not match:
        Expected: #{expected}
        Actual: #{actual}
      MSG
    end

    def refute_file_content(file, expected)
      assert_file_exist file
      actual = File.read(file)
      refute_equal(expected, actual, "Expected fiile content to not be the same!")
    end
  end
end

FT = FileTransactions
