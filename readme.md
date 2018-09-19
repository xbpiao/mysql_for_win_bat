# 绿色安装windows版本mysql的批处理

mysql5.7.21、mysql-5.7.23、mysql-8.0.12下测试通过

下载链接：https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.21-winx64.zip

将setup.bat放到相应路径下，例如：

```
G:\GREENSOFT\MYSQL-5.7.21-WINX64
├──bin
├──docs
├──include
├──lib
├──share
├─setup.bat
└─clear.bat
```

运行setup.bat

1. 初始化data
2. 生成my.ini、my.cnf
3. 启动服务
4. 重置root密码为root123

## 注意

如果使用 **下载zip** 的方式需要自行将.bat转换为Windows(CR LF)风格的回车换行才能正确执行
