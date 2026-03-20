class JobLogPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin?
  end

  def retry?
    admin?
  end

  def discard?
    admin?
  end

  def requeue?
    admin?
  end

  class Scope < Scope
    def resolve
      admin? ? scope.all : scope.none
    end

    private
      def admin?
        user&.admin?
      end
  end
end
