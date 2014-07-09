#!/usr/bin/env ruby

class EnvMissing < Exception
end

begin
  require 'colorize'
  require 'optparse'
  require 'aws-sdk'
  require 'fileutils'
  raise EnvMissing unless ENV['YOUTOO_AWS_ACCESS_KEY']
  raise EnvMissing unless ENV['YOUTOO_AWS_SECRET_KEY']
rescue LoadError
  puts "Running this program requires the following gems to be installed:
  - colorize
  - aws-sdk
Fix this problem by installing the gems with this command:
  gem install colorize aws-sdk
"
  exit 1
rescue EnvMissing
  puts "This program requires two environment variables be set and valid:
  YOUTOO_AWS_ACCESS_KEY
  YOUTOO_AWS_SECRET_KEY
Add these keys with their proper values to your .zshrc/.bashrc, open a new tab, and try again."
  exit 1
end

$ec2 = AWS::EC2.new(
  :access_key_id => ENV['YOUTOO_AWS_ACCESS_KEY'],
  :secret_access_key => ENV['YOUTOO_AWS_SECRET_KEY']
)

class SSHBuilder
  def initialize(opts)
    @backup_enabled = opts[:backup]
    @detailed = opts[:detailed]
  end

  def log(msg)
    puts " #{'>'.green} #{msg.blue}"
  end

  def pounds(n)
    output = ""
    n.times do
      output += "#"
    end

    output
  end

  def date
    Time.now.strftime("%F_%T")
  end

  def config_path
   File.expand_path("~/.ssh/config")
  end

  def personal_config_path
   "#{config_path}_personal"
  end

  def backup_config_path
   "#{config_path}.sshbuilder_#{date}.backup"
  end

  def get_name(instance)
    instance.tags.to_h.fetch('Name', '').to_s
  end

  def tag_html(instance)
    tag_template = "
#   %{key}: %{val}"
    output = ""
    instance.tags.each do |key,val|
      output += tag_template % { key: key, val: val }
    end

    output
  end

  def header
  "#{pounds 40}
# SSH Config
#
# Built on: %{date}
#{pounds 40}

"
  end

  def personal_config
    output = ""
    File.open(personal_config_path, "r") do |f|
      f.each_line do |line|
        output += "#{line}"
      end
    end

    output
  end

  def youtoo_config
    output = ""
    instance_template = "
Host youtoo-%{host}
  HostName %{hostname}
  User ec2-user
  Port %{port}
  PasswordAuthentication no
  IdentityFile ~/.ssh/infrastructure@youtoo.key
  "
    detailed_instance_template = "
# Instance Name:        %{host}
# Instance ID:          %{id}
# Instance Type:        %{type}
# Launched:             %{launch_time}
# Availability Zone:    %{availability_zone}
# Tags: %{tags}
Host youtoo-%{host}
  HostName %{hostname}
  User ec2-user
  Port %{port}
  PasswordAuthentication no
  IdentityFile ~/.ssh/infrastructure@youtoo.key
"
    region_template = "
  #{pounds 40}
  # Youtoo AWS Region: %{region} (%{count} instances)
  #{pounds 40}
  "

    AWS.memoize do
      $ec2.regions.each do |region|
        log "Parsing region: #{region.name}"
        instance_count = region.instances.map(&:id).length

        unless instance_count == 0
          log " - Found #{instance_count} instances"
          output += region_template % { region: region.name, count: instance_count }

          region.instances.each do |instance|
            if instance.status == :running
              name = get_name(instance)

              case name
              when "aspera-01"
                port = 33001
              when "storage-02"
                port = 46732
              else
                port = 22
              end

              template = @detailed ? detailed_instance_template : instance_template
              output += template % {
                region: region.name,
                host: name,
                hostname: instance.ip_address,
                port: port,
                tags: tag_html(instance),
                id: instance.id,
                type: instance.instance_type,
                launch_time: instance.launch_time,
                availability_zone: instance.availability_zone
              }
            end
          end
        end
      end
    end

    output
  end

  def build_config
    log "Building SSH config file"
    @compiled_config = "#{header % {date: date}}
#{pounds 60}
# Personal SSH Config
#{pounds 60}
#{personal_config}

#{pounds 60}
# Youtoo AWS Config
#{pounds 60}
#{youtoo_config}"
    log "SSH config file built"
  end

  def do_config_backup
    log "Backing up existing config: #{config_path} > #{backup_config_path}"
    FileUtils.move config_path, backup_config_path
    log "Config backed up to #{backup_config_path}"
  end

  def write_config
    log "Writing config to #{config_path}"
    File.open(config_path, "w") do |file|
      file.write(@compiled_config)
    end
    log "Config written to #{config_path}"
  end

  def generate
    log "Generating SSH config (detailed: #{@detailed}, backup_enabled: #{@backup_enabled})"
    build_config
    do_config_backup if @backup_enabled
    write_config
    log "SSH config generated successfully!"
  end
end

options = {
  detailed: false,
  backup: false
}

opt_parser = OptionParser.new do |opts|
  opts.banner = "Usage: ruby build-ssh-config.rb [options]"

  opts.on("-d","--detailed","Include detailed instance info") do |d|
    options[:detailed] = d
  end

  opts.on("-b","--backup","Backup existing ~/.ssh/config") do |b|
    options[:backup] = b
  end

  opts.on("-h","--help","Show this help message") do |h|
    puts opts
    exit 0
  end
end

begin
  opt_parser.parse!
rescue OptionParser::InvalidOption => e
  puts e
  puts opt_parser
  exit 1
end

builder = SSHBuilder.new(options)
builder.generate