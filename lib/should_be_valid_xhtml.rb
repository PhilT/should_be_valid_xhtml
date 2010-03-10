require 'md5'

module CustomValidaterMatchers
  class BeValidXhtml
    MARKUP_VALIDATOR_HOST = 'validator.w3.org'
    MARKUP_VALIDATOR_PATH = '/check'

    def matches?(html)
      http = Net::HTTP.start(MARKUP_VALIDATOR_HOST)
      response = http.post2(MARKUP_VALIDATOR_PATH, "fragment=#{CGI.escape(html)}&prefill=1&prefill_doctype=xhtml10")
      doc = Nokogiri::HTML(response.body)
      @message = ''
      doc.css('.msg_err').each do |error|
        if error.css('.err_type img').first['title'] == 'Error'
          position = error.css('em').first.text.split("\n").collect{|line|line.strip}.join(' ')
          message = error.css('.msg').text
          @message << "#{position}: #{message}\n"
        end
      end
      @message.empty?
    end

    def failure_message_for_should
      @message
    end

    def failure_message_for_should_not
      @message
    end

    def description
      "be valid XHTML"
    end

  end

  def be_valid_xhtml
    BeValidXhtml.new
  end

end

