#######################################################################################
# RUBY

# Rails aliases

alias rc='rails console'
alias rs='rails server'
# alias rbi='bundle install --path="vendor/bundle"'
alias rdh='rm -f db/schema.rb && rails db:drop && rails db:create && rails db:migrate && rails db:seed'
alias rdr='rails db:schema:load && rails db:migrate && rails db:seed'
