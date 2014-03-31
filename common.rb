# -*- coding: utf-8 -*-

module Common
  def self.gaussian(mean, stddev)
    theta = 2 * Math::PI * rand()
    rho = Math.sqrt(-2 * Math.log(1 - rand()))
    scale = stddev * rho
    x = mean + scale * Math.cos(theta)
    y = mean + scale * Math.sin(theta)
    return x
  end

  DNA = ["A", "T", "G", "C"]

  class << self
    attr_accessor :sam_header
  end
end