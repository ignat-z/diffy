class AstBuilder
  def initialize(path)
    @filepaths = (path =~ /.rb$/ ? [path] : Dir["#{path}/**/*.rb"]).reject do |path|
      path =~ /vendor/ || path =~ /spec/ || path =~ /db/
    end
  end

  def call
    filepaths.map do |filepath|
      source_code = File.read(filepath)
      Parser::CurrentRuby.parse(source_code)
    end
  end

  private

  attr_reader :filepaths
end
