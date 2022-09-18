# Restful CGI ( Common Gateway Interface )

Nginx + CGI 是使用 Perl 建立 Nginx 與 FastCGI 溝通用的 IPC Socket；並由 Perl 與 Python 撰寫符合 Restful 架構的 CGI 服務。

此設計不考慮使用 Python、Perl 相關的服務框架，而是採用 Nginx 完成路由設定，並呼叫對應的 CGI 服務。

## 啟動服務

本專案可啟動 Perl、Python 不同語言撰寫的 CGI 服務，啟用方式請使用專案內的控制台命令介面 ( CLI ) ```dockerw.bat``` 檔案

+ Perl
```
dockerw perl
```

+ Python
```
dockerw python
```

測試業面：
+ [Nginx 首頁](http://localhost/)
+ [index CGI in cgi-bin](http://localhost/cgi-bin)
+ [api.html page call api.pl/api.py](http://localhost/api.html)

## Restful 檢測

### Postman

+ 啟動 Python 服務
```
dockerw python
```

+ 執行 Postman 服務
```
docekrw test
```

### CURL

+ GET
```
curl -X GET -v "http://localhost/rapi/1234/root?var1=abc&var2=098"
```

+ POST
```
curl -X POST -H "Content-Type: application/json" -d "{\"key1\": \"laks\",\"key2\": true,\"key3\": 5678}" -v "http://localhost/rapi/1234/root?var1=abc&var2=098"
```

+ PUT
```
curl -X PUT -H "Content-Type: application/json" -d "{\"key1\": \"laks\",\"key2\": true,\"key3\": 5678}" -v "http://localhost/rapi/1234/root?var1=abc&var2=098"
```

+ DELETE
```
curl -X DELETE -v "http://localhost/rapi/1234/root"
```

## 文獻

+ [Common Gateway Interface wiki](https://zh.wikipedia.org/zh-tw/%E9%80%9A%E7%94%A8%E7%BD%91%E5%85%B3%E6%8E%A5%E5%8F%A3)
    - [What is the Common Gateway interface (CGI)?](https://mixwithmarketing.com/2022/02/what-is-the-common-gateway-interface-cgi/)
+ [RestFul](https://zh.wikipedia.org/zh-tw/%E8%A1%A8%E7%8E%B0%E5%B1%82%E7%8A%B6%E6%80%81%E8%BD%AC%E6%8D%A2)
+ Python
    - [PYTHON – CGI PROGRAMMING](https://prutor.ai/python-cgi-programming/)
    - [Snippet to apply Restful routes in Python CGI](https://gist.github.com/mittmannv8/2ce00275f139e0a5a7732e068ec79333)
+ Perl
    - [CGI::Application::Plugin::REST](https://metacpan.org/pod/CGI::Application::Plugin::REST)
