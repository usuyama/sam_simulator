# -*- coding: utf-8 -*-

require_relative "read.rb"
require_relative "common.rb"
require_relative "settings.rb"
require_relative "reference.rb"
require_relative "variant.rb"

class Haplotype
  attr_reader :variants, :seq, :punc, :chr

  def initialize(chr, vars=[])
    @chr = chr
    @variants = vars.sort {|a,b| a.pos <=> b.pos }
    gen_seq
    gen_punc
  end

  def inspect
    "variants: #{@variants}, punc"
  end

  def self.from_variants_str(chr, variants_str)
    variants = []
    for x in variants_str.split(",")
      variants << Variant.gen_variant(chr, x.to_i)
    end
    Haplotype.new(chr, variants)
  end

  def gen_punc
    @punc = []
    for v in @variants
      if v.type == :snp
        next
      elsif v.type == :ins
        @punc.push([:is, v.hap_pos])
        @punc.push([:ie, v.hap_pos+v.length])
      elsif v.type == :del
        @punc.push([:ds, v.hap_pos])
        @punc.push([:de, v.hap_pos+v.length])
      end
    end
  end

  def change_hap_pos(start, length)
    start.upto(@variants.size-1) do |i|
      @variants[i].hap_pos += length
    end
  end

  def seek_next(pos, rest)
    left = nil
    right = nil
    old = nil
    for x in @punc
      if x.last > pos
        right = x
        if !old.nil?
          left = old
        end
        break
      end
      old = x
    end
    if left.nil?
      if !right.nil?
        l = right.last - pos
        l = (l < rest) ? l : rest
        return [l, "#{l}M"]
      else
        [rest, "#{rest}M"]
      end
    end
    if right.nil?
      [rest, "#{rest}M"]
    else
      l = right.last - pos
      l = l > rest ? rest : l
      if  left.first == :ie || left.first == :de
        [l, "#{l}M"]
      elsif left.first == :is
        [l, "#{l}I"]
      else
        l = right.last - pos
        [l, "#{l}D"]
      end
    end
  end

  def gen_cigar(start)
    cp = start
    rest = Settings.read_length
    cigar = ""
    while(rest > 0)
      x = seek_next(cp, rest)
      cigar += x.last
      if x.last[-1,1]!="D"
        rest -= x.first
      end
      cp += x.first
    end
    cigar
  end

  def gen_seq
    @seq = Reference.get_chr_seq(@chr).dup
    i = 0
    for v in @variants
      i += 1
      if v.type == :snp
        @seq[v.hap_pos-1] = v.seq
      elsif v.type == :ins
        @seq = @seq[0..v.hap_pos-1] + v.seq + @seq[v.hap_pos..@seq.size-1]
        change_hap_pos(i, v.length)
      elsif v.type == :del
        @seq = @seq[0..v.hap_pos-1] + @seq[v.hap_pos+v.length..@seq.size-1]
        change_hap_pos(i, -v.length)
      end
    end
  end

  def sanger_phred_score_at(position)
    return 20
  end

  def phred_to_prob(phred_score)
    10 ** (-phred_score/10.0)
  end

  def phred_to_ascii(phred_score)
    (phred_score+33).chr
  end

  def gen_read(pos) # pos: 1-based
    read = @seq[pos-1, Settings.read_length]
    qualities = ""
    0.upto(read.size-1) do |i|
      phred_score = sanger_phred_score_at(i)
      qualities += phred_to_ascii(phred_score)
      if(rand() < phred_to_prob(phred_score))
        alt = read[i, 1]
        while alt==read[i, 1]
          alt = Common::DNA[rand(4)]
        end
        read[i] = alt
      end
    end
    return Read.new(read, qualities, gen_cigar(pos), pos, @chr)
  end

  def gen_paired_reads(target_pos)
    start = target_pos - Settings.read_length + rand(Settings.read_length).round
    to_forward = rand() > 0.5 # direction of strand
    ins_size = Settings.get_insert_size()
    if to_forward
      start1 = start
      start2 = start + ins_size - Settings.read_length
    else
      start2 = start
      start1 = start - ins_size + Settings.read_length
    end
    r1 = gen_read(start1)
    r2 = gen_read(start2)
    read_pair = ReadPair.new(r1, r2)
    read_pair
  end

end
