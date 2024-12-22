# 修改《戴森球计划》存档的创建者
```python
my_steam_id = 76561199571326057
his_name = "TTenYX"
dsv_path = r"C:\\Users\\kunkun\\Desktop\\黑雾版本120万白糖存档.dsv"

with open(dsv_path, "rb") as f:
    c = bytearray(f.read(1024 * 1024))

p1 = c.find(bytes(his_name, encoding="utf-8"))
p2 = c.find(bytes(his_name, encoding="utf-8"), p1 + 1)
for p in (p1, p2):
    c[p - 9 : p - 1] = my_steam_id.to_bytes(8, "little")

with open(dsv_path, "r+b") as f:
    f.write(c)
```
1. 通过将大佬的存档的创建者改为自己,可以轻松白嫖他的游戏进度,元数据和成就,直接少走 1000 小时弯路
2. 需要将 `my_steam_id`, `his_name`, `dsv_path` 换成相应数据. `my_steam_id` 为自己的 `Steam ID`,点击右上角头像,账户明细,可以查看, `his_name` 为对方的 steam 昵称,用对方存档进入一次游戏,可以在右上角看到, `dsv_path` 为要修改的存档路径
3. 唯一要注意的是,因为会借助 steam 昵称在存档中定位,如果昵称过于简单,则可能会修改到错误的地方,所以修改前先备份
4. 进入游戏载入修改过的存档,再手动存一次档然后载入刚存的档,右上角的昵称就会变成自己的