# encoding: utf-8

require 'logger'
require 'ssh_builder/colorizer'

module SshBuilder
  class Log
    def initialize(output_stream)
      @instance = Logger.new(output_stream)

      format_date
      set_prompts

      @instance
    end

    def format_date(format = '%Y-%m-%d %H:%M:%S')
      @instance.datetime_format = format
    end

    def set_prompts
      @instance.formatter = proc do |severity, datetime, progname, msg|
        case severity.downcase
          when "debug"
            prompt = "☰ ".blue
          when "info"
            prompt = "i ".green
          when "warn"
            prompt = "⚑ ".magenta
          when "error"
            prompt = "⁢⁢⁢⁢⁢⁢✖ ".red
          when "fatal"
            prompt = ":( ".red
          else
            prompt = "✓ ".blue
        end

        ( ARGV.include? "-e" ) ? "#{prompt} #{datetime.strftime("%Y/%m/%d %H:%M:%S")} \n » #{msg.strip} \n\n" : "#{prompt} #{msg.strip} \n"
      end
    end

    def debug(msg)
      text = @instance.debug(msg)
      puts "Debug text? #{text}"
    end

    def info(msg)
      @instance.info(msg)
    end

    def warn(msg)
      @instance.warn(msg)
    end

    def error(msg)
      @instance.error(msg)
    end

    def fatal(msg)
      @instance.fatal(msg)
    end

    def add(severity, msg)
      @instance.add(severity, msg)
    end
  end
end