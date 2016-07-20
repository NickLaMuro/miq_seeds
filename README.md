MiqSeeds
========

Provides database seed scripts for various customer scenarios for the
[ManageIQ](https://github.com/ManageIQ/manageiq) application, without including
any kind of private or customer specific data, or passing around a database
dump to replicate on other developers machines.

Slower than some of the aforementioned approaches for sure, but more
customizable, and ideally each generator can be combined with others to set up
a tailored database for your specific scenario in question, and not rely on a
bloated catch-all database dump or seed file.


Installation
------------

Since this is meant to be used specifically with the
[ManageIQ Codebase](https://github.com/ManageIQ/manageiq), but only for
the development environment, add the following line to the `Gemfile.dev.rb`
file:

```ruby
gem 'miq_seeds', :require => false, :github => 'ManageIQ/miq_seeds'
```

And then execute:

    $ bin/bundle update


Usage
-----

This is mean to be strictly a console utility that you require as needed, and
the `rails console` is a great way to do that:

```ruby
irb> require 'miq_seeds'
#=> true
```

From there, you can view the generators available to you:

```ruby
irb> MiqSeeds.generators
:miq_reports
:miq_services
:miq_tasks
:hosts
:networks
:users
#=> nil
```

And view specific usage instructions for a specific generator:

```ruby
irb> MiqSeeds.generators :miq_reports
# Generate a set count of miq_reports
#
# Arguments:
#
#   count: int (required)
#
# Examples
#
#   MiqSeed.generators :miq_reports 10000
#
# => nil
```

To finally fire off a generator, just run the generate method with the
generator you want to use:

```ruby
irb> MiqSeeds.generators :miq_reports
# Lines and lines and lines of ActiveRecord output... this will take a while...
# => nil
```

If you are using a database dump and want to determine what a comparable
generator script would look like, the `MiqSeeds.analyze` command will do just
that for the specified generator (assuming it implements the analyze function):

```ruby
irb> MiqSeeds.analyze :miq_reports
# MiqSeeds.generate :miq_reports, [ 500, 4000, 20, 58, 85, 1, 9]
# => nil
```


FAQ
---
_LOL, that is a good one!  There isn't even any users yet for there to be any
questions!_

Shh!... Quiet you "self-aware README"...

> Hey, why is this not just included in the `ManageIQ/manageiq` project, since
> it is so context specific?

The scripts and automation for this repository fall well beyond the needs of
the customer, and it is expected that there will be many of these available for
developers to use.  Because of that, to reduce the extra noise on the base
repository, we are making this a separate gem that can be use at a developer's
discrete.


> Am I able to submit some generators that I also find useful?

Of course, pull requests welcome!  We only ask that you properly document the
generators that you add so that others can easily make use of them.  Use
existing generators as a guide.  Otherwise just about anything that you wish to
contribute will probably be excepted (within reason of course).

> Why are there no tests?

I'm a cowboy.


Contributing
------------

Bug reports and pull requests are welcome on GitHub at
https://github.com/NickLaMuro/miq_seeds.

