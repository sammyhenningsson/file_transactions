# frozen_string_literal: true

module FileTransactions
  class Error < StandardError; end
  class Rollback < Error; end
end
