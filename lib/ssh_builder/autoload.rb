require 'no_require'

require_root = File.expand_path('../../', File.dirname(__FILE__))
puts "require_root: #{require_root}"
NoRequire.new(require_root, ['lib'])