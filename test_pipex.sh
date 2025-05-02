#!/bin/bash

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RED='\033[0;31m'
NC='\033[0m'

# Variables
i=1
ok=0
ko=0
leak=0
ko_leak=0

# Listes des erreurs
ko_tests=()
leak_tests=()
ko_leak_tests=()

# Nettoyage
rm -f infile_test outfile_pipex outfile_shell valgrind_out traces.txt tests.txt valgrind.txt

# Création fichier d'entrée
echo -e "hello world\nça va\n42 pipex\nanother line\ntest test\na b c d\n1 2 3\nfoo bar baz" > infile_test

# Commandes BASIC (30 tests)
basic_cmds=(
    "cat" "wc -l"
    "cat" "wc -w"
    "cat" "grep 'hello'"
    "cat" "grep 'pipex'"
    "grep '42'" "wc -l"
    "grep 'ca va'" "cat"
    "grep 'test'" "awk '{print \$1}'"
    "awk '{print \$2}'" "sort"
    "awk '{print \$3}'" "wc -c"
    "cat" "awk '{print \$1, \$2}'"
    "cat" "rev"
    "sort" "uniq"
    "sort" "wc -l"
    "grep 'baz'" "awk '{print \$1}'"
    "awk '{print \$1}'" "sort"
)

# Commandes EXTENDED (25 tests)
extended_cmds=(
    "awk '{print \$2}'" "sort -r"
    "cat" "cut -d' ' -f2"
    "cat" "head -n 3"
    "cat" "tail -n 2"
    "awk '{print \$1}'" "head -n 1"
    "grep 'a b'" "wc -c"
    "grep 'another'" "wc -w"
    "grep 'nonexistent'" "wc -l"
    "cat" "sed 's/ /_/g'"
    "awk '{print \$1}'" "cut -c1-2"
    "awk '{print \$2}'" "cut -c1-1"
    "tr ' ' '\n'" "sort"
    "tr a-z A-Z" "cat"
    "cat" "awk '{print toupper(\$0)}'"
    "cat" "awk '{print length(\$1)}'"
    "grep 'world'" "wc -l"
    "grep 'test test'" "wc -l"
    "grep 'foo bar'" "awk '{print \$1}'"
    "awk '{print \$1}'" "awk '{print length(\$1)}'"
    "cat" "awk '{ if(length(\$1)>3) print \$1 }'"
    "sort" "head -n 1"
    "grep -v 'baz'" "sort"
    "awk '{print toupper(\$1)}'" "wc -c"
    "grep '1 2 3'" "awk '{print \$2}'"
    "cat" "tr -d '\n'"
)

# Commandes HARD (10 tests corrigés)
hard_cmds=(
    "awk '{ if (length(\$1) > 3) print \$1 }'" "sort -r"
    "grep 'foo'" "wc -c"
    "grep '^[a-z]'" "awk '{print length(\$0)}'"
    "cat" "awk '{print \$1}'"
    "awk '{print \$2}'" "awk '{print toupper(\$0)}'"
    "grep -i 'hello'" "awk '{print toupper(\$1)}'"
    "awk 'NR==2'" "rev"
    "grep '42'" "cut -c1-2"
    "cat" "awk '{ if (length(\$2) < 3) print \$2 }'"
    "cat" "awk '{print \$NF}'"
	"awk '{print \$1}'" "cat"
)

# Fonctions
launch_valgrind() {
    valgrind --leak-check=full --show-leak-kinds=all --track-fds=yes --quiet --log-file="valgrind_out" "$@" > /dev/null 2>&1
}

check_valgrind() {
    allocs=$(grep -o "[0-9]* allocs" valgrind_out | head -n1 | cut -d' ' -f1)
    frees=$(grep -o "[0-9]* frees" valgrind_out | head -n1 | cut -d' ' -f1)
    [ -z "$allocs" ] && allocs=0
    [ -z "$frees" ] && frees=0
    diff_alloc_free=$((allocs - frees))
}

