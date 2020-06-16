# frozen_string_literal: true

require "test_helper"

module FileTransactions
  class TransactionTest < Test
    def setup
      @cmd1 = CreateFileCommand.new('new_file') { 'hello' }
      @cmd2 = ChangeFileCommand.new('new_file') { 'world' }
    end

    def test_that_transaction_can_run
      in_project do
        FT.transaction do
          @cmd1.execute
          @cmd2.execute
        end

        assert_file_content 'new_file', 'world'
      end
    end

    def test_that_transaction_rolls_back_on_exception
      in_project do
        error = assert_raises(RuntimeError) do
          FT.transaction do
            @cmd1.execute
            @cmd2.execute
            raise 'expected failure'
          end
        end

        assert_equal 'expected failure', error.message
        assert_clean_project
      end
    end

    def test_that_exception_can_be_caught_without_rollback
      in_project do
        FT.transaction do
          @cmd1.execute
          raise 'failure'
          @cmd2.execute
        rescue StandardError
          nil
        end

        assert_file_content 'new_file', 'hello'
      end
    end

    def test_that_exception_can_be_reraised_and_cause_rollback
      in_project do
        error = assert_raises(RuntimeError) do
          FT.transaction do
            @cmd1.execute
            raise 'expected failure'
            @cmd2.execute
          rescue StandardError
            raise
          end
        end

        assert_equal 'expected failure', error.message
        assert_clean_project
      end
    end

    def test_that_transactions_can_be_nested
      in_project do
        FT.transaction do
          @cmd1.execute
          FT.transaction do
            @cmd2.execute
          end
        end

        assert_file_content 'new_file', 'world'
      end
    end

    def test_that_and_exceptions_caught_in_inner_transaction_rolls_back_all_transactions
      in_project do
        error = assert_raises(RuntimeError) do
          FT.transaction do
            @cmd1.execute
            FT.transaction do
              @cmd2.execute
              raise 'crash'
            end
          end
        end

        assert_equal 'crash', error.message
        assert_clean_project
      end
    end

    def test_that_an_inner_transaction_thats_completed_gets_rolled_back_on_error
      in_project do
        error = assert_raises(RuntimeError) do
          FT.transaction do
            @cmd1.execute
            FT.transaction do
              CreateFileCommand.execute('another_file') { 'hello again' }
            end
            raise 'crash'
          end
        end

        assert_equal 'crash', error.message
        assert_clean_project
      end
    end
  end
end
