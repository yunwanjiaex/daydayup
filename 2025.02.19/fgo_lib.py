import os, cv2, time, logging, uiautomator2
from paddleocr import PaddleOCR

# 添加日志
os.chdir(os.path.split(os.path.realpath(__file__))[0])
logger = logging.getLogger("fgo_logger")
logger.propagate = False
logger.setLevel(logging.DEBUG)
f = logging.Formatter("[%(asctime)s]: %(message)s", datefmt="%FT%T")
h = logging.FileHandler(filename="fgo.log", encoding="utf-8")
h.setLevel(logging.DEBUG)
h.setFormatter(f)
logger.addHandler(h)
h = logging.StreamHandler()
h.setLevel(logging.DEBUG)
h.setFormatter(f)
logger.addHandler(h)
# 预先确保adb已连接
d = uiautomator2.connect()


# 点击屏幕对应位置然后等待几秒
def cs(x, y, s=0, z=0):
    logger.info(f"click {x},{y} and sleep {s}")
    d.click(x, y)
    if z == 0 or s <= 0.3:
        time.sleep(s)
        return True
    # 如果z不为0,连点一下加速
    time.sleep(0.3)
    d.click(x, y)
    time.sleep(s - 0.3)


# 读取屏幕某区域的一行英文,目前只用于判断AP然后吃苹果
def read_digit(x1, y1, x2, y2):
    d.screenshot().crop((x1, y1, x2, y2)).save("tmp.png")
    res = PaddleOCR(lang="en").ocr("tmp.png")
    logger.info(res)
    for l in res[0]:
        return l[1][0]


# 在规定时间内等待屏幕出现相应元素,默认等待30次3秒,即90秒
# 若指定坐标则在屏幕上的该坐标范围内等待元素
def wait_image(img_file, s=30, e=0, x1=0, y1=0, x2=0, y2=0):
    logger.info(f"正在读取{img_file}")
    img_find = cv2.imread(img_file, cv2.IMREAD_GRAYSCALE)

    for b in range(s):
        logger.info("正在读取屏幕")
        img_screen = d.screenshot()
        if x2 != 0:
            img_screen = img_screen.crop((x1, y1, x2, y2))
        img_screen.save("tmp.png")
        img_screen = cv2.imread("tmp.png", cv2.IMREAD_GRAYSCALE)

        res = cv2.matchTemplate(img_screen, img_find, cv2.TM_CCOEFF_NORMED)
        _, val, _, top_left = cv2.minMaxLoc(res)
        if val >= 0.95:
            logger.info(f"已找到图像,位于{top_left}")
            time.sleep(0.3)
            # 返回找到的图片的左上角坐标,如果指定了范围,则返回的坐标是相对于指定坐标的左上角坐标
            return top_left
        if s == 1:
            break
        logger.info(f"图像未找到,3s后重试{b+1}")
        time.sleep(3)

    # 未找到图片执行操作,默认是截图退出
    if e == 0:
        logger.info("等待超时,退出")
        d.screenshot(f"troubleshoot_{time.strftime('%Y-%m-%d_%H-%M-%S')}.png")
        exit()
    else:
        logger.info("未找到图片,继续执行")
        return (-1, -1)


# 第几个人的第几个技能给第几个人,暂时不考虑库库尔坎这种多一次确认的情况
def goskill(a, b, c=0):
    x1 = 400 * a + 110 * b - 420
    x2 = 400 * c
    if c == 0:
        cs(x1, 720, 2, 1)
    else:
        cs(x1, 720, 0.6)
        cs(x2, 550, 2, 1)


# 攻击时选卡,宝具卡为1,2,3,普通卡为4,5,6,7,8
def goattack(a, b, c):
    t = 0
    cs(1420, 750, 1)
    for i in [a, b, c]:
        if i <= 3:
            cs(280 * i + 240, 250, 0.6)
            t += 1
        else:
            cs(320 * i - 1120, 620, 0.6)
    t = 10 + 14 * t
    logger.info(f"sleep {t}")
    time.sleep(t)


# 换人服,a为技能位置,b和c为换人位置,范围是1-6
def goexchange(a, b=0, c=0):
    cs(1500, 390, 0.6)
    if a == 1:
        cs(1130, 390, 2, 1)
    elif a == 3:
        cs(1350, 390, 0.6)
        cs(b * 250 - 80, 390, 0.6)
        cs(c * 250 - 80, 390, 0.6)
        cs(800, 780, 6)
