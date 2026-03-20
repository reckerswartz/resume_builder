class PhotoAssetPolicy < ApplicationPolicy
  def create?
    owner?
  end

  def destroy?
    owner?
  end

  def update?
    owner?
  end

  def show?
    owner?
  end

  class Scope < Scope
    def resolve
      return scope.none unless user
      return scope.all if user.admin?

      scope.joins(:photo_profile).where(photo_profiles: { user_id: user.id })
    end
  end

  private
    def owner?
      admin? || record.photo_profile.user_id == user&.id
    end
end
