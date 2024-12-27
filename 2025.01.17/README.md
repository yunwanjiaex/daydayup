# 自定义 ssh 登录验证
### Google Authenticator
1. 确保当前时间准确,生成验证文件和验证码,环境为 `Debian 12`
    ```bash
    apt install libpam-google-authenticator
    rm -f ~/.google_authenticator
    google-authenticator -tfdC -w3 -e3 -r3 -R30
    # -e3: 生成3个紧急备用代码
    # -r3 -R30: 每30秒允许3次登录
    ```
2. 手机端下载 [Google Authenticator](https://play.google.com/store/apps/details?id=com.google.android.apps.authenticator2) 扫描查看,命令行可以用 `oathtool`
    ```bash
    apt install oathtool
    oathtool -b --totp @.google_authenticator
    ```
3. 配置sshd
    ```bash
    echo 'PermitRootLogin yes
    PubkeyAuthentication yes
    PasswordAuthentication yes
    ChallengeResponseAuthentication yes
    KbdInteractiveAuthentication yes
    UsePAM yes' > /etc/ssh/sshd_config.d/google.conf
    systemctl restart sshd
    ```
4. 通过修改配置文件 `/etc/ssh/sshd_config.d/google.conf` (以下简称 cfg ) 和 `/etc/pam.d/sshd` (以下简称 pam )来调整密码验证,密钥验证和Google验证的启用和顺序
    * 密钥和Google双重验证
        * cfg: `AuthenticationMethods publickey,keyboard-interactive` ,位置决定先后顺序
        * pam: 注释掉 `@include common-auth` 行,并在此行之前添加 `auth required pam_google_authenticator.so`
    * 密码和Google双重验证
        * cfg: `AuthenticationMethods keyboard-interactive`
        * pam: 在 `@include common-auth` 行之前(或后)添加 `auth required pam_google_authenticator.so` ,位置决定先后顺序
    * 密码和密钥双重验证
        * cfg: `AuthenticationMethods publickey,password` ,位置决定先后顺序
    * 密码,密钥和Google三重验证
        * cfg: `AuthenticationMethods publickey,keyboard-interactive`
        * pam: 在 `@include common-auth` 行之前(或后)添加 `auth required pam_google_authenticator.so`
    * Google和密码验证二选一
        * cfg: `AuthenticationMethods keyboard-interactive`
        * pam: 在 `@include common-auth` 行之前添加 `auth sufficient pam_google_authenticator.so`
    * 密钥和Google验证二选一
        * cfg: `AuthenticationMethods publickey keyboard-interactive`
        * pam: 注释掉 `@include common-auth` 行,并在此行之前添加 `auth required pam_google_authenticator.so`
### Python PAM
1. 编译 `pam_python3.so`
    ```bash
    apt install libpam0g-dev
    git clone --branch v20231123 https://git.code.sf.net/p/pam-python-py3/code pam-python-py3
    cd pam-python-py3
    make lib
    mkdir /lib/security
    cp -fv src/build/lib.linux-x86_64-cpython-311/pam_python3.cpython-311-x86_64-linux-gnu.so /lib/security/pam_python3.so
    chmod 644 /lib/security/pam_python3.so
    ```
2. 自定义 PIN 码登录 demo,位置 `/lib/security/ssh_auth.py` ,输入 `memeda` 即可成功登录
    ```python
    def pam_sm_authenticate(pamh, flags, argv):
        resp = pamh.conversation(pamh.Message(pamh.PAM_PROMPT_ECHO_OFF, "PIN: "))
        if resp.resp == "memeda":
            return pamh.PAM_SUCCESS
        return pamh.PAM_AUTH_ERR

    def pam_sm_setcred(pamh, flags, argv):
        return pamh.PAM_SUCCESS

    def pam_sm_acct_mgmt(pamh, flags, argv):
        return pamh.PAM_SUCCESS

    def pam_sm_open_session(pamh, flags, argv):
        return pamh.PAM_SUCCESS

    def pam_sm_close_session(pamh, flags, argv):
        return pamh.PAM_SUCCESS

    def pam_sm_chauthtok(pamh, flags, argv):
        return pamh.PAM_SUCCESS
    ```
3. 添加 `auth requisite pam_python3.so ssh_auth.py` 到 `/etc/pam.d/sshd` ,配置同上面 3,4 步骤