# Given a CSV file of the form <text,natural number>, this writes a CSV
# file of relative probabilities, based on the maximum natural number found
# in the CSV file.
#
# awk -f probability.awk <csv file>
#
BEGIN {
  max=0;
  OFS=FS=","
}

$NF > max {
  max=$NF
}

NR > FNR {
  print $1, $2/max
}
