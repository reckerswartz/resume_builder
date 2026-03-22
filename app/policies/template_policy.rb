class TemplatePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    admin?
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end

  class Scope < Scope
    def resolve
      return scope.none unless user
      return scope.all if user.admin?

      active_scope = scope.active
      active_scope.exists? ? active_scope : scope.all
    end
  end
end
