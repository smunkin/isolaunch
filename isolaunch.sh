#!/bin/bash

# Проверка установки Qemu
if [ -f /usr/bin/qemu-system-x86_64 ];then
	echo "Checked OK">>/dev/null
else
	zenity --error --text="Не установлен Qemu!"
	exit
fi

########## ФУНКЦИИ ########## 
# выбор количества используемой RAM
function choicemem() {
mem=$(zenity --scale \
    --text "Выделяемый объем RAM (Mb):" \
    --value=256 \
    --min-value=256\
    --max-value=4096 \
    --step=256)
}
# выбор размера виртуального диска 
function choicedisk() {
disk=$(zenity --scale \
    --text "Размер виртуального диска (Gb):" \
    --value=10 \
    --min-value=1\
    --max-value=30 \
    --step=1)
}
# создание файла qcow
function createqcow() {
qcowfile=$(zenity --entry \
--title="Создание файла" \
--text="Введите имя файла qcow:" \
--entry-text "")
}
# выбор ISO файла
function isochoice() {
isofile=$(zenity --file-selection --title="Выберите ISO образ")
}

# выбор QCOW файла
function qcowchoice() {
qcowfilechoice=$(zenity --file-selection --title="Выберите QCOW контейнер")
}
########## ФУНКЦИИ ########## 

choice=$(zenity --list  --title="Выбор параметров запуска" \
       --column="#" --column "действие" \
       1 "Создать контейнер на диске и запустить iso образ" \
       2 "Выбрать контейнер qcow и запустить") 
case $choice in
1) action=1;;
2) action=2;;
*) exit;;
esac

if [ $action = 1 ];then
	createqcow
	choicemem
	choicedisk
	isochoice
	qemu-img create -f qcow2 $HOME/$qcowfile.qcow $disk'G'
	qemu-system-x86_64 -hda $HOME/$qcowfile.qcow -boot d -cdrom $isofile -m $mem -enable-kvm -vga qxl -global qxl-vga.vram_size=42949670 
else
	qcowchoice
	choicemem
	qemu-system-x86_64 -hda $qcowfilechoice -boot d -m $mem -enable-kvm -vga qxl -global qxl-vga.vram_size=42949670 
fi

