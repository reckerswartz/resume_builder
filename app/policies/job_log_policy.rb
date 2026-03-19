class JobLogPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
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
