from fgo_lib import *

# 抽友情池,自动变还只留下一二星礼装
while True:
    x, _ = wait_image("full.png", 1, 1)
    if x >= 1:
        logger.info("友情池抽完")
        break
    for _ in range(20):
        cs(957, 843, 0.2)
        cs(1033, 704, 0.2)

# 过渡
cs(800, 600, 3)
cs(250, 500, 3)

# 搓丸子
# 筛选中仅留下一二星礼装,开启智能筛选,确保已经锁定的礼装排在最后
while True:
    wait_image("choose.png")
    logger.info("选择要升级的礼装")
    cs(1266, 250, 1)
    cs(38, 440, 1)
    cs(335, 314, 1)
    cs(38, 300, 2)
    cs(335, 314, 2)

    level_o = 0
    while True:
        # 识别错误则重试3次
        for _ in range(3):
            try:
                wait_image("level.png", 5, 1)
                level = read_digit(563, 549, 709, 597).split("/")
                level[0] = int(level[0])
                level[1] = int(level[1])
                assert level[1] > 9
                logger.info(f"目前丸子等级为{level[0]}/{level[1]}")
                break
            except:
                # 可能会卡在结算页面
                logger.info(f"识别出错")
                cs(1000, 740, 1)
        # 升到20级换下一个
        if level[0] >= 20:
            logger.info(f"此丸子{level[0]}级,已搓完")
            cs(250, 500, 1)
            break
        if level_o == level[0]:
            logger.info(f"无法升级,已搓完")
            exit()
        level_o = level[0]

        logger.info("继续搓丸子")
        cs(1500, 400, 2)
        for y in range(3):
            for x in range(7):
                cs(164 + 167 * x, 315 + 177 * y, 0.2)

        logger.info("点击强化")
        cs(1500, 840, 1)
        cs(1500, 840, 1)
        for i in range(7):
            cs(1000, 740, 0.6, 1)
