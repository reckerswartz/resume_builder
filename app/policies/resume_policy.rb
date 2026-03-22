class ResumePolicy < ApplicationPolicy
  def index?
    authenticated?
  end

  def show?
    owner?
  end

  def create?
    authenticated?
  end

  def update?
    owner?
  end

  def destroy?
    owner?
  end

  def duplicate?
    owner?
  end

  def export?
    owner?
  end

  def download?
    owner?
  end

  class Scope < Scope
    def resolve
      return scope.none unless user
      return scope.all if user.admin?

      scope.where(user: user)
    end
  end

  private
    def owner?
      admin? || record.user_id == user&.id
    end
end
