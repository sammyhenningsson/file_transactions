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

        assert_file_exist 'new_file'

        command.undo

        refute_file_exist 'new_file'
        assert_clean_project
      end
    end

    def test_that_it_creates_a_file_with_content_from_block
      command = CreateFileCommand.new('new_file') { 'some content' }

      in_project do
        command.execute

        assert_file_exist 'new_file'
        assert_file_content 'new_file', 'some content'

        command.undo

        refute_file_exist 'new_file'
        assert_clean_project
      end
    end

    def test_that_it_creates_file_and_directories
      command = CreateFileCommand.new('dir1/dir2/new_file') { 'some content' }

      in_project do
        command.execute

        assert_file_exist 'dir1/dir2/new_file'
        assert_file_content 'dir1/dir2/new_file', 'some content'

        command.undo

        refute_file_exist 'dir1/dir2/new_file'
        refute_dir_exist 'dir1'
        assert_clean_project
      end
    end

    def test_that_it_creates_a_file_with_absolute_path
      path = File.join(tmp_dir, 'some_directory', 'new_file')
      command = CreateFileCommand.new(path) { 'some content' }

      command.execute

      assert_file_exist path
      assert_file_content path, 'some content'

      command.undo

      refute_file_exist path
      refute_dir_exist File.join(tmp_dir, 'some_directory')
      assert_dir_exist tmp_dir
      in_project { assert_clean_project }
    end
  end
end
