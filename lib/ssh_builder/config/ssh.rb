module SshBuilder
  module Config
    class Ssh < ConfigProvider
      @location = $config_paths[:ssh]
      @template = SshBuilder::Templates::Ssh
    end
  end
end