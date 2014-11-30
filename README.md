# contracthashtool-ruby

Ruby port of https://github.com/Blockstream/contracthashtool

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'contracthashtool'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install contracthashtool

## Usage

```ruby
require 'contracthashtool'
require 'bitcoin'

Bitcoin.network = :testnet3

r = '5121038695b28f1649c711aedb1fec8df54874334cfb7ddf31ba3132a94d00bdc9715251ae'
p = 'cMcpaCT6pHkyS4347i4rSmecaQtLiu1eH28NWmBiePn8bi6N4kzh'
a = 'mqWkEAFeQdrQvyaWNRn5vijPJeiQAjtxL2'
n = '3a11be476485a6273fad4a0e09117d42'

nonce, p2sh_address = Contracthashtool.generate(r,a,n)
puts "nonce: #{nonce}, address: #{p2sh_address}"

key = Contracthashtool.claim(p,a,n)
puts "new privkey: #{key.to_base58}"
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/contracthashtool/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
