---
name: walkie-talkie
description: WhatsApp 语音/文字双模对话：收到语音消息自动本地转写（Whisper CLI），并用语音消息 + 文字双回复。
---

# Walkie-Talkie（WhatsApp 语音对话模式）

目标：用户既可以发**文字**也可以发**语音**；我都能理解并回复。若用户发语音，我会：
- **先转写成文字**（用于理解与可读性）
- **再生成语音回复**（语音消息 / voice note）
- **同时发回文字 + 语音**（避免听不清/便于复制）

## 工作流

### 1) 收到语音消息（WhatsApp voice note / audio）
1. 在消息上下文中找到音频附件的本地路径（通常会以 `MEDIA: /path/to/file` 或类似字段出现）。
2. 如音频为 `ogg/opus`，可直接用 Whisper；如遇到格式问题，先用 ffmpeg 转成 mp3：
   - `ffmpeg -y -i input.ogg -ar 16000 -ac 1 /tmp/in.mp3`
3. 用本地 Whisper CLI 转写：
   - `whisper /tmp/in.mp3 --model small --output_format txt --output_dir /tmp`
   - 读取 `/tmp/in.txt` 得到转写文本。
4. 将转写文本当作用户的真实输入来处理，并生成正常的文字回复。

### 2) 回复语音 + 文字
1. **先发送文字回复**（清晰、可复制）。
2. 再把同样的内容用 `tts` 工具生成音频，并用 `message` 工具作为语音消息发送：
   - `tts(text=回复内容)` → 得到 `MEDIA: ...`
   - `message(action="send", channel="whatsapp", ... , filePath=<MEDIA路径>, asVoice=true)`

## 触发方式
- 用户发送音频/语音消息时自动触发（若平台把转写/媒体路径注入上下文）。
- 或用户说：
  - “开启语音模式 / walkie-talkie 模式”
  - “用语音和我说”

## 约束/注意
- 转写默认用 `--model small`（速度/准确性折中）；需要更准可提升到 `medium`。
- 必须**双回复**：文字 + 语音。
- 任何一步缺依赖（找不到媒体路径、whisper 失败、tts 失败）要明确报错并给出下一步（例如让用户重发、或改用文字）。

## 手动命令（内部）
```bash
# 1) 语音转写
ffmpeg -y -i input.ogg -ar 16000 -ac 1 /tmp/in.mp3
whisper /tmp/in.mp3 --model small --output_format txt --output_dir /tmp
cat /tmp/in.txt
```
