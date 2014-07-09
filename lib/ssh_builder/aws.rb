module SshBuilder
  class Aws
    def ec2(credentials)
      AWS::EC2.new(
        :access_key_id => credentials[:access_key_id],
        :secret_access_key => credentials[:secret_access_key]
      )
    end
  end
end