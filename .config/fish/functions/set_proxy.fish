function set_proxy
    set -gx all_proxy http://my.proxy:7890
    set -gx http_proxy http://my.proxy:7890
    set -gx https_proxy http://my.proxy:7890

    # 基础：本地地址不走代理
    # 域名后缀匹配：.example.com 匹配 *.example.com
    # 新增域名只需追加到列表末尾
    set -gx no_proxy localhost,127.0.0.1,.local,.internal,.cn,.aliyun.com,.alibaba-inc.com,.taobao.com,.jd.com,.bilibili.com,.qq.com,.163.com,.baidu.com
end
