# OpenCPU gem

![Build Status](https://circleci.com/gh/roqua/opencpu.png?circle-token=4689df66bef26cd4aff65a4893c25400795b408a)
[![Code Climate](https://codeclimate.com/github/roqua/opencpu.png)](https://codeclimate.com/github/roqua/opencpu)
[![Dependency Status](https://gemnasium.com/roqua/opencpu.svg)](https://gemnasium.com/roqua/opencpu)

Roqua wrapper for the OpenCPU REST API.

## Installation

Add this line to your application's Gemfile:

    gem 'opencpu'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install opencpu

## Configuration

```Ruby
OpenCPU.configure do |config|
  config.endpoint_url = 'https://public.opencpu.org/ocpu'
end
```

## Usage

```Ruby
client = OpenCPU.client
```

### One-step call

One-step call always returns a JSON result from OpenCPU. However this is a
preferred way to use this gem, not every R-package supports one-step responses.

To get a response just pass a package name, function and the payload to the
function. In the following example `:digest` is an R-package name, `:hmac` is a
function and `{ key: 'foo', object: 'bar' }` is the payload:

```Ruby
client.execute :digest, :hmac, { key: 'foo', object: 'bar' }
# => ['0c7a250281315ab863549f66cd8a3a53']
```

### Two-steps way

To prepare the calculations on OpenCPU execute the `#prepare` method. It accepts
the same arguments as `#execute`.

```Ruby
calculations = client.prepare :animation, 'flip.coin'
```

`calculations` variable now holds the reference URL's to the calculations made
by OpenCPU. These URL are available through one of the following methods. Which
of them are available depends on the package and possible response it can
generate.

**#graphics(obj, type)**

```Ruby
calculations.graphics
# => Returns the first SVG created by OpenCPU.
calculations.graphics(1)
# => Returns the second SVG created by OpenCPU.
calculations.graphics(1, :png)
# => Returns the second PNG created by OpenCPU.
```

**#value**

```Ruby
calculations.value
# => Returns the raw output of the R-function.
```

**#stdout**

```Ruby
calculations.stdout
# => Returns the raw output of stdout being written at the runtime.
```

**#warnings**

```Ruby
calculations.warnings
# => Returns the warnings returned by the script.
```

**#source**

```Ruby
calculations.source
# => Returns the source of the script.
```

**#console**

```Ruby
calculations.console
# => Returns the output from R-console.
```

**#info**

```Ruby
calculations.info
# => Returns information about R-environment of the script.
```

## Test mode

OpenCPU gem provides a test mode. It basically disables all HTTP interactions
with provided OpenCPU server. It is very handy when testing your software for
example. You can easily turn it on:

```Ruby
OpenCPU.enable_test_mode!
```

After that you can set fake responses per package/script combination:

```Ruby
OpenCPU.set_fake_response! :digest, :hmac, 'foo'
```

This will allways return `'foo'` when calling function `hmac` in package
`digest`.

## Contributing

1. Fork it ( http://github.com/roqua/opencpu/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
