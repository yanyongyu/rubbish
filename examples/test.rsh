help

echo && echo

echo "Welcome to rubbish shell!" && sleep 5 && echo "Bye~" &

echo && echo -n "User: " && export USER

alias list ls --color=always
list | wc -l
unalias list
list

echo && echo -n "Current directory: " && pwd

cd examples

echo && echo -n "After cd: " && export PWD

echo && echo Running thirdparty executable like python

echo && echo no redirect

python ./test.py

echo && echo redirect stdout

python ./test.py >test.txt

echo && echo redirect both stdout and stderr

python ./test.py >test.txt 2>&1
