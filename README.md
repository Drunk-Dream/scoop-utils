# scoop-utils

这是一个为scoop提供额外功能的工具，好吧其实我也不知道scoop本身有没有这个功能，就是写着玩的

## Usage

```powershell
scoop-utils.ps1 <command> [<options>]
```

- 获取命令帮助
    ```powershell
    scoop-utils help <command>
    ```

- 备份已安装的应用
    ```powershell
    scoop-utils backup [-o]
    ```
    默认保存在脚本所在目录

- 升级全部应用
    ```powershell
    scoop-utils update [--exclude]
    ```
    排除多个应用使用英文`,`分割

## TODO

- [ ] 安装备份的应用
- [x] 全部升级