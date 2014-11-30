require "ffi"

#
# Ruby port of https://github.com/Blockstream/contracthashtool
#
module Contracthashtool

  # generate a contract address
  def self.generate(redeem_script_hex, payee_address_or_ascii, nonce_hex=nil)
    redeem_script = Bitcoin::Script.new([redeem_script_hex].pack("H*"))
    raise "only multisig redeem scripts are currently supported" unless redeem_script.is_multisig?
    nonce_hex, data = compute_data(payee_address_or_ascii, nonce_hex)

    derived_keys = []
    group = OpenSSL::PKey::EC::Group.new("secp256k1")
    redeem_script.get_multisig_pubkeys.each do |pubkey|
      tweak = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("SHA256"), pubkey, data).to_i(16)
      raise "order exceeded, pick a new nonce" if tweak >= group.order
      tweak = OpenSSL::BN.new(tweak.to_s)
      key = Bitcoin::Key.new(nil, pubkey.unpack("H*")[0])
      key = key.instance_variable_get(:@key)
      point = group.generator.mul(tweak).add(key.public_key).to_bn.to_i
      key = Bitcoin::Key.new(nil, point.to_s(16))
      key.instance_eval{ @pubkey_compressed = true }
      derived_keys << key.pub
    end

    m = redeem_script.get_signatures_required
    p2sh_script, redeem_script = Bitcoin::Script.to_p2sh_multisig_script(m, *derived_keys)

    [ nonce_hex, redeem_script.unpack("H*")[0], Bitcoin::Script.new(p2sh_script).get_p2sh_address ]
  end

  # claim a contract
  def self.claim(private_key_wif, payee_address_or_ascii, nonce_hex)
    key = Bitcoin::Key.from_base58(private_key_wif)
    data = compute_data(payee_address_or_ascii, nonce_hex)[1]

    pubkey = [key.pub].pack("H*")
    tweak = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("SHA256"), pubkey, data).to_i(16)
    group = OpenSSL::PKey::EC::Group.new("secp256k1")
    raise "order exceeded, verify parameters" if tweak >= group.order

    derived_key = (tweak + key.priv.to_i(16)) % group.order
    Bitcoin::Key.new(derived_key.to_s(16))
  end

  # compute HMAC data
  def self.compute_data(address_or_ascii, nonce_hex)
    nonce = nonce_hex ? [nonce_hex].pack("H32") : SecureRandom.random_bytes(16)
    if Bitcoin.valid_address?(address_or_ascii)
      address_type = Bitcoin.address_type(address_or_ascii)
      case address_type
      when :hash160
        address_type = "P2PH"
      when :p2sh
        address_type = "P2SH"
      else
        raise "unsuppoorted address type #{address_type}"
      end
      contract_bytes = [Bitcoin.hash160_from_address(address_or_ascii)].pack("H*")
    else
      address_type = "TEXT"
      contract_bytes = address_or_ascii
    end
    [ nonce.unpack("H*")[0], address_type + nonce + contract_bytes ]
  end

  # lifted from https://github.com/GemHQ/money-tree
  module EC_ADD
    extend ::FFI::Library
    ffi_lib "ssl"

    NID_secp256k1 = 714
    POINT_CONVERSION_COMPRESSED = 2
    POINT_CONVERSION_UNCOMPRESSED = 4

    attach_function :EC_KEY_free, [:pointer], :int
    attach_function :EC_KEY_get0_group, [:pointer], :pointer
    attach_function :EC_KEY_new_by_curve_name, [:int], :pointer
    attach_function :EC_POINT_free, [:pointer], :int
    attach_function :EC_POINT_add, [:pointer, :pointer, :pointer, :pointer, :pointer], :int
    attach_function :EC_POINT_point2hex, [:pointer, :pointer, :int, :pointer], :string
    attach_function :EC_POINT_hex2point, [:pointer, :string, :pointer, :pointer], :pointer
    attach_function :EC_POINT_new, [:pointer], :pointer

    def self.add(point_0, point_1)
      eckey = EC_KEY_new_by_curve_name(NID_secp256k1)
      group = EC_KEY_get0_group(eckey)

      point_0_hex = point_0.to_bn.to_s(16)
      point_0_pt = EC_POINT_hex2point(group, point_0_hex, nil, nil)
      point_1_hex = point_1.to_bn.to_s(16)
      point_1_pt = EC_POINT_hex2point(group, point_1_hex, nil, nil)

      sum_point = EC_POINT_new(group)
      success = EC_POINT_add(group, sum_point, point_0_pt, point_1_pt, nil)
      hex = EC_POINT_point2hex(group, sum_point, POINT_CONVERSION_UNCOMPRESSED, nil)
      EC_KEY_free(eckey)
      EC_POINT_free(sum_point)
      hex
    end
  end

  # monkey patch EC::Point
  class OpenSSL::PKey::EC::Point
    def add(point)
      sum_point_hex = EC_ADD.add(self, point)
      self.class.new group, OpenSSL::BN.new(sum_point_hex, 16)
    end
  end

end
