#!/usr/bin/env bash
# 构建 nova 品牌审核 (brand-audit) iframe URL
#
# 用法:
#   ./nova-brand-audit-url.sh <sellerId> <id>
# 示例:
#   ./nova-brand-audit-url.sh 6000655586 5990141
#
# 说明: iframeUrl 的值会被整体 encodeURIComponent，
# 这样内层的 & 不会被外层 URL 当作参数分隔符，
# 从而保证 iframe 内页面能正确取到 id / sellerId 等参数。

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <sellerId> <id>" >&2
  exit 1
fi

seller_id="$1"
audit_id="$2"

# 固定参数
digital_emp_id="676"
digital_emp_type="TASK"
iframe_type="page"
op_group_id="1.4794.9717.0.9856"
audit_type="0"
to_nova="true"

# 内层 iframe 指向的真实业务地址（参数未编码）
inner_url="https://global.alibaba-inc.com/bzb/business/brand-audit/detail?opGroupId=${op_group_id}&id=${audit_id}&sellerId=${seller_id}&auditType=${audit_type}&toNova=${to_nova}"

# 外层 nova myagent 地址，iframeUrl 整体编码
encoded_inner=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1], safe=''))" "$inner_url")

final_url="https://nova.alibaba-inc.com/myagent/detail?digitalEmpId=${digital_emp_id}&digitalEmpType=${digital_emp_type}&iframeType=${iframe_type}&iframeUrl=${encoded_inner}"

echo "$final_url"
