class ImapAccount < ActiveRecord::Base
  
  has_many :accounts, :dependent => :nullify
  
  validates_presence_of :host, :username, :password
  validates_uniqueness_of :username, :scope => :host
  
  def name
    "#{host} (#{username})"
  end
  
end
