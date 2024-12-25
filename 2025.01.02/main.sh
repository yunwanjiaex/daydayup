cd "$(dirname "$0")"
format_date(){ date "+%y.%m.%d_%H.%M.%S_%6N"; }

git pull
git add -A
git commit -m $(format_date)
git push # -u origin master

cd $("ls" -d once* | tail -1)
res=res_$(hostname).txt
[ -f $res ] || [ ! -f run.sh ] && exit

echo "start at $(format_date)" > $res
"bash" run.sh >> $res
echo "finish at $(format_date)" >> $res