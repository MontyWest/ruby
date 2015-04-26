# ruby
Library Reservation System in Ruby

Author: Monty West - mwest06

Running:
- Clone the repo and move to the directory
- Run:
```
$ irb
> require_relative 'library'
> my_lib = Library.new
```
- Use library as described in library.pdf (Note using **puts** as the beginning of each function will ensure proper formatting)  e.g.
```
> my_lib.open
=> "Today is day 1"
> my_lib.issue_card('Dave')
=> "Library card issued to Dave."
> my_lib.serve('Dave')
=> "Now serving Dave."
etc.
```
