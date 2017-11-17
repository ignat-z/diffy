require 'pry'
require 'git'
require 'parser/current'
require_relative './class_definition_processor'
require_relative './graph_renderer'
require_relative './graph_builder'


builder = GraphBuilder.new(ARGV.first || raise('PARAM!!!1'))
classes = builder.call

# classes.sort_by(&:name).each do |ruby_class|
#   puts " -- #{ruby_class.full_name}:"
#   puts ruby_class.dependencies.map(&:full_name)
#   puts "\n"
#   # puts [
#   #   'type: ',   ruby_class.type.to_s.center(6),
#   #               ruby_class.name.center(30),
#   #   '<',        (ruby_class.inherited_from.last&.name || '""').to_s.center(30),
#   #   'scope:',   (ruby_class.scope.name).to_s.center(10),
#   #   'include:', (ruby_class.includes.map(&:name)).to_s.center(10),
#   #   'extend:',  (ruby_class.extends.map(&:name)).to_s.center(10),
#   #   'constants:', (ruby_class.constants.map(&:name)).to_s.center(10),
#   #   (ruby_class.external ? "external" : "").to_s.center(10)
#   # ].join
# end

# git.gblob('gems.locked').log.last.gtree.blobs.values.first.contents

l = classes.inject({}) { |result, value| result.merge(value.full_name => value.dependencies.map(&:full_name)) }

git = Git.open('~/Work/baypoint-benefits/diesel/')
changed = git.log.first.diff_parent.map(&:path).reject do |path|
  path =~ /vendor/ || path =~ /spec/ || path =~ /db/ || path !~ /\.rb/
end
blobs = git.log.first.gtree.full_tree.map { |x| x.split("\t") }.select { |x| changed.include?(x.last) }.map { |x| x[0].split(" ").last }
source_files = blobs.map { |blob| git.gblob(blob).contents }
asts = source_files.map {|x| Parser::CurrentRuby.parse(x) }

puts GraphRenderer.new(l, classes.map(&:full_name)).call
