# -*- coding: utf-8 -*-

require_relative "./reference.rb"
require_relative "./variant.rb"
require_relative "./haplotype.rb"

p Reference.get_base("chrA", 100)

variants = [Variant.gen_variant("chrA", 1), Variant.gen_variant("chrA", 5)]

h0 = Haplotype.new("chrA", [])
h1 = Haplotype.new("chrA", variants)

p h0.seq[0, 20]
p h1.seq[0, 20]

rp = h1.gen_paired_reads(100)
rp.id = "id"
p rp.to_str