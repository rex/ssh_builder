module SshBuilder
  module Templates
    class TemplateProvider < Mustache
      self.template_path = SshBuilder::App.template_path
      @data = {}

      def self.build
        self.render @data
      end
    end
  end
end