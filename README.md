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
    
## Configuration

    

## Usage

    client = OpenCPU.client

### One-step call

```Ruby
client.execute :digest, :hmac, { key: 'foo', object: 'bar' }
# => ['0c7a250281315ab863549f66cd8a3a53']
```

### Two-steps way

To prepare the calculations on OpenCPU execute the `#prepare` method. It accepts the same arguments as `#execute`.

```Ruby
calculations = client.prepare :animation, 'flip.coin'
```

`calculations` variable now holds the calculations that OpenCPU returned to us.

Which of the following methods are available depends on the response from the package.

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

## Contributing

1. Fork it ( http://github.com/roqua/opencpu/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
