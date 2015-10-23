require "./db/setup"
require "./lib/all"
require 'mail'

class EmailUser

  def initialize user, password
    @email = user.email
    @password = password
  end

  Mail.defaults do
    delivery_method :smtp, {
      :address => 'smtp.mailgun.org',
      :port => '587',
      :domain => ENV["MAILGUN_DOMAIN"] || File.read("mailgun_domain.txt").chomp,
      :user_name => ENV["MAILGUN_SMTP_LOGIN"] || File.read("mailgun_user_name.txt").chomp,
      :password => ENV["MAILGUN_SMTP_PASSWORD"] || File.read("mailgun_password.txt").chomp,
      :authentication => :plain,
      :enable_starttls_auto => true
                    }
  end

  def invite_user_mail
    Mail.deliver do
      to @email
      from 'admin@spotifyifyly.com'
      subject "You've been invited to Spotifyifyly"
      body 'You can log in with your email. Your temporary password is #{@password}. Please use your profile to change this password once you are logged in.'
    end
  end
end
