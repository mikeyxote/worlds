class Team < ActiveRecord::Base
  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships, source: :user
  has_many :weeklies, dependent: :destroy
  
  def add_member user
    Membership.create(user: user,
                      team: self)
  end
  
  def delete_member user
    Membership.delete.where(user: user,
                            team: self)
  end
end
