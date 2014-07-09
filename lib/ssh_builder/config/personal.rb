module SshBuilder
  module Config
    class Personal < ConfigProvider
      @location = $config_paths[:personal]
      @template = SshBuilder::Templates::Personal
    end
  end
end