# Polls
Polling app in Ruby on Rails

## How to run
- run `rake db:seed:load`

## Features
- Users cannot create multiple responses to the same question
- `Question#result_includes` and `Question#result_improved` optimized N+1 queries
- Author cannot respond to own poll using custom validation
- `User#completed_polls` method returns polls where the user has answered all of the questions in the poll.
