require 'md5'
require 'nokogiri'

class Hash
  def to_s
    self.map{|key, value| "#{key}=#{value}"}.join('&')
  end
end

module ValidaterMatchers
  class BeValidXhtml
    MARKUP_VALIDATOR_HOST = 'validator.w3.org'
    MARKUP_VALIDATOR_PATH = '/check'

    def initialize(fragment, doctype)
      @params = {:output => 'soap12'}
      @params[:prefill] = '1' if fragment
      @params[fragment ? :prefill_doctype : :doctype] = doctype
    end

    def matches?(html)
      hash = MD5.hexdigest(html)

      cache_dir = File.join('tmp', 'should_be_valid_cache')
      cache_file = File.join(cache_dir, hash)
      if File.exists?(cache_file)
        @message = File.read(cache_file)
      else
        response_body = validate(html)
        FileUtils.mkdir_p(cache_dir) unless File.exists?(cache_dir)
        @message = parse(response_body)
        File.open(cache_file, "w") {|f| f.write(@message)}
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

  private
    def validate(html)
      @params[:fragment] = CGI.escape(html)
      http = Net::HTTP.start(MARKUP_VALIDATOR_HOST)
      http.post2(MARKUP_VALIDATOR_PATH, @params.to_s).body
    end

    def parse(response)
      doc = Nokogiri::XML(response)
      messages = ''
      m_namespace = {'m' => 'http://www.w3.org/2005/10/markup-validator'}
      doc.xpath('//m:error', m_namespace).each do |error|
        line = error.xpath('m:line', m_namespace).text
        column = error.xpath('m:col', m_namespace).text
        message = error.xpath('m:message', m_namespace).text
        messages << "Line #{line}, Column #{column}: #{message}\n"
      end
      messages
    end
  end

  def be_valid_xhtml(fragment = true)
    BeValidXhtml.new(fragment, 'xhtml10')
  end

  def be_valid_html(fragment = true)
    BeValidHtml.new(fragment, 'html401')
  end

end

