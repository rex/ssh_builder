require 'no_require'

require_root = File.expand_path('../../../', File.dirname(__FILE__))
NoRequire.new(require_root, ['lib'])