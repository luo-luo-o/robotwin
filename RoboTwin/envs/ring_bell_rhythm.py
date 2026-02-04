# pyright: reportArgumentType=false
from ._base_task import Base_Task
from .utils import *
import sapien
import numpy as np
import sys

def flushed_print(*args, **kwargs):
    """确保日志能够实时刷新的打印函数"""
    print(*args, **kwargs)
    sys.stdout.flush()

class ring_bell_rhythm(Base_Task):
    """铃声节奏任务环境"""

    def setup_demo(self, **kwags):
        super()._init_task_env_(**kwags)

        self.info["info"] = {
            "task": "ring_bell_rhythm",
        }

    def load_actors(self):
        flushed_print("正在加载资产...")

    def play_once(self):
        flushed_print("开始环境演示...")

    def check_success(self):
        pass

if __name__ == "__main__":
    pass