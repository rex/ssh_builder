class Step
  def self.write!(text)
    if $Log.info?
      print text
    end
  end

  def self.start(msg)
    self.write!("#{"i ".green} #{msg}...")
  end

  def self.complete
    self.write!("OK \n".green)
  end

  def self.fail(msg)
    self.write!("FAIL \n".red)
    $Log.error(msg)
  end
end