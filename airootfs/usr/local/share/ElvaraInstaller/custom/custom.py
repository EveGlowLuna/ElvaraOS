import shutil
from installer import base_system

def run(mount_point):
    print("请修改文件来实现自定义效果。这是一个自定义效果，执行customize_system.sh")
    shutil.copy("customize_system.sh", f'{mount_point}/root/customize_system.sh')
    base_system.arch_chroot(mount_point, ['bash', '/root/customize_system.sh'])