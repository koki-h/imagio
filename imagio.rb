require 'mechanize'
require "base64"
class Imagio
  def initialize(imagio_address)
    @TopPage        = "http://#{$IMAGIO_ADDRESS}/web/guest/ja/websys/webArch/topPage.cgi"
    @FaxDocListPage = "http://#{$IMAGIO_ADDRESS}/web/guest/ja/webdocbox/faxDocListPage.cgi"
    @agent = Mechanize.new
    @agent.post(@TopPage) #まずトップページにアクセスしないとエラーになる
  end

  def download_fax_doc(recv_date = nil)
    #与えられた日付に受信した文書をPDF形式でダウンロードする
    page = @agent.post(@FaxDocListPage)
    pdf_post_data(page.body).each do |d|
      $stderr.puts d[:date]
      break if d[:date] !~ /#{recv_date}/
      pdf = page.form_with(:name => "DocboxListDownload") do |form|
        form.action = d[:action]
        form.method = "post"
        form.id = d[:id]
        form.el = d[:el]
        form.jt = d[:jt]
      end.submit
      d[:pdf] = pdf.body
      yield(d)
    end
  end

  include Base64
  def pdf_post_data(page)
    data = [] 
    page.scan(/<input type="hidden" name="(Pdf_url.+?)" value="(.+?)"/) do |pdf_url|
      value = pdf_url[1].split(/\?/)
      action     = value[0]
      enc_data   = value[1]
      dec_data   = decode64(enc_data)
      split_data = dec_data.scan(/id=(.+?)&jt=(.+?)&el=(.+?)$/)
      data << {
        _name: pdf_url[0],
        _url: pdf_url[1],
        _enc: enc_data,
        _dec: dec_data,
        action: action,
        id: split_data[0][0],
        jt: split_data[0][1],
        el: split_data[0][2],
      }
    end
    date_strings = page.scan(/name="ListThumbnail" alt="(.+?) .+?\[(.+?)  .+?\]"/)
    date_strings.map!{|str| "#{str[1]} (#{str[0]})"}
    data.each_with_index do|d,i|
      d[:date] = date_strings[i]
    end
  end
end

if $0 == __FILE__
  require "pp"
  open("imagio_pages/aaa.html") do |f|
    pp Imagio.new.pdf_post_data(f.read)
  end
end
