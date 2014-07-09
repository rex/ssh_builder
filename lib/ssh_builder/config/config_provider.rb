module SshBuilder
  module Config
    class ConfigProvider
      class << self
        @location = nil
        @template = nil

        def read
          $fs.read @location
        end

        def write(data)
          $fs.write @location, @template.render
        end

        def ensure
          $fs.generate_if_not_exists(@location, @template.render)
        end

        def exists?
          $fs.exists? @location
        end

        def debug
          {
            file: @template.template_file,
            path: @template.template_path,
            name: @template.template_name
          }.inspect
        end

        def generate(data = {})
          @template.render(data)
        end
      end
    end
  end
end