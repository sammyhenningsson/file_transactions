# frozen_string_literal: true

require "test_helper"

module FileTransactions
  class ChangeFileCommandTest < Test
    def setup
      in_project do
        File.open('some_file', 'w') { |f| f.write('original content') }
      end
    end

    def test_that_it_can_change_a_file_and_undo_it
      command = ChangeFileCommand.new('some_file') do
        File.open('some_file', 'w') { |f| f.write('new content') }
      end

      in_project do
        command.execute

        assert File.exist? 'some_file'
        assert File.read('some_file') == 'new content'


        command.undo

        assert File.exist? 'some_file'
        assert File.read('some_file') == 'original content'
      end
    end

    def test_that_it_change_a_file_with_content_from_block
      command = ChangeFileCommand.new('some_file') { 'new content' }

      in_project do
        command.execute

        assert File.exist? 'some_file'
        assert File.read('some_file') == 'new content'


        command.undo

        assert File.exist? 'some_file'
        assert File.read('some_file') == 'original content'
      end
    end
  end
end
