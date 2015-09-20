# encoding: UTF-8

module Fetcher

  class OMG < Base

    START = 'https://shop.omg.de/my-account/'

    def login
      page = get(START)
      page = @agent.post "/WebAjaxBase.php",
        "Object"      => "myaccount@WebMyAccountLogin",
        "result_id"   => "PlentyWebMyAccountLoginErrorPane",
        "ActionCall"  => "login",
        "AccountShow" => "MyAccount",
        "email"       => @account.username,
        "pwd"         => @account.password


      page = get '/my-account/'

      # Login fehlgeschlagen?
      raise LoginException unless page.body.include?("Mein Konto")
    end

    def list
      invoices = []

      page = action \
        "ActionCall" => "showOrders",
        "Object"     => "myaccount@WebMyAccountDisplayOrders"

      page.search(".PlentyWebMyAccountDisplayOrdersContainer").to_a.each do |order|
        id = order.to_s.match(/orderId=(\d+)/)[1]
        subpage = action \
          "ActionCall"  => "open",
          "Object"      => "myaccount@WebMyAccountOrderOverview",
          "orderId"     => id

        invoice_link = subpage.at(".PlentyWebMyAccountOrderOverviewInvoiceValue a")
        next unless invoice_link

        href   = invoice_link["href"]
        number = @agent.head(href).response["content-disposition"].match(/\d+/)[0]

        invoices << build_invoice(
          href:    href,
          number:  number,
          date:    subpage.at(".PlentyWebMyAccountOrderOverviewDeliveryValue").text.strip,
          amount:  subpage.at(".PlentyTotalAmountDetail").text,
        )
      end

      invoices
    end

    def action(params)
      page = @agent.post "/WebAjaxBase.php", params
      Nokogiri::HTML("<html><body>" + page.at("data").text + "</body></html>")
    end

    def logout
    end

  end

end
