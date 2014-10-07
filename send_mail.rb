require 'mail'

MAIL_ADDRESS = open('mail_address').read
PASSWORD     = open('password').read

Mail.defaults do
  delivery_method :smtp, { address:   'smtp.gmail.com',
                           port:      587,
                           domain:    'gmail.com',
                           user_name: MAIL_ADDRESS,
                           password:  PASSWORD }
end

def send_mail(file)
  filename = File.basename(file)
  Mail.deliver do
    from    MAIL_ADDRESS
    to      MAIL_ADDRESS
    subject "FAX received(#{filename})"
    body    "FAX received. filename:#{filename}"
    add_file :filename => file, :content => File.read(file)
  end
end
