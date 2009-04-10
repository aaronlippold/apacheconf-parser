class Hash
  def add_without_overwrite(key, value)
    if self.keys.include?(key)
      self[key] = [self[key], value]
    else
      self[key] = value
    end
  end
end