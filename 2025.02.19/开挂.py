from fgo_lib import *

t = -1
while True:
    # 每场有几个回合
    for _ in range(3):
        wait_image("attack.png")
        # 外援3号位,每回合放宝具,其它随意
        goattack(3, 7, 8)

    wait_image("over.png")
    for _ in range(6):
        cs(1500, 800, 0.3)
    cs(414, 769, 0.3)

    wait_image("continue.png")
    ap = read_digit(820, 450, 1000, 500)
    logger.info(f"AP = {ap}")
    cs(1050, 700, 1)
    ap = int(ap.split("/")[0])
    # 每场消耗AP
    if ap < 40:
        t += 1
        # 刷完几个苹果后结束
        if t >= 2:
            break
        cs(800, 400, 1)
        cs(1000, 700, 1)
        logger.info(f"已吃{t+1}个苹果")

    wait_image("friend.png")
    # 选第1个助战
    cs(800, 350, 2)
