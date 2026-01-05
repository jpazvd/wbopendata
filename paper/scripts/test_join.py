#!/usr/bin/env python3
"""Test continuation joining logic."""

test_lines = [
    '. twoway (scatter si_pov_dday ny_gdp_pcap_pp_kd, msize(small)) ///',
    '>     , title("wrapped") ///',
    '>       xtitle("GDP per capita") ///',
    '>       ytitle("Poverty headcount (%)") ///',
    '>       note("Source: World Bank Open Data")'
]

print("Input lines:")
for i, line in enumerate(test_lines):
    print(f"  {i}: {repr(line)}")

joined = []
for line in test_lines:
    if line.startswith('> ') and joined:
        prev = joined[-1]
        cont = line[2:].lstrip()  # Remove '> ' and leading spaces
        print(f"Continuation: {repr(line[:30])} -> {repr(cont[:30])}")
        print(f"  Previous ends with ///: {prev.rstrip().endswith('///')}")
        if prev.rstrip().endswith('///'):
            joined.append('      ' + cont)
        else:
            joined.append('      ' + cont)
    else:
        joined.append(line)

print("\nOutput lines:")
for i, line in enumerate(joined):
    print(f"  {i}: {repr(line)}")
