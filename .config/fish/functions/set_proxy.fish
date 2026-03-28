function set_proxy
    set -gx all_proxy http://my.proxy:7890
    set -gx http_proxy http://my.proxy:7890
    set -gx https_proxy http://my.proxy:7890
    set -gx NO_PROXY localhost,127.0.0.1
end
