class ImapFilter < ActiveRecord::Base
  
  has_many :accounts, :dependent => :nullify
  
  validates_presence_of :name, :search, :subject, :filename
  validates_uniqueness_of :name
  
  def search_attr
    search.split("\n").map(&:strip)
  end
  
  def subject_regexp
    Regexp.new(subject)
  end
  
  def filename_regexp
    Regexp.new(filename)
  end
  
end