test_pipex() {
    infile=$1
    cmd1=$2
    cmd2=$3
    outfile=$4
    description=$5
    mode=$6

    rm -f outfile_pipex outfile_shell valgrind_out

    launch_valgrind ./pipex "$infile" "$cmd1" "$cmd2" "$outfile"

    if [[ $mode == "valid" ]]; then
        eval "< $infile $cmd1 | $cmd2 > outfile_shell"
    fi

    status="OK"
    check_valgrind

    if [[ $mode == "valid" ]]; then
        if ! diff "$outfile" outfile_shell > /dev/null; then
            status="KO"
        fi
    else
        if [ $? -eq 0 ]; then
            status="KO"
        fi
    fi

    if [ "$diff_alloc_free" -ne 0 ]; then
        if [[ "$status" == "KO" ]]; then
            status="KO+LEAK"
        else
            status="LEAK"
        fi
    fi

    case $status in
        OK)
            echo -e "test [$i] [${GREEN}OK${NC}]"
            ((ok++))
            ;;
        KO)
            echo -e "test [$i] [${YELLOW}KO${NC}]"
            ((ko++))
            ko_tests+=("[test $i]")
            ;;
        LEAK)
            echo -e "test [$i] [${BLUE}LEAK${NC}]"
            ((leak++))
            leak_tests+=("[test $i]")
            ;;
        KO+LEAK)
            echo -e "test [$i] [${RED}KO+LEAK${NC}]"
            ((ko_leak++))
            ko_leak_tests+=("[test $i]")
            ;;
    esac

    if [[ "$status" != "OK" ]]; then
        {
            echo "--------------------------------------------------------------------------------"
            echo "$description [test $i] [$status]"
            echo "commande : ./pipex \"$infile\" \"$cmd1\" \"$cmd2\" \"$outfile\""
            echo "shell : < \"$infile\" $cmd1 | $cmd2 > \"$outfile\""
            echo ""
            if [[ $mode == "valid" ]]; then
                echo "infile :"
                cat "$infile"
                echo ""
                echo "outfile obtenu :"
                cat "$outfile"
                echo ""
                echo "résultat attendu :"
                cat outfile_shell
                echo ""
            fi
            if [ "$diff_alloc_free" -ne 0 ]; then
                echo "Valgrind fuite détectée : $allocs allocs / $frees frees -> Différence: $diff_alloc_free"
                file_info=$(grep "at 0x" valgrind_out | head -n1)
                echo "Fuite mémoire : $file_info"
            fi
            echo "--------------------------------------------------------------------------------"
            echo ""
        } >> traces.txt
    fi

    # tests.txt
    echo "[test $i] ./pipex \"$infile\" \"$cmd1\" \"$cmd2\" \"$outfile\"" >> tests.txt

    # valgrind.txt
    if [ "$diff_alloc_free" -eq 0 ]; then
        echo "[test $i] [OK]     alloc: $allocs  free: $frees  diff: $diff_alloc_free" >> valgrind.txt
    else
        echo "" >> valgrind.txt
        echo "[test $i] [LEAK]   alloc: $allocs  free: $frees  diff: $diff_alloc_free" >> valgrind.txt
        echo "" >> valgrind.txt
    fi

    ((i++))
}

# Lancement des tests
echo -e "${BLUE}===== BASIC =====${NC}"
for ((j=0; j<${#basic_cmds[@]}; j+=2)); do
    test_pipex "infile_test" "${basic_cmds[j]}" "${basic_cmds[j+1]}" "outfile_pipex" "[BASIC]" "valid"
done

echo -e "${BLUE}===== EXTENDED =====${NC}"
for ((j=0; j<${#extended_cmds[@]}; j+=2)); do
    test_pipex "infile_test" "${extended_cmds[j]}" "${extended_cmds[j+1]}" "outfile_pipex" "[EXTENDED]" "valid"
done

echo -e "${BLUE}===== HARD =====${NC}"
for ((j=0; j<${#hard_cmds[@]}; j+=2)); do
    test_pipex "infile_test" "${hard_cmds[j]}" "${hard_cmds[j+1]}" "outfile_pipex" "[HARD]" "valid"
done

# Résumé final
echo ""
echo -e "${BLUE}===========================${NC}"
echo -e "     ${YELLOW}[KO]${NC}            ${BLUE}[LEAK]${NC}       ${RED}[KO+LEAK]${NC}"

max_lines=$(( ${#ko_tests[@]} > ${#leak_tests[@]} ? ${#ko_tests[@]} : ${#leak_tests[@]} ))
max_lines=$(( $max_lines > ${#ko_leak_tests[@]} ? $max_lines : ${#ko_leak_tests[@]} ))

for (( j=0; j<$max_lines; j++ )); do
    printf "%-15s %-15s %-15s\n" "${ko_tests[j]}" "${leak_tests[j]}" "${ko_leak_tests[j]}"
done

echo -e "${BLUE}---------------------------------------------------${NC}"
total_tests=$((ok + ko + leak + ko_leak))
echo -e "${GREEN}[OK]${NC} : $ok/$total_tests"
echo -e "${YELLOW}[KO]${NC} : $ko/$total_tests"
echo -e "${BLUE}[LEAK]${NC} : $leak/$total_tests"
echo -e "${RED}[KO+LEAK]${NC} : $ko_leak/$total_tests"
echo -e "${BLUE}===========================${NC}"

rm -f infile_test outfile_pipex outfile_shell valgrind_out
