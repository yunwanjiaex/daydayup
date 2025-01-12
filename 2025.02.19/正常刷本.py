from fgo_lib import *


# 阵容: 陈宫,圣诞玛尔达,双C呆,玛修,奥伯龙
for i in range(1, 10000):
    logger.info(f"===================第{i}场/第1回合===================")
    wait_image("attack.png")
    logger.info("玛尔达1,2,3技能")
    goskill(2, 1, 1)
    goskill(2, 2, 0)
    goskill(2, 3, 1)
    logger.info("c呆1,2,3技能")
    goskill(3, 1, 0)
    goskill(3, 2, 3)
    goskill(3, 3, 1)
    logger.info("攻击")
    goattack(3, 2, 1)

    logger.info(f"===================第{i}场/第2回合===================")
    wait_image("attack.png")
    logger.info("换人")
    goexchange(3, 3, 5)
    logger.info("c呆1,2,3技能")
    goskill(2, 1, 0)
    goskill(2, 2, 1)
    goskill(2, 3, 1)
    logger.info("奥伯龙1技能")
    goskill(3, 1, 0)
    logger.info("攻击")
    goattack(2, 1, 4)

    logger.info(f"===================第{i}场/第3回合===================")
    wait_image("attack.png")
    logger.info("陈宫2技能")
    goskill(1, 2, 0)
    logger.info("玛修2技能")
    goskill(2, 2, 1)
    logger.info("奥伯龙2,3技能")
    goskill(3, 2, 1)
    goskill(3, 3, 1)
    logger.info("加攻")
    goexchange(1)
    logger.info("攻击")
    goattack(1, 5, 4)

    wait_image("over.png")
    logger.info("战斗结束")
    for _ in range(7):
        cs(1300, 760, 0.3)
    # 可能会有的加好友环节
    cs(300, 800, 0.3)
    cs(800, 700, 0.3)

    wait_image("continue.png")
    logger.info("继续战斗")
    # "31/139",此处文字位置可能会有变化
    ap = read_digit(820, 450, 1000, 500)
    logger.info(f"=================现在AP为{ap}=================")

    cs(1050, 700, 1)
    ap = int(ap.split("/")[0])
    if ap < 40:
        # y=200彩石头/400金苹果/600银苹果/708青铜苹果
        cs(800, 400, 1)
        cs(1000, 700, 1)

    while True:
        # 锁定术阶找C呆
        t = wait_image("cdai.png", 9, 1)
        logger.info("找到助战")
        if t[0] >= 0:
            cs(t[0], t[1], 6)
            break
        # 刷新助战
        wait_image("list.png")
        cs(1166, 160, 2)
        cs(1046, 704, 2)
