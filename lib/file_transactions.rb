# frozen_string_literal: true

require "file_transactions/version"
require 'file_transactions/error'
require 'file_transactions/base_command'
require 'file_transactions/change_file_command'
require 'file_transactions/create_directory_command'
require 'file_transactions/create_file_command'
require 'file_transactions/delete_file_command'
require 'file_transactions/move_file_command'
require 'file_transactions/transaction'

module FileTransactions
  # This method runs the block inside a transaction
  #
  # ==== Examples
  #
  #   FileTransactions.transaction do
  #     CreateFileCommand.execute('new_file') { 'hello' }
  #     ChangeFileCommand.execute('new_file') { 'world' }
  #   end
  #  
  #   FileTransactions.transaction do
  #     CreateFileCommand.execute('new_file') { 'hello' }
  #     DeleteFileCommand.execute('some_file')
  #  
  #     # An exception will make the transaction be rolled back. E.g
  #     # 'new_file' will be removed again and 'some_file' will be restored
  #     raise "foobar"
  #   end
  #  
  #   # Create an alias for FileTransactions
  #   FT = FileTransactions
  #
  #   FT.transaction do
  #     CreateFileCommand.execute('new_file') { 'hello' }
  #  
  #     FT.transaction do
  #       ChangeFileCommand.execute('new_file') { 'world' }
  #  
  #       # This rolls back the current transaction but not the outer transaction
  #       raise FT::Rollback
  #     end
  #   end
  def self.transaction(&block)
    Transaction.run(&block)
  end
end
