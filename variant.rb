# -*- coding: utf-8 -*-

require_relative "reference.rb"
require_relative "common.rb"

class Variant
  attr_accessor :type, :pos, :length, :str, :seq, :hap_pos
  # hap_pos : position index in hap. it can be changed by other variants

  def initialize(pos, str) # pos is 1-based
    @str = str
    @pos = pos
    @hap_pos = @pos
    if /(\w)=>(\w)/ =~ str
      @type = :snp
      @seq = $2
      @length = 1
    elsif /\+(\w+)/ =~ str
      @type = :ins
      @seq = $1
      @length = $1.length
    elsif /-(\w+)/ =~ str
      @type = :del
      @seq = $1
      @length = $1.length
    end
  end

  def self.gen_variant(chr, pos)
    ref_base = Reference.get_base(chr, pos)
    i = ::Common::DNA.index(ref_base)
    obs_base = ::Common::DNA[(i + 1) % 4]
    Variant.new(pos, "#{ref_base}=>#{obs_base}")
  end

  def inspect
    "pos:#{@pos}, hap_pos:#{@hap_pos}," + @str
  end
end
