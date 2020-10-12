#!/bin/sh

contest=$(realpath $1)
result=$(realpath $2)

mkdir $result -pv

for coder in $contest/code/*; do
	coder_name=$(basename $coder)
	mkdir $result/$coder_name -pv
	for task in $contest/task/*; do
		task_name=$(basename $task)
		cnt=0
		for i in $task/*; do
			cnt=$(($cnt + 1))
		done
		score=0
		if [ -e $coder/$task_name ]; then
			for src in $coder/$task_name/*; do
				$contest/compile.sh $src
				if [ "$?" != "0" ]; then
						echo "$src: CE" >> $result/$coder_name/log
						break
				fi
				cnt_ac=0
				for subtask in $task/data/*; do
					err=no
					for inf in $subtask/[^.a]; do
						./run_one_test.sh $task/cfg prog $inf $inf.a res
						if [ "$?" != "0" ]; then
							echo "$src $inf" >> je.log
							continue
						fi
						res=$(cat res)
						echo "$src $inf: $res" >> $result/$coder_name/log
						if [ "$res" != "AC" ]; then
							err=yes
							break
						fi
					done
					if [ "$err" = "no" ]; then
						cnt_ac=$(($cnt_ac + 1))
					fi
				done
				if [ $cnt_ac -gt $score ]; then
					score=$cnt_ac
				fi
			done
		fi
		echo "$score/$cnt" > $result/$coder_name/$task_name.score
	done
	./aggr.py $result/$coder_name/*.score > $result/$coder_name/summary
done
