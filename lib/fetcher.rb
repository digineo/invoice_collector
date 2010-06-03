module Fetcher
  
  class LoginException < Exception
  end
  
end

require_dependency RAILS_ROOT + '/lib/fetcher/invoice'