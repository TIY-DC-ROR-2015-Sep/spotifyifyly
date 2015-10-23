require 'mail'

Mail.defaults do
  delivery_method :smtp, {
    :address => 'smtp.mailgun.org',
    :port => '587',
    :domain => 'appcc3784cba03248a9b22b45f6494fec0e.mailgun.org',
    :user_name => 'postmaster@appcc3784cba03248a9b22b45f6494fec0e.mailgun.org',
    :password => 'c7a91e23466debad3f250c854d2ebfb7',
    :authentication => :plain,
    :enable_starttls_auto => true
                  }
end

def invite_user_mail
  Mail.deliver do
    to ''
    from 'admin@spotifyifyly.com'
    subject 'testing send mail'
    body 'Sending email with Ruby through SendGrid!'
  end
end
