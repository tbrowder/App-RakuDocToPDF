find . \( -type f -o -type l \) \( -name "why-linux*pdf" \) -printf "%TY-%Tm-%Td %TH:%TM:%TS %p\n" | sort -k1
