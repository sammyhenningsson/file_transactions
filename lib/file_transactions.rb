# frozen_string_literal: true

require "file_transactions/version"

module FileTransactions
  class Error < StandardError; end
  # Your code goes here...
end

require 'file_transactions/base_command'
require 'file_transactions/change_file_command'
require 'file_transactions/create_directory_command'
require 'file_transactions/create_file_command'
require 'file_transactions/delete_file_command'
require 'file_transactions/move_file_command'

