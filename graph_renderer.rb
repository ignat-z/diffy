class GraphRenderer
  def initialize(relations, klasses)
    @relations = relations
    @klasses = klasses
  end

  def call
    [
      begin_header,
      klasses_info,
      relations_info,
      end_header
    ].flatten.join("\n")
  end

  private

  def begin_header
    [
      %(digraph graphname {),
      %(rankdir="LR")
    ]
  end

  def klasses_info
    @klasses.map do |klass|
      [wrap(klass), %Q{[label="#{klass}"]}].join(" ")
    end
  end

  def relations_info
    @relations.map do |klass, dependents|
      dependents.map do |child|
        [wrap(klass), wrap(child)].join(' -> ')
      end
    end
  end

  def end_header
    [
      %(})
    ]
  end

  def wrap(text)
    '"' + text + '"'
  end
end
