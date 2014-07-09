module SshConfig
  class Helpers
    def self.pounds(n)
      output = ""
      n.times do
        output += "#"
      end
      output
    end
  end
end