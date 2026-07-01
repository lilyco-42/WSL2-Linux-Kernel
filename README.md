# WSL2 Linux Kernel (Custom Distribution & Module Dev Environment)

这是一个经过极致精简与完全体优化的 WSL2 内核分发仓库。本仓库剔除了庞大的内核开发源码树，**仅保留了编译完成的轻量化内核镜像、提取净化后的标准内核头文件，以及编译自定义驱动（内核模块）所需的全部构建桩（Kbuild 系统）**。

无论是普通用户想要一键为 WSL2 换芯，还是开发者想要针对此内核版本开发外部 `.ko` 驱动，都能在几秒钟内无缝完成环境搭建。

## 📦 仓库内容

* **`vmlinux`**: 剔除了调试符号（已执行 `strip -s`）的精简版 WSL2 内核二进制镜像（约 59MB）。
* **`usr/include/`**: 通过内核官方 `make headers_install` 净化提取的标准 UAPI 内核头文件。
* **`Module.symvers`**: **驱动开发核心**。记录了当前内核所有导出符号的 CRC 校验码，确保编译出的模块能被内核成功加载。
* **`scripts/` & `Makefile` & `Kbuild`**: 完整的内核轻量构建桩，允许外部驱动借用其构建系统进行二次编译。

---

## 🚀 场景一：直接为当前的 WSL2 更换此内核

如果你不想耗费数小时去编译 Linux 内核，可以直接下载本仓库的镜像进行一键替换：

### 1. 轻量化克隆本仓库
由于去除了历史包袱，使用 `--depth 1` 可以实现秒级克隆：
```bash
git clone --depth 1 -b linux-msft-wsl-6.6.y git@github.com:lilyco-42/WSL2-Linux-Kernel.git
```
2.在Windows中配置.wslconfig
在Windows资源管理器中，点击荒野Win + R，输入%USERPROFILE%回车（进入Windows当前用户的主目录）。

检查该目录下是否存在.wslconfig文件。如果不存在，请新建一个文本文件并重命名为.wslconfig。

使用文本编辑器打开它，添加以下配置（此路径修改为你实际克隆出的vmlinux绝对路径，注意必须使用双反斜杠\\）：

Ini，TOML
[wsl2]
kernel=C:\\Users\\你的Windows用户名\\Documents\\WSL2-Linux-Kernel\\vmlinux
3.重启WSL2生效
Windows Terminal (PowerShell)，强行关闭并重启打开WSL实例：

PowerShell
wsl --shutdown
重新进入你的WSL2终端，验证内核版本与编译时间是否已切换成功：

巴什
uname -a
🛠️场景二：自己编写与编译的Linux内核模块(.ko)
本仓库内置了完整的模块编译支持，别人或者你自己下载全量仓库源码，就可以直接在这个轻量仓库上编译驱动。

1.编写你的驱动代码（例如hello.c）
C
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Lanque");
MODULE_DESCRIPTION("A Simple WSL2 Kernel Module");

static int __init hello_init(void) {
    printk(KERN_INFO "Hello WSL2 Kernel!\n");
    return 0;
}

static void __exit hello_exit(void) {
    printk(KERN_INFO "Goodbye WSL2 Kernel!\n");
}

module_init(hello_init);
module_exit(hello_exit);
2. 准备的Makefile
在驱动同级目录下创建Makefile，源码将KDIR指向本仓库克隆下来的本地路径：

Makefile
obj-m += hello.o

# 将此处替换为本仓库在本地的绝对路径
KDIR := /home/lyco/WSL2-Linux-Kernel

PWD := $(shell pwd)

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean
3.编译与加载
在驱动目录下直接执行：

巴什
# 1. 借用本仓库的构建桩一键编译驱动
make

# 2. 加载模块到 WSL2 内核中
sudo insmod hello.ko

# 3. 查看内核日志，验证是否打印成功
dmesg | tail -n 5
🔍场景三：普通C/C++程序引用内核标准头文件
如果你在编写依赖内核底层数据结构的普通用户态程序，可以直接通过-I参数将头文件内部路径指向本仓库的usr/include：

Makefile
CFLAGS += -I/path/to/WSL2-Linux-Kernel/usr/include
