# -*- coding: utf-8 -*-

class Read
  attr_accessor :seq, :base_qualities, :cigar, :pos, :chr

  def initialize(seq, quality, cigar, pos, chr)
    @seq = seq
    @base_qualities = quality
    @cigar = cigar
    @pos = pos
    @chr = chr
  end

  def inspect
    "#{@pos}, cigar: #{@cigar}\n#{@seq}\n#{@base_qualities}"
  end
end

class ReadPair
  attr_accessor :first, :second, :id

  def initialize(first, second)
    @first = first
    @second = second
  end

  def to_str
    pos = @first.pos
    pair_pos = @second.pos
    ins = pair_pos - pos + @second.seq.length
    out = "#{@id}\t99\t#{@first.chr}\t#{pos}\t60\t#{@first.cigar}\t=\t#{pair_pos}\t#{ins}\t#{@first.seq}\t#{@first.base_qualities}\n"
    out += "#{@id}\t147\t#{@second.chr}\t#{pair_pos}\t60\t#{@second.cigar}\t=\t#{pos}\t#{-ins}\t#{@second.seq}\t#{@second.base_qualities}"
    return out
  end

  def inspect
    out = @first.inspect + "\n"
    out += @second.inspect
    return out
  end
end