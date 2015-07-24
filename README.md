# Configurative

Configurative is a library for handling basic configuration settings that was
heavily inspired by the Settingslogic library. I found Settingslogic to be an
excellent library but I just needed some extra capabilities...

 * The library could use either YAML or JSON files as input.

 * The library supported loading from a number of potential locations.

 * The library was more accepting of failures (i.e. it would raise exceptions
   in fewer cases).

 * The library would allow configuration settings to be selected as a subset
   of a larger file (i.e. the configuration settings could be tweaked to only
   consist of the contents of a single section within a larger file).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'configurative'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install configurative

## Usage

The intended mechanism of usage is to derive a class from the
```Configurative::Settings``` class. You can then customize this to have your
configuration settings come from one of a specific set of files. A basic
implementation therefore might look like this...

    class Configuration < Configurative::Settings
      files File.join(Dir.getwd, "config", "application.yml")
    end

The files line here can accept more than a single file path and will work
through them in order until it finds a file that exists and that the code has
permission to read. This will then be loaded and its contents will become the
configuration settings.

The library supports the use of files in either the JSON or YAML formats (note
that the file extension should be either '.json' or '.yml'). The concept of
environments is also supported, with "development" being the default environment
used. You can support an alternative environment either by specifying it in
an environment variable (the library checks RAILS_ENV then RACK_ENV in that
order for the environment setting) or by specify it explicitly in the class
definition like this...

    class Configuration < Configurative::Settings
      files File.join(Dir.getwd, "config", "application.yml")
      environment ENV["MY_ENV"]
    end

If your configuration file is large and you really only want some of the
settings it contains then you can specify a subsection in your class definition
and the library will narrow the settings available to just those in the section
specified. For example, if you had a configuration file like this...

    database:
      user_name: db_user
      password: db_password
    logging:
      active: true
      file: ./log/application.log

Then you could extract only the entries in the logging section by defining your
class as follows...

    class Configuration < Configurative::Settings
      files File.join(Dir.getwd, "config", "application.yml")
      section "logging"
    end

Note that this setting can be used in conjunction with the environment setting
but the environment setting takes precedence. So if you specify an environment
setting of ```production``` and a section of ```logging``` then the production
section would be extracted first and then the logging section extracted from
what that returned. Note that for both the environment and section settings if
a matching subsection is not found then the library simply assumes that its
absence means that the relevant discrimator does not need to be applied.

Once you've defined your configuration class then you can access the settings
retrieved either directly through the class itself or by fetching an instance
of that class. So if you defined a setting class called Configuration and loaded
the following configuration settings...

    one: 1
    two: "Two"

You could access the settings in all of the following ways...

    Configuration.one            # = 1
    Configuration[:one]          # = 1
    Configuration.fetch(:one)    # = 1
    Configuration.instance.two   # = "Two"
    Configuration.instance[:two] # = "Two"

If you request a setting that does not exist then the library returns ```nil```
by default. If you want to fetch something with a viable alternative in case
the original setting is not set then pass a second parameter to a call to the
```#fetch()``` method. If you need to check whether a setting has been given a
value then use the ```#include?()``` method and pass in the setting key. Finally
if you want to check that you have at least some settings you can make a call
to the ```#empty?()``` method to determine whether or not your settings class
has anything in it.

Note that, as part of the loading process, the library converts all Hashes into
instances of the OpenStruct class and thus you can cascade down through a
settings hierarchy using the ```.``` operator rather than a dereference call.
So, for example, if you had this configuration...

   one:
     two:
       three: 3

You could access the value of three with a call such as this...

    Configuration.one.two.three

## Contributing

1. Fork it ( https://github.com/[my-github-username]/configurative/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
