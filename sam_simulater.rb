# -*- coding: utf-8 -*-

require_relative "common.rb"
require_relative "haplotype.rb"

usage = "ruby sam_simulater.rb\tchr\ttarget_pos\tvariants1\tvariants2\thaplotype_freq_tumor\thaplotype_freq_normal\tout_prefix
ex. ruby sam_simulater.rb\tchrA\t1000\t500,1500,2500\t750,1200,2600\t0.5,0.5,0.0,0.0\t0.25,0.5,0.25,0.0\t./out."

if ARGV.length != 7
  warn "ARGV=#{ARGV.inspect}"
  warn usage
  raise "invalid_parameters"
end

chr = ARGV[0]
target_pos = ARGV[1].to_i
out_f = ARGV[6]

tumor_f = File.open(out_f + "tumor.sam", "w")
normal_f = File.open(out_f + "normal.sam", "w")
tumor_f.puts Common.sam_header
normal_f.puts Common.sam_header

variants1_str = ARGV[2]
variants2_str = ARGV[3]
variants3_str = variants1_str + ",#{target_pos}"
variants4_str = variants2_str + ",#{target_pos}"

haps = []
haps << Haplotype.from_variants_str(chr, variants1_str)
haps << Haplotype.from_variants_str(chr, variants2_str)
haps << Haplotype.from_variants_str(chr, variants3_str)
haps << Haplotype.from_variants_str(chr, variants4_str)

hap_freq_normal = ARGV[4].split(",").map {|x| x.to_f}
hap_freq_tumor = ARGV[5].split(",").map {|x| x.to_f}

def simulate_sam(target_pos, haps, hap_freq_tumor, hap_freq_normal, tumor_f, normal_f)
  index = 0
  Settings.depth.to_i.times do
    r = rand()
    i = 0
    th = 0.0
    0.upto(haps.size()-1) do
      th += hap_freq_normal[i]
      if th >= r
        break
      else
        i += 1
      end
    end
    index += 1
    pair = haps[i].gen_paired_reads(target_pos)
    pair.id = "#{index}_#{i}"
    normal_f.puts pair.to_str
  end

  index = 0
  Settings.depth.to_i.times do
    r = rand()
    i = 0
    th = 0.0
    0.upto(haps.size()-1) do
      th += hap_freq_tumor[i]
      if th >= r
        break
      else
        i += 1
      end
    end
    index += 1
    pair = haps[i].gen_paired_reads(target_pos)
    pair.id = "#{index}_#{i}"
    tumor_f.puts pair.to_str
  end
end

simulate_sam(target_pos, haps, hap_freq_tumor, hap_freq_normal, tumor_f, normal_f)
