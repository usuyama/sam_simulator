# -*- coding: utf-8 -*-

require_relative "common.rb"

class Settings
  class << self
    attr_accessor :reference_path, :depth, :read_length
    attr_reader :sam_header_path
  end

  def self.set_sam_header_path(x)
    ::Common.sam_header = File.open(x, "r").read
    sam_header_path = x
  end

  def self.get_insert_size
    Common.gaussian(3000, 200).round
  end

end

Settings.reference_path = "/Users/usuyama/Dropbox/research/hapmuc_sim/random_ref.fasta"
Settings.set_sam_header_path("/Users/usuyama/Dropbox/research/hapmuc_sim/header")
Settings.depth = 50
Settings.read_length = 1000