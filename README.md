
## this is no longer maintained. support is now included in: https://github.com/lian/bitcoin-ruby

# contracthashtool-ruby

Ruby port of: https://github.com/Blockstream/contracthashtool

See also Appendix A of: https://blockstream.com/sidechains.pdf

![Appendix A, Algorithm 1](https://cloud.githubusercontent.com/assets/4391003/5239292/cff58560-7891-11e4-80fc-9f1b7235d19c.png)

## Installation [![GemVersion](https://badge.fury.io/rb/contracthashtool.svg)](http://badge.fury.io/rb/contracthashtool)

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

# Example parameters from the original tool's usage().

redeem_script_template = '5121038695b28f1649c711aedb1fec8df54874334cfb7ddf31ba3132a94d00bdc9715251ae'
payee_address = 'mqWkEAFeQdrQvyaWNRn5vijPJeiQAjtxL2'
nonce_hex = '3a11be476485a6273fad4a0e09117d42'
private_key_wif = 'cMcpaCT6pHkyS4347i4rSmecaQtLiu1eH28NWmBiePn8bi6N4kzh'

# Someone wanting to send funds to the sidechain would call this
# to calculate a P2SH address to send to. They would then send the
# MDFs (mutually distrusting functionaries) the target address
# and nonce so they are able to locate the subsequent transaction.
# The caller would then send the desired amount of coin to the P2SH
# address to initiate the peg protocol.

nonce, redeem_script, p2sh_address =
  Contracthashtool.generate(redeem_script_template, payee_address, nonce_hex)

puts "nonce: #{nonce}"
puts "P2SH address: #{p2sh_address}"
puts "new redeem script: #{redeem_script}"

# Each MDF would call this to derive a private key to redeem the
# locked transaction.

key = Contracthashtool.claim(private_key_wif, payee_address, nonce)
puts "new privkey: #{key.to_base58}"

# Verify homomorphic derivation was successful.

signature = key.sign_message("derp")
script = Bitcoin::Script.new([redeem_script].pack("H*"))
pubkey = Bitcoin::Key.new(nil, script.get_multisig_pubkeys.first.unpack("H*").first)
raise "nope" unless pubkey.verify_message(signature, "derp")
```

<pre>
<code>
$ bundle exec ruby test.rb
nonce: 3a11be476485a6273fad4a0e09117d42
P2SH address: 2MvGPFfDXbJZyH79u187VNZbuCgyRBhcdsw
new redeem script: 512102944aba05d40d8df1724f8ab2f5f3a58d052d26aedc93e175534cb782becc8ff751ae
new privkey: cSBD8yM62R82RfbugiGK8Lui9gdMB81NtZBckxe5YxRsDSKySwHK
</code>
</pre>

