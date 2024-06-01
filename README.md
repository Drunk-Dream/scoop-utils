# scoop-utils

这是一个为 scoop 提供额外功能的工具，好吧其实我也不知道 scoop 本身有没有这个功能，就是写着玩的

## Usage

```powershell
scoop-utils.ps1 <command> [<options>]
```

- **获取命令帮助**

  ```powershell**
  scoop-utils help <command>
  ```

- **备份已安装的应用**

  ```powershell
  scoop-utils backup [-o]
  ```

  默认备份在运行目录下的 scoop-list.xml

- **安装备份的应用**

  ```powershell
  scoop-utils install [-i|-v|-y]
  ```

  默认导入运行目录下的 scoop-list.xml

- **升级全部应用**
  ```powershell
  scoop-utils update [--exclude]
  ```
  排除多个应用使用英文`,`分割

## TODO

- [x] 安装备份的应用
- [x] 全部升级
