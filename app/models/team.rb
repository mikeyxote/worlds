class Team < ActiveRecord::Base
  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships, source: :user
  has_many :weeklies, dependent: :destroy
  
  def add_member user
    Membership.create(user: user,
                      team: self)
  end
  
  def drop_member user
    Membership.where(user: user,
                    team: self).destroy_all
  end
end
