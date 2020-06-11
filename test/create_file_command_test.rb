# frozen_string_literal: true

require "test_helper"

module FileTransactions
  class CreateFileCommandTest < Test
    def test_that_it_creates_a_new_file_can_be_created
      command = CreateFileCommand.new('new_file') do
        File.open('new_file', 'w') { |f| f.write('some content') }
      end

      in_project do
        command.execute

        assert File.exist? 'new_file'

        command.undo

        refute File.exist? 'new_file'
        assert_clean_project
      end
    end

    def test_that_it_creates_a_file_with_content_from_block
      command = CreateFileCommand.new('new_file') { 'some content' }

      in_project do
        command.execute

        assert File.exist? 'new_file'
        assert File.read('new_file') == 'some content'

        command.undo

        refute File.exist? 'new_file'
        assert_clean_project
      end
    end

    def test_that_it_creates_file_and_directories
      command = CreateFileCommand.new('dir1/dir2/new_file') { 'some content' }

      in_project do
        command.execute

        assert File.exist? 'dir1/dir2/new_file'
        assert File.read('dir1/dir2/new_file') == 'some content'

        command.undo

        refute File.exist? 'dir1/dir2/new_file'
        refute Dir.exist? 'dir1'
        assert_clean_project
      end
    end

    def test_that_it_creates_a_file_with_absolute_path
      path = File.join(tmp_dir, 'some_directory', 'new_file')
      command = CreateFileCommand.new(path) { 'some content' }

      command.execute

      assert File.exist? path
      assert File.read(path) == 'some content'

      command.undo

      refute File.exist? path
      refute Dir.exist? File.join(tmp_dir, 'some_directory')
      assert Dir.exist? tmp_dir
      in_project { assert_clean_project }
    end
  end
end
