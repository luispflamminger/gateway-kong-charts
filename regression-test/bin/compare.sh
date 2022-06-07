TEMPLATE_NAME=stargate

# --- generic code below this line ---
RED=31m
GREEN=32m
ZERO=0m
echo -e "Running regression tests"
for test in $(ls regression-test/data/); do
  echo -e "\tRun test '${test}'"
  helm template . --name-template $TEMPLATE_NAME -f ./regression-test/data/${test}/values.yaml --dry-run --set global.domain=lab.tif.telekom.de -n default > result.yaml 2> stderr.txt
  ret_code="$?"
  if [ $ret_code -eq 0 ]; then
    if [ -f ./regression-test/data/${test}/sanitize.txt ]; then
      mv result.yaml dirty-result.yaml
      sed -f ./regression-test/data/${test}/sanitize.txt dirty-result.yaml > result.yaml
      rm -f dirty-result.yaml
    fi
    lines=$(diff result.yaml ./regression-test/data/${test}/expected.yaml | wc -l)
    if [ $lines -ne 0 ]; then
      echo -e "\t\t\e[${RED}${test} failed with diff of $lines lines\e[${ZERO}"
      mv result.yaml TEST-${test}-result.yaml
      echo -e "\t\tExecute 'diff TEST-${test}-result.yaml ./regression-test/data/${test}/expected.yaml' for details"
    else
      echo -e "\t\t\e[${GREEN}succeeded\e[${ZERO}"
      rm -f result.yaml stderr.txt
    fi
  else
    if [ ! -f ./regression-test/data/${test}/expected-stderr.txt ]; then
      touch ./regression-test/data/${test}/expected-stderr.txt
    fi
    lines=$(diff stderr.txt ./regression-test/data/${test}/expected-stderr.txt | wc -l)
    if [ $lines -ne 0 ]; then
      echo -e "\t\t\e[${RED}${test} failed with diff of $lines lines\e[${ZERO}"
      mv stderr.txt TEST-${test}-stderr.txt
      echo -e "\t\tExecute 'diff TEST-${test}-stderr.txt ./regression-test/data/${test}/expected-stderr.txt' for details"
    else
      echo -e "\t\t\e[${GREEN}failed with expected result\e[${ZERO}"
      rm -f result.yaml stderr.txt
    fi
  fi
done
echo -e "Done."
