
class Mechanize::Page
  def at!(path)
    at(path) || raise(ArgumentError.new("Element '#{path}' nicht gefunden"))
  end
end

class Nokogiri::XML::Node
  def at!(path)
    at(path) || raise(ArgumentError.new("Element '#{path}' nicht gefunden"))
  end
end
