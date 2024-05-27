#!/bin/bash

# Скрипт для создания и ротации снапшотов

SNAP_AMOUNT="40"                    # Количество снапшотов
BTRFS='/sbin/btrfs'                 # Исполяемый файл для управления btrfs
BTRFS_PATH='/data'                  # Путь к примонтированному subvolume с рабочим каталогом zimbra
BTRFS_SNAPSHOT='/snapshot'          # Путь куда смонтирован subvolume со снапшотами
DATE=`date "+%Y-%m-%d_%H-%M-%S"`    # Текущая дата и время
NAMESNAPSHOT='data'                 # Имя снапшота

# Удаляем последний снапшот
# (Снапшот создается с именем data, последующие в ротации должны иметь имя data_[timestamp])
$BTRFS subvolume delete $BTRFS_SNAPSHOT'/'$NAMESNAPSHOT

# Считаем количество снапшотов начинающихся на 'data'
SUBVOL_AMOUNT=`$BTRFS subvolume list -p $BTRFS_SNAPSHOT | grep -v dataroot | grep -E 'path '$NAMESNAPSHOT | wc -l`
echo "Subvolumes: $SUBVOL_AMOUNT"

# Если количество снапшотов больше чем нужно то удаляем самые давние до тех пор пока их не станет столько сколько нужно
while [ $SUBVOL_AMOUNT -gt $SNAP_AMOUNT ]; do
	echo "Subvolumes amount > $SNAP_AMOUNT"
	echo -e "I want to delete oldest subvolume and make the new one!"
#        $BTRFS subvolume list -p $BTRFS_SNAPSHOT | grep -v dataroot | grep -E 'parent.'$TOP_SUBVOL | head -1 | cut -d' ' -f11 -s
#        $BTRFS subvolume list -p $BTRFS_SNAPSHOT | grep -v dataroot | grep -E 'path data' | head -1 | cut -d' ' -f11 -s
#       Выбираем имя самого последнего снапшота и сразу удаляем его
	$BTRFS subvolume delete $BTRFS_SNAPSHOT'/'`$BTRFS subvolume list -p $BTRFS_SNAPSHOT | grep -v dataroot | grep -E 'path '$NAMESNAPSHOT | head -1 | cut -d' ' -f11 -s`

#       Считаем количество снапшотов заново
        SUBVOL_AMOUNT=`$BTRFS subvolume list -p $BTRFS_SNAPSHOT | grep -v dataroot | grep -E 'path '$NAMESNAPSHOT | wc -l`
done

echo -e "Let's do another one!"
# Создаем снапшот с датой
$BTRFS subvolume snapshot -r $BTRFS_PATH $BTRFS_SNAPSHOT'/'$NAMESNAPSHOT'_'$DATE
# И зачем-то еще один снапшот
$BTRFS subvolume snapshot -r $BTRFS_PATH $BTRFS_SNAPSHOT'/'$NAMESNAPSHOT
