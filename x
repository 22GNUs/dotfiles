   curl -s http://127.0.0.1:8317/v1/chat/completions \
     -H "Authorization: Bearer sk-ryfvDnXrMUFrAzPjmtot02Kf8SAcWXGjYebJHbpVyqS9A" \
     -H "Content-Type: application/json" \
     -d '{
       "model": "gpt-5.3-codex",
       "messages": [{"role": "user", "content": "hi"}],
       "max_tokens": 50
     }'



   curl -s https://ai.22gnusdev.xyz/v1/chat/completions \
     -H "Authorization: Bearer sk-ryfvDnXrMUFrAzPjmtot02Kf8SAcWXGjYebJHbpVyqS9A" \
     -H "Content-Type: application/json" \
     -d '{
       "model": "gpt-5.3-codex",
       "messages": [{"role": "user", "content": "hi"}],
       "max_tokens": 50
     }'

