require 'pry'
require 'parser/current'
require_relative './class_definition_processor'
require_relative './graph_renderer'
require_relative './graph_builder'


builder = GraphBuilder.new(ARGV.first || raise('PARAM!!!1'))
classes = builder.call

classes.sort_by(&:name).each do |ruby_class|
  puts " -- #{ruby_class.name}:"
  puts ruby_class.dependencies.map(&:name).to_s
  puts "\n"
  # puts [
  #   'type: ',   ruby_class.type.to_s.center(6),
  #               ruby_class.name.center(30),
  #   '<',        (ruby_class.inherited_from.last&.name || '""').to_s.center(30),
  #   'scope:',   (ruby_class.scope.name).to_s.center(10),
  #   'include:', (ruby_class.includes.map(&:name)).to_s.center(10),
  #   'extend:',  (ruby_class.extends.map(&:name)).to_s.center(10),
  #   'constants:', (ruby_class.constants.map(&:name)).to_s.center(10),
  #   (ruby_class.external ? "external" : "").to_s.center(10)
  # ].join
end

# puts GraphRenderer.new(processor.klass_dependencies, processor.klasses).call
