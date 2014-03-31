# -*- coding: utf-8 -*-

module Common
  def self.gaussian(mu, sig2) # N(mu, sig^2)
    t = -6.0
    12.times { t += rand() }
    t /= 4.0
    (t * sig2) + mu
  end

  DNA = ["A", "T", "G", "C"]

  class << self
    attr_accessor :sam_header
  end
end