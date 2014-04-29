# OpenCPU gem

![Build Status](https://circleci.com/gh/roqua/opencpu.png?circle-token=4689df66bef26cd4aff65a4893c25400795b408a)

Roqua wrapper for the OpenCPU REST API.

## Installation

Add this line to your application's Gemfile:

    gem 'opencpu'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install opencpu

## Usage

    data = { '.someFunction': [{ x: [1,2,3,4,5], y: [7,3,9,4,1] }]}
    response = OpenCPU.execute 'PackageName', 'ScriptName', data

## Contributing

1. Fork it ( http://github.com/roqua/opencpu/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
