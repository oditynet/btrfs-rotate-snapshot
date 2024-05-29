#!/bin/bash
snap_count=10
btrfs_path="/home/odity/vm"
date_str=`date "+%Y-%m-%d_%H-%M-%S"`

main=$(btrfs subvolume list -p $btrfs_path |grep snaps|grep 'snapshot$'|awk '{print $2}')
count=$(btrfs subvolume list -p $btrfs_path |awk '{if ($6 == '$main') print($2)}'|wc -l)
while [ $snap_count -lt $count ]; do
	item_snap=$(btrfs subvolume list -p $btrfs_path |awk '{if ($6 == '$main') print($2)}'| head -1)
	
	echo "Delete $item_snap"
	del=$(btrfs subvolume delete --subvolid $item_snap $btrfs_path)
done
echo "Create snap №$((count+1))"
btrfs subvolume snapshot -r $btrfs_path $btrfs_path/image/@snapshot/snap_$date_str
