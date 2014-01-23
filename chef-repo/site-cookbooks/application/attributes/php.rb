default[:php][:ini][:timezone]  = "UTC"

default[:php][:ini][:session][:save_handler] = "files"
default[:php][:ini][:session][:save_path] = "/var/lib/php/session"
default[:php][:ini][:session][:use_cookies] = 1
default[:php][:ini][:session][:name] = "PHPSESSID"
default[:php][:ini][:session][:cookie_path] = "/"
default[:php][:ini][:session][:cookie_domain] = ""
default[:php][:ini][:session][:cache_expire] = 180
