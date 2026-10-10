find . \( -type f -o -type l \) \( -name "why-linux.rakudoc" \) -printf "%TY-%Tm-%Td %TH:%TM:%TS %p\n" | sort -k1
