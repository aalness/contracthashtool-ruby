# contracthashtool-ruby

Ruby port of https://github.com/Blockstream/contracthashtool

See also: https://blockstream.com/sidechains.pdf

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

nonce, redeem_script, p2sh_address = Contracthashtool.generate(r,a,n)
puts "nonce: #{nonce}, address: #{p2sh_address}"
puts "new redeem script: #{redeem_script}"

key = Contracthashtool.claim(p,a,n)
puts "new privkey: #{key.to_base58}"
```

<pre>
<code>
$ bundle exec ruby test.rb
nonce: 3a11be476485a6273fad4a0e09117d42, address: 2MvGPFfDXbJZyH79u187VNZbuCgyRBhcdsw
new redeem script: 512102944aba05d40d8df1724f8ab2f5f3a58d052d26aedc93e175534cb782becc8ff751ae
new privkey: cSBD8yM62R82RfbugiGK8Lui9gdMB81NtZBckxe5YxRsDSKySwHK
</code>
</pre>

