---
name: exa-contents
description: Fetch web page content using Exa AI API. Extract full text content from specified URLs.
---

# Exa Contents

Exa Contents API 用于抓取指定网页的完整内容。

## Setup

1. 从 [Exa Dashboard](https://dashboard.exa.ai/) 获取 API key
2. 设置环境变量: `export EXA_API_KEY=your_api_key`

或者在第一次使用时 skill 会提示你输入 API key。

## Usage

### Basic Content Fetch

```bash
./contents.sh "https://example.com/page1"
```

### Fetch Multiple Pages

```bash
./contents.sh "https://url1.com" "https://url2.com" "https://url3.com"
```

## API Endpoint

- **Contents**: `POST https://api.exa.ai/contents`

## Response Format

返回结果包含:
- `url`: 页面 URL
- `title`: 页面标题
- `text`: 页面完整文本内容
- `extract`: 页面摘要

## Examples

```bash
# 抓取单个页面
./contents.sh "https://docs.python.org/3/tutorial/"

# 抓取多个页面
./contents.sh "https://react.dev/learn" "https://react.dev/learn/state"

# 抓取技术文档
./contents.sh "https://docs.github.com/en/rest"
```

## Error Handling

- HTTP 401: API key 无效或缺失
- HTTP 429: 超出速率限制
- HTTP 422: 请求参数无效
- HTTP 404: 页面无法访问

更多详情查看 [Exa Documentation](https://docs.exa.ai/)
