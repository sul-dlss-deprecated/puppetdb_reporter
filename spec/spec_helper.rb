$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'coveralls'
Coveralls.wear!

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)
