class Account < ActiveRecord::Base
  
  has_many :invoices, :order => 'date DESC', :dependent => :destroy do
    def sum_amount
      collect{|i| i.amount.to_f }.sum
    end
  end
  
  validates_presence_of :module, :username, :password
  
  default_scope :order => 'module, username'
  named_scope :active, :conditions => 'active=TRUE'
  
  # Holt Rechnungen von allen Accounts ab
  def self.fetch_all
    total = 0
    for account in active.all
      print "#{account.module} (#{account.username}) ... "
      i      = account.fetch_invoices.count
      total += i
      puts " #{i} neu"
    end
    puts "#{total} neue Rechnungen insgesamt"
    true
  end
  
  # lädt neue Rechnungen runter
  def fetch_invoices
    
    invoices = []
    
    # einloggen
    fetcher.login
    
    begin
      list = fetcher.list
      print "#{list.count} Rechnungen gefunden,"
      
      for invoice in list
        # existiert schon?
        next if self.invoices.find_by_number(invoice.number)
        
        transaction do
          i = self.invoices.create! \
            :number    => invoice.number,
            :date      => invoice.date,
            :amount    => invoice.amount,
            :original  => invoice.original,
            :signature => invoice.signature
          
          # Drucken, falls gewünscht
          i.print if autoprint?
          
          invoices << i
        end
      end
    ensure
      # ausloggen
      fetcher.logout
    end
    
    invoices
  end
  
  def fetcher
    @fetcher ||= "Fetcher::#{self.module}".constantize.new(self)
  end
  
end
