class GraphRenderer
  def initialize(relations, klasses, changes)
    @relations = relations
    @klasses = klasses
    @changes = changes
  end

  def call
    [
      begin_header,
      klasses_info,
      relations_info,
      changes_info,
      end_header
    ].flatten.join("\n")
  end

  private

  def changes_info
    @changes.map do |klass, dependents|
      dependents.map do |child|
        [wrap(klass), ' -> ', wrap(child), '[color="green"]'].join()
      end
    end
  end

  def begin_header
    [
      %(digraph graphname {),
      %(rankdir="LR")
    ]
  end

  def klasses_info
    @klasses.map do |klass|
      green = @changes.keys.include?(klass) ? 'color="green"' : ''
      [wrap(klass), %Q{[label="#{klass}" #{green}]}].join(" ")
    end
  end

  def relations_info
    @relations.map do |klass, dependents|
      dependents.map do |child|
        if @changes[klass].to_a.include?(child)
          ''
        else
          [wrap(klass), wrap(child)].join(' -> ')
        end
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
