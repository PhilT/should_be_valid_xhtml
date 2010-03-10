require 'md5'

class Hash
  def to_s
    self.map{|key, value| "#{key}=#{value}"}.join('&')
  end
end

module CustomValidaterMatchers
  class BeValidXhtml
    MARKUP_VALIDATOR_HOST = 'validator.w3.org'
    MARKUP_VALIDATOR_PATH = '/check'

    def initialize(fragment, doctype)
      @params = {:output => 'soap12'}
      @params[:prefill] = '1' if fragment
      @params[fragment ? :prefill_doctype : :doctype] = doctype
    end

    def matches?(html)
      @params[:fragment] = CGI.escape(html)

      http = Net::HTTP.start(MARKUP_VALIDATOR_HOST)
      response = http.post2(MARKUP_VALIDATOR_PATH, @params.to_s)
      doc = Nokogiri::XML(response.body)
      @message = ''
      m_namespace = {'m' => 'http://www.w3.org/2005/10/markup-validator'}
      doc.xpath('//m:error', m_namespace).each do |error|
        line = error.xpath('m:line', m_namespace).text
        column = error.xpath('m:col', m_namespace).text
        message = error.xpath('m:message', m_namespace).text
        @message << "Line #{line}, Column #{column}: #{message}\n"
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

  def be_valid_xhtml(fragment = true)
    BeValidXhtml.new(fragment, 'xhtml10')
  end

  def be_valid_html(fragment = true)
    BeValidHtml.new(fragment, 'html401')
  end

end

