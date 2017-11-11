require_relative 'ruby_class.rb'

# TODO: add lazy loading
# TODO: complex names resolving

class ConstDefinitionFinder
  def initialize(full_const_name, scope)
    @full_const_name = full_const_name
    @scope = scope
  end

  def call
    return if !full_const_name || !scope
    constant = find&.last

    constant ? constant : RubyClass.build_external(full_const_name, scope)
  end

  private

  attr_reader :full_const_name, :scope

  def find
    full_const_name.split("::").inject([scope]) do |scopes, const_name|
      constant = scope_lookup(const_name, scopes.last)
      constant ||= superclass_chain_lookup(const_name, scopes.last)

      constant ? scopes + [constant] : break
    end
  end

  def scope_lookup(const_name, current_scope)
    return if current_scope == :end_of_scope
    constant = find_in_scope(const_name, current_scope)
    constant || scope_lookup(const_name, current_scope.scope)
  end

  def superclass_chain_lookup(const_name, current_scope)
    result = current_scope.includes.find do |parent|
      constant = find_in_scope(const_name, parent)
      break constant if constant
    end

    result || current_scope.inherited_from.find do |parent|
      constant = find_in_scope(const_name, parent)
      break constant if constant
    end
  end

  def find_in_scope(const_name, current_scope)
    return if !const_name || !current_scope
    current_scope.constants.find { |c| c.name == const_name }
  end
end
