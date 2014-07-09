require 'fileutils'
require 'mustache'

module SshBuilder
  class App
    class << self
      attr_reader :template_path, :runtime_path

      @timestamp = Time.now.strftime("%F_%T")

      def verbose?
        ARGV.include? "-v"
      end

      def boot
        @runtime_path = File.expand_path('..', File.dirname(__FILE__))
        @template_path = File.expand_path('./templates', File.dirname(__FILE__) )
        $Log = SshBuilder::Utils::Log.new(STDOUT)
        $Log.debug("ARGV: #{ARGV}")
        $fs = SshBuilder::Utils::Fs.new

        require 'ssh_builder/utils/step'
        require 'ssh_builder/utils/signals'

        $config_paths = {
          :personal => File.expand_path("~/.ssh/config_personal"),
          :ssh => File.expand_path("~/.ssh/config"),
          :credentials => File.expand_path("~/.ssh_builder")
        }
        $credentials = SshBuilder::Credentials.new

        $Log.info " > Personal config exists? #{SshBuilder::Config::Personal.exists?}"
        $Log.info " > Credentials config exists? #{SshBuilder::Config::Credentials.exists?}"
        $Log.info " > Ssh config exists? #{SshBuilder::Config::Ssh.exists?}"

        SshBuilder::Config::Personal.ensure
        SshBuilder::Config::Credentials.ensure
        SshBuilder::Config::Ssh.ensure

        Step.start("Testing Step")
        Step.complete

        puts SshBuilder::Config::Credentials.render({
          servers: [
            { name: 'Server 1', ip: '123.123.123.123' },
            { name: 'Server 2', ip: '123.123.123.123' }
          ]
        })
      end
    end
  end
end