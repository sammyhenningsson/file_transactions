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
  def self.transaction(&block)
    Transaction.run(&block)
  end
end
