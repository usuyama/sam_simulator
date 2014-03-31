# -*- coding: utf-8 -*-

require_relative "settings.rb"

class Reference
  @@data = nil

  def self.init
    data = open(Settings.reference_path).read
    tmp = data.split(">")[1..-1]
    @@data = {}
    for x in tmp
      i = x.index("\n")
      chr_key = x[0..i-1]
      seq = x[i+1..-1].gsub("\n", "")
      @@data[chr_key] = seq
    end
  end

  def self.get_base(chr, pos)
    # pos is 1-based
    Reference.init if @@data.nil?
    unless @@data.has_key?(chr)
      raise "chr: #{chr} not found"
    else
      return @@data[chr][pos-1, 1]
    end
  end

  def self.get_chr_seq(chr)
    Reference.init if @@data.nil?
    @@data[chr]
  end

end