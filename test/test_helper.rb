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
      assert false # FIXME
    end
  end
end
