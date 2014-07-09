module SshBuilder
  module Templates
    class Ssh < TemplateProvider
      self.template_file = "#{SshBuilder::App.template_path}/ssh.mustache"
    end
  end
end