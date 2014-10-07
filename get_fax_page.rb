require 'pp'
require 'date'
require './imagio.rb'
require './send_mail.rb'

include FileTest
IMAGIO_ADDRESS = '192.168.11.200'
PDF_DIR = 'pdf'

def today
  d = Date.today
  "#{d.year}/#{d.month}/#{d.day}"
end

def yesterday
  d = Date.today - 1
  "#{d.year}/#{d.month}/#{d.day}"
end

saved_files = []
imagio = Imagio.new(IMAGIO_ADDRESS)
yesterday = "2014/10/3"
puts yesterday
imagio.download_fax_doc(yesterday) do |down_data|
    pdf_filename = down_data[:date].gsub("/","-").gsub(":","") + ".pdf"
    pdf_filename = "#{PDF_DIR}/#{pdf_filename}"
    unless File.exist?(pdf_filename)
        open(pdf_filename, "wb"){|f| f.print down_data[:pdf]}
        saved_files << pdf_filename
    end
end

saved_files.each do |fname|
  send_mail(fname)
end
