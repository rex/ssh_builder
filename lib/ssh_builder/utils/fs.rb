require 'fileutils'

module SshBuilder
  module Utils
    class Fs
      def initialize
      end

      def read(path)
        output = ""
        File.open(File.expand_path(path), "r") do |f|
          f.each_line do |line|
            output += line
          end
        end

        output
      end

      def write(path, content)
        File.open(File.expand_path(path), "w") do |file|
          file.write content
        end
      end

      def exists?(path)
        File.exists? File.expand_path(path)
      end

      def generate_if_not_exists!(path)
        unless exists? path
          write path, ""
        end
      end

      def backup!(path)
        file = "#{path}.ssh_builder_#{SshBuilder::App.timestamp}.backup"
        FileUtils.move path, file
      end
    end
  end
end