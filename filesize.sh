#!/bin/bash

total_size=0
show_summary=false
show_only_summary=false
has_errors=false
files_to_precoss=()

print_usage(){
	echo "Using: $0 [-s, -S] [--usage, --help] <file1> <file2> ..."

}

print_help() {
    echo "Сценарий для вывода информации о размере файлов"
    echo ""
    print_usage
    echo ""
    echo "Опции:"
    echo "  -s        Вывести размеры файлов и суммарный размер"
    echo "  -S        Вывести только суммарный размер"
    echo "  --usage   Вывести краткую справку по использованию"
    echo "  --help    Вывести эту подробную справку"
    echo ""
    echo "Коды возврата:"
    echo "  0  - Успешное выполнение"
    echo "  1  - Один или несколько файлов не существуют"
    echo "  2  - Использована неподдерживаемая опция"
}

process_file() {
	local file="$1"

	if [ ! -e "$file" ]; then
		echo "Ошибка: файл '$file' не найден" >&2
		has_errors=true
		return 1
	fi

	local size=$(stat -c %s "file" 2>/dev/null)

	if [ $? -ne 0]; then
		echo "Ошибка в нахождении размера файла '$file'" >&2
		has_error=true

		return 1
	fi

	total_size=$((total_size + size))

 	if ["$show_only_summary" = false]; then
		echo "$size $file"
	fi

	return 0
}

while [[ $# -gt 0 ]]; do
	case "$1" in
		-s)
			show_summary=true
			shift
			;;
		-S)
			show_only_summary=true
			show=true
			shift
			;;
		--usage)
			print_usage
			exit 0
			;;
		--help) print_help
			exit 0
			;;
		--)
			shift
			break
			;;
		-*)
			echo "Ошибка, неизвестная опция '$1'" >&2
			print_usage
			exit 2
			;;
		*)
			files_to_process+=("$1")
			shift
			;;
	esac
done

while [[ $# -gt 0 ]]; do
	files_to_process+=("$1")
	shift
done

if [ ${#files_to_process[@]} -eq 0 ]; then
	echo "Ошибка: отсутствуют файлы" >&2
	print_usage
	exit 1
fi

for file in "${files_to_process[@]}"; do
	process_file "$file"
done

if [ "$show_summary" = true ]; then
	if [ "$show_only_summary" = false ]; then
		echo "-------------------"
	fi
	echo "TOtal summary: $total_size byte"
fi

if [ "$has_errors" = true ]; then
	exit 1
else
	exit 0
fi

