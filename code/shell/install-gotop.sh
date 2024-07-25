#!/bin/sh

# 一个使用 Go 编写TUI 图形活动监视器，用于监视 Linux 系统的活动，包括 CPU、磁盘、内存、网络、CPU温度和进程列表的使用情况。
# 使用教程：https://www.linuxidc.com/Linux/2018-05/152266.htm
# 终端运行以下命令
# gotop 
# 系统 CPU、磁盘、内存、网络、CPU温度和进程列表的使用情况
# gotop -m
# 仅显示CPU、内存和进程组件

# 你可以使用以下键盘快捷键对进程表进行排序。
# c – CPU
# m – 内存
# p – PID
# 对于进程浏览，请使用以下键。

# 上/下 箭头或者 j/k 键用于上移下移。
# Ctrl-d 和 Ctrl-u – 上移和下移半页。
# Ctrl-f 和 Ctrl-b – 上移和下移整页。
# gg 和 G – 跳转顶部和底部。
# 按下 TAB 切换进程分组。要杀死选定的进程或进程组，请输入 dd。
# 要选择一个进程，只需点击它。要向下/向上滚动，请使用鼠标滚动按钮。要放大和缩小 CPU 和内存的图形，请使用 h 和 l。要显示帮助菜单，只需按 ?

cd ~
yum install -y git
git clone https://gitee.com/feynman0919/gotop
sh gotop/scripts/download.sh
cp gotop/scripts/gotop /usr/local/bin
chmod +x /usr/local/bin/gotop
gotop
