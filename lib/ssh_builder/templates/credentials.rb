module SshBuilder
  module Templates
    class Credentials < TemplateProvider
      self.template_file = "#{SshBuilder::App.template_path}/credentials.mustache"
    end
  end
end