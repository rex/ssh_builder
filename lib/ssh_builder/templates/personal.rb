module SshBuilder
  module Templates
    class Personal < TemplateProvider
      self.template_file = "#{SshBuilder::App.template_path}/personal.mustache"
    end
  end
end