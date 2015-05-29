# OpenCPU gem

[![Build Status](https://travis-ci.org/roqua/opencpu.svg?branch=master)](https://travis-ci.org/roqua/opencpu)
[![Build Status](https://circleci.com/gh/roqua/opencpu.svg?style=shield&circle-token=4689df66bef26cd4aff65a4893c25400795b408a)](https://circleci.com/gh/roqua/roqua/tree/master)
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
  config.timeout      = 30 # Timeout in seconds
  config.verify_ssl   = true # set to false for opencpu server with self-signed certificates.
end
```

## Usage

```Ruby
client = OpenCPU.client
```

### Formats

By default we send data using the json format. This format is efficient and safe, but only supports strings and numeric parameters (see [opencpu page](https://www.opencpu.org/api.html#api-arguments))

If you want to send R code argument, you'll need to specify format: :urlencoded in your request. Note that you need to enclose your string parameters in quotes in that case, since they will be seen as variables otherwise:

```Ruby
client.execute :digest, :hmac, data: { key: "'foo'", object: "'bar'" }, format: :urlencoded
```

### One-step call

One-step call always returns a JSON result from OpenCPU. This is a preferred
way to use this gem, but keep in mind that not every R-package supports one-step
responses. On OpenCPU server, packages can be installed under the system, but
also under a particular user. This gem also provides a way to access both of them.

**Access System Libraries**

To get a response from the package installed under the system libraries just
pass the package name, function and input data to the function. In the following
example `:digest` is an R-package name, `:hmac` is a function and
`{ key: 'foo', object: 'bar' }` is the input data, where `key` and `object` are
parameters of `hmac` function:

```Ruby
client.execute :digest, :hmac, data: { key: 'foo', object: 'bar' }
# => ['0c7a250281315ab863549f66cd8a3a53']
```

Above example is the same as the following (note the `user` parameter):

```Ruby
client.execute :digest, :hmac, user: :system, data: { key: 'foo', object: 'bar' }
# => ['0c7a250281315ab863549f66cd8a3a53']
```

**Access User Libraries**

To access a package installed under a particular user, just pass `user` parameter
with the name of the existing user.

```Ruby
client.execute :digest, :hmac, user: :johndoe, data: { key: 'foo', object: 'bar' }
# => ['0c7a250281315ab863549f66cd8a3a53']
```

### Two-steps way

To prepare the calculations on OpenCPU execute the `#prepare` method. It accepts
the same arguments as `#execute`, thus: `package`, `function`, `user` and `data`.

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

### Additional features

**Multipart requests with files**

If you want to send one or more files along, you can pass in a File object as data, but only when using the urlencoded format.

```Ruby
client.execute :foo, :bar, user: :johndoe, data: {file: File.new('/tmp/test.foo')}, format: :urlencoded
```

## Testing

**NOTE:** Test mode is only supported in combination with `#execute` and the
first step (`#prepare`) in two-step call.

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

## Maintainers

* [Henk van der Veen](@hampei)
* [Ivan Malykh](@ivdma)

## Contributing

1. Fork it ( http://github.com/roqua/opencpu/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
