# frozen_string_literal: true

# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get 'login_attempts_limit/clear', to: 'invalid_accounts#clear'
