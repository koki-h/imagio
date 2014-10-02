require 'pp'
require "./imagio.rb"

$IMAGIO_ADDRESS = "192.168.11.200"

today = "2014/10/1"
saved_files = []
imagio = Imagio.new($IMAGIO_ADDRESS)
imagio.download_fax_doc(today) do |down_data|
    pdf_filename = down_data[:date].gsub("/","-")
    open(pdf_filename, "w"){|f| f.print down_data[:pdf]}
    saved_files << pdf_filename
end


