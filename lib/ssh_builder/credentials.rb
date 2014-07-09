module SshBuilder
  class Credentials
    class << self
      attr_accessor :all

      @all = []

      def exists?
        false
      end

      def load
        load_env
        load_file
      end

      def dump
        ENV.each_pair do |key,val|
          puts " > #{key} - #{val}"
        end
      end

      def store(credentials)
        unless @all.count {|cred| cred[:access_key_id] == credentials[:access_key_id]} > 0
          @all.push({
            :access_key_id => credentials[:access_key_id],
            :secret_access_key => credentials[:secret_access_key]
          })
        else
          $Log.debug("Credentials already loaded: #{credentials.inspect}")
        end
      end

      def load_env
        $Log.debug env_pairs.inspect
        if ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY']
          store(
            :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
            :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
          )
        else
          $Log.error("No AWS credentials found in environment")
          nil
        end
      end

      def env_pairs
        access_keys = []
        secret_keys = []
        ENV.each_pair do |key,val|
          if key.include? "AWS_ACCESS_KEY"
            access_keys.push key
          elsif key.include? "AWS_SECRET_ACCESS_KEY"
            secret_keys.push key
          elsif key.include? "AWS_SECRET_KEY"
            secret_keys.push key
          end
        end

        {
          access_keys: access_keys,
          secret_keys: secret_keys
        }
      end

      def load_file
        #
      end
    end
  end
end