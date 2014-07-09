module SshBuilder
  module Config
    class Credentials < ConfigProvider
      @location = $config_paths[:credentials]
      @template = SshBuilder::Templates::Credentials
    end
  end
end