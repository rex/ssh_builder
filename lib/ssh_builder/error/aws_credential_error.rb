module SshBuilder
  module Error
    class AwsCredentialError < StandardError
      def initialize(msg = "No valid AWS credentials were found to load!")
        super
      end
    end
  end
end