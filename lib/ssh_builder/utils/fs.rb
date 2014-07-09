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

      def generate_if_not_exists!(path, content = "")
        Step.start("Ensuring #{path} exists")
        unless exists? path
          Step.warn
          Step.start("#{path} does not exist, creating")
          write path, content
          Step.complete
          Step.start("Ensuring #{path} was created successfully")
          if exists? path
            Step.complete
          else
            Step.fail "File #{path} was unable to be created!"
          end
        else
          Step.complete
        end
      end

      def backup!(path)
        Step.start("Creating backup of #{path}")
        file = "#{path}.ssh_builder_#{SshBuilder::App.timestamp}.backup"
        FileUtils.move path, file
        Step.complete
      end
    end
  end
end