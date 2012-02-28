require 'message_helper'

# Make sure integration tests are only run against the pre-configured PAPER ACCOUNT
def verify_account
  return OPTS[:account_verified] if OPTS[:account_verified]

  puts
  puts 'WARNING: MAKE SURE TO RUN INTEGRATION TESTS AGAINST IB PAPER ACCOUNT ONLY!'
  puts 'WARNING: FINANCIAL LOSSES MAY RESULT IF YOU RUN TESTS WITH REAL IB ACCOUNT!'
  puts 'WARNING: YOU HAVE BEEN WARNED!'
  puts
  puts 'Configure your connection to IB PAPER ACCOUNT in spec/spec_helper.rb'
  puts

  account = OPTS[:connection][:account] || OPTS[:connection][:account_name]
  raise "Please configure IB PAPER ACCOUNT in spec/spec_helper.rb" unless account

  connect_and_receive :AccountValue
  @ib.send_message :RequestAccountData, :subscribe => true

  wait_for { received? :AccountValue }
  raise "Unable to verify IB PAPER ACCOUNT" unless received? :AccountValue

  received = @received[:AccountValue].first.account_name
  raise "Connected to wrong account #{received}, expected #{account}" if account != received

  close_connection
  OPTS[:account_verified] = true
end
