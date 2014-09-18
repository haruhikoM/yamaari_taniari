module CellColor
  def self.yellow
    @yellow ||= NSColor.colorWithSRGBRed 1.0, green: 0.87, blue: 0.38, alpha: 1.0
  end

  def self.green
    @green ||= NSColor.colorWithSRGBRed 0.57, green: 0.88, blue: 0.3, alpha: 1.0
  end

  def self.blue
    @blue ||= NSColor.colorWithSRGBRed 0.39, green: 0.66, blue: 0.85, alpha: 1.0
  end

  def self.red
    @red ||= NSColor.colorWithSRGBRed 1.0, green: 0.37, blue: 0.38, alpha: 0.5
  end

  def self.orange
    @orange ||= NSColor.colorWithSRGBRed 1.0, green: 0.75, blue: 0.44, alpha: 0.5
  end

  def self.purple
    @purple ||= NSColor.colorWithSRGBRed 0.61, green: 0.27, blue: 0.72, alpha: 0.5
  end
end
